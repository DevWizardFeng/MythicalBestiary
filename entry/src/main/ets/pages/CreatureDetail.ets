/**
 * 神话志 - 神兽详情页
 * 全屏展示神兽详细信息
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { AttributeType, RarityType, CultureType, AlignmentType, CreatureType,
  getAttributeColor, getRarityColor, getRarityName, getCultureName, getAlignmentName, getCreatureTypeName,
  ColorPair, RarityInfo, CultureNameInfo, NamePair } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { CreatureCard } from '../components/CreatureCard';
import { AttributeTag } from '../components/AttributeTag';
import { RarityBadge } from '../components/RarityBadge';
import { TTSManager, TTSState } from '../utils/TTSManager';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

interface RouterParams {
  creatureId: string;
}

@Entry
@Component
struct CreatureDetail {
  @State creature: MythicalCreature | null = null;
  @State relatedCreatures: MythicalCreature[] = [];
  @State isFavorite: boolean = false;
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  @State isTTSPlaying: boolean = false;
  private creatureId: string = '';
  private ttsManager: TTSManager = new TTSManager();

  private tabs: string[] = ['神话传说', '能力特点', '文化象征'];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.creatureId) {
      this.creatureId = params.creatureId;
      this.loadData();
    }
    this.initTTS();
  }

  aboutToDisappear(): void {
    this.releaseTTS();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      this.creature = dataLoader.getCreatureById(this.creatureId) || null;

      if (this.creature) {
        // 获取相关神兽
        const allCreatures = dataLoader.getAllCreatures();
        this.relatedCreatures = allCreatures
          .filter(c => c.id !== this.creature?.id &&
            (c.culture === this.creature?.culture ||
             c.attributes.primary === this.creature?.attributes.primary))
          .slice(0, 4);

        // 检查是否已收藏
        const storage = StorageUtil.getInstance();
        await storage.initialize();
        const favorites = await storage.getFavorites();
        this.isFavorite = favorites.includes(this.creatureId);

        // 记录浏览历史
        await storage.addBrowsingHistory(this.creatureId);
      }

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load creature detail:', error);
      this.isLoading = false;
    }
  }

  async toggleFavorite() {
    try {
      const storage = StorageUtil.getInstance();
      if (this.isFavorite) {
        await storage.removeFavorite(this.creatureId);
      } else {
        await storage.addFavorite(this.creatureId);
      }
      this.isFavorite = !this.isFavorite;
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  }

  /**
   * 保存图片到相册
   */
  async saveImageToGallery() {
    try {
      if (!this.creature?.image) {
        promptAction.showToast({ message: '图片不存在' });
        return;
      }

      const context = this.getUIContext().getHostContext();
      if (!context) {
        promptAction.showToast({ message: '获取上下文失败' });
        return;
      }

      const helper = photoAccessHelper.getPhotoAccessHelper(context);

      // 创建媒体库图片文件
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
      const file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

      // 读取应用资源图片内容
      const imageResourceId = $r(`app.media.${this.creature.image}`).id;
      const mediaContent = await context.resourceManager.getMediaContent(imageResourceId, 0);
      const imageBuffer = mediaContent.buffer;

      // 写入媒体库文件
      await fileIo.write(file.fd, imageBuffer);
      await fileIo.close(file.fd);

      promptAction.showToast({ message: '已保存至相册' });
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to save image: ${err.code}, ${err.message}`);
      promptAction.showToast({ message: '保存失败' });
    }
  }

  /**
   * 初始化 TTS 引擎
   */
  async initTTS(): Promise<void> {
    try {
      await this.ttsManager.init()

      // 设置状态变化监听器
      this.ttsManager.setOnStateChange((state: TTSState) => {
        this.isTTSPlaying = (state === TTSState.PLAYING)
      })

      console.info('TTS 引擎初始化成功')
    } catch (error) {
      console.error('TTS 引擎初始化失败:', error)
    }
  }

  /**
   * 释放 TTS 资源
   */
  async releaseTTS(): Promise<void> {
    try {
      await this.ttsManager.release()
      console.info('TTS 资源已释放')
    } catch (error) {
      console.error('TTS 资源释放失败:', error)
    }
  }

  /**
   * 播放/停止语音
   */
  async toggleTTS(): Promise<void> {
    if (!this.creature) return

    try {
      if (this.isTTSPlaying) {
        // 停止播放
        this.isTTSPlaying = false
        await this.ttsManager.stop()
      } else {
        // 组合要朗读的文本
        const text = this.buildIntroText()

        // 快速切换状态来"预热"动效（解决首次点击动效不生效问题）
        this.isTTSPlaying = true
        this.isTTSPlaying = false
        setTimeout(() => {
          this.isTTSPlaying = true
        }, 16) // 一帧的时间（约16ms）

        // 开始播放
        try {
          await this.ttsManager.speak(text)
        } catch (speakError) {
          this.isTTSPlaying = false
          throw new Error(`TTS 播放失败: ${speakError}`)
        }
      }
    } catch (error) {
      console.error('TTS 操作失败:', error)
      this.isTTSPlaying = false
      promptAction.showToast({
        message: '语音播放失败，请稍后重试',
        duration: 2000,
        bottom: 100
      })
    }
  }

  /**
   * 构建要朗读的文本
   */
  private buildIntroText(): string {
    if (!this.creature) return ''

    const parts: string[] = []

    // 名称和品质
    const rarityName = getRarityName(this.creature.rarity as RarityType).cn
    parts.push(`${this.creature.name.cn}，${rarityName}品质神兽。`)

    // 英文名和原名
    if (this.creature.name.en) {
      parts.push(`英文名称：${this.creature.name.en}。`)
    }
    if (this.creature.name.original && this.creature.name.original !== this.creature.name.cn) {
      parts.push(`原名：${this.creature.name.original}。`)
    }

    // 分类
    const cultureName = getCultureName(this.creature.culture as CultureType).cn
    const typeName = getCreatureTypeName(this.creature.type as CreatureType).cn
    const alignmentName = getAlignmentName(this.creature.alignment as AlignmentType).cn
    parts.push(`来自${cultureName}神话，属于${typeName}类型，阵营为${alignmentName}。`)

    // 描述
    parts.push(this.creature.description)

    // 神话传说
    if (this.creature.mythology) {
      parts.push(`神话传说：${this.creature.mythology}`)
    }

    // 能力特点
    if (this.creature.abilities && this.creature.abilities.length > 0) {
      parts.push(`能力特点：${this.creature.abilities.join('、')}。`)
    }

    // 文化象征
    if (this.creature.symbolism) {
      parts.push(`文化象征：${this.creature.symbolism}`)
    }

    return parts.join(' ')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 背景图片
      Image($r('app.media.bg_creature_detail'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.creature) {
        Scroll() {
          Column() {
            // 顶部大图
            this.HeroImage()

            // 基本信息
            this.BasicInfo()

            // Tab内容
            this.TabContent()

            // 相关神兽
            if (this.relatedCreatures.length > 0) {
              this.RelatedCreatures()
            }

            // 底部占位
            Column()
              .height(32)
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        // 顶部导航栏
        this.TopBar()
      } else {
        this.ErrorView()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopBar() {
    Row() {
      // 返回按钮
      Stack() {
        Circle()
          .width(36)
          .height(36)
          .fill('rgba(0,0,0,0.3)')

        Image($r('app.media.ic_arrow_left'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        router.back();
      })

      Blank()

      // 保存按钮
      Column() {
        SaveButton({
          icon: SaveIconStyle.FULL_FILLED,
          buttonType: ButtonType.Capsule
        })
          .width(36)
          .height(36)
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              await this.saveImageToGallery();
            } else {
              promptAction.showToast({ message: '授权失败' });
            }
          })
      }
      .margin({ right: 8 })

      // 收藏按钮
      Stack() {
        Circle()
          .width(36)
          .height(36)
          .fill('rgba(0,0,0,0.3)')

        Image(this.isFavorite ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        this.toggleFavorite();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
  }

  @Builder
  HeroImage() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 神兽图片
      Image($r(`app.media.${this.creature?.image}`))
        .width('100%')
        .height(360)
        .objectFit(ImageFit.Cover)

      // 渐变遮罩
      Column()
        .width('100%')
        .height('50%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [[DarkTheme.background, 0], ['rgba(18,18,18,0)', 1]]
        })
    }
    .width('100%')
    .height(360)
  }

  @Builder
  BasicInfo() {
    Column({ space: 16 }) {
      // 名称
      Row({ space: 12 }) {
        Text(this.creature?.name.cn)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        RarityBadge({
          rarity: this.creature?.rarity as RarityType,
          badgeSize: 'medium'
        })
      }
      .width('100%')

      // 英文名和原名
      Column({ space: 4 }) {
        Text(this.creature?.name.en)
          .fontSize(16)
          .fontColor(DarkTheme.textSecondary)

        if (this.creature?.name.original && this.creature?.name.original !== this.creature?.name.cn) {
          Text(`原名: ${this.creature?.name.original}`)
            .fontSize(14)
            .fontColor(DarkTheme.textTertiary)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 标签
      Row({ space: 8 }) {
        // 文化
        Row({ space: 4 }) {
          Image($r(`app.media.ic_culture_${this.creature?.culture}`))
            .width(16)
            .height(16)
            .clip(true)
            .borderRadius(8)

          Text(getCultureName(this.creature?.culture as CultureType).cn)
            .fontSize(12)
            .fontColor(DarkTheme.textSecondary)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(DarkTheme.backgroundSecondary)
        .borderRadius(12)

        // 属性
        AttributeTag({
          attribute: this.creature?.attributes.primary as AttributeType,
          tagSize: 'small'
        })

        // 阵营
        Text(getAlignmentName(this.creature?.alignment as AlignmentType).cn)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(DarkTheme.backgroundSecondary)
          .borderRadius(12)

        // 类型
        Text(getCreatureTypeName(this.creature?.type as CreatureType).cn)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(DarkTheme.backgroundSecondary)
          .borderRadius(12)
      }
      .width('100%')

      // 简介
      Text(this.creature?.description)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TabContent() {
    Column({ space: 16 }) {
      // Tab标签
      Row({ space: 0 }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? DarkTheme.accent : DarkTheme.textSecondary)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)

            if (this.currentTab === index) {
              Column()
                .width(24)
                .height(2)
                .backgroundColor(DarkTheme.accent)
                .borderRadius(1)
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 8 })
          .onClick(() => {
            this.currentTab = index;
          })
        })
      }
      .width('100%')
      .backgroundColor(DarkTheme.backgroundCard)
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 24 })

      // Tab内容
      Column() {
        if (this.currentTab === 0) {
          this.MythologyContent()
        } else if (this.currentTab === 1) {
          this.AbilitiesContent()
        } else {
          this.SymbolismContent()
        }
      }
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  MythologyContent() {
    Column({ space: 12 }) {
      // 标题行：标题文字 + 语音播放按钮
      Row() {
        Text('神话传说')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        // 语音播放按钮
        Column() {
          SymbolGlyph($r('sys.symbol.speaker_wave_3'))
            .fontSize(20)
            .fontColor(['#D4AF37'])
            .symbolEffect(
              new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE),
              this.isTTSPlaying
            )
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#1A2233')
        .borderRadius(18)
        .border({ width: 1, color: '#333' })
        .onClick(() => this.toggleTTS())
      }
      .width('100%')

      Text(this.creature?.mythology || '暂无神话传说记载')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AbilitiesContent() {
    Column({ space: 12 }) {
      // 标题行：标题文字 + 语音播放按钮
      Row() {
        Text('能力特点')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        // 语音播放按钮
        Column() {
          SymbolGlyph($r('sys.symbol.speaker_wave_3'))
            .fontSize(20)
            .fontColor(['#D4AF37'])
            .symbolEffect(
              new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE),
              this.isTTSPlaying
            )
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#1A2233')
        .borderRadius(18)
        .border({ width: 1, color: '#333' })
        .onClick(() => this.toggleTTS())
      }
      .width('100%')

      if (this.creature?.abilities && this.creature.abilities.length > 0) {
        ForEach(this.creature.abilities, (ability: string, index: number) => {
          Row({ space: 8 }) {
            Circle()
              .width(6)
              .height(6)
              .fill(DarkTheme.accent)

            Text(ability)
              .fontSize(14)
              .fontColor(DarkTheme.textSecondary)
          }
          .width('100%')
        })
      } else {
        Text('暂无能力记载')
          .fontSize(14)
          .fontColor(DarkTheme.textTertiary)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SymbolismContent() {
    Column({ space: 12 }) {
      // 标题行：标题文字 + 语音播放按钮
      Row() {
        Text('文化象征')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        // 语音播放按钮
        Column() {
          SymbolGlyph($r('sys.symbol.speaker_wave_3'))
            .fontSize(20)
            .fontColor(['#D4AF37'])
            .symbolEffect(
              new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE),
              this.isTTSPlaying
            )
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#1A2233')
        .borderRadius(18)
        .border({ width: 1, color: '#333' })
        .onClick(() => this.toggleTTS())
      }
      .width('100%')

      Text(this.creature?.symbolism || '暂无象征意义记载')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RelatedCreatures() {
    Column({ space: 12 }) {
      Text('相关神兽')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .padding({ left: 16 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.relatedCreatures, (creature: MythicalCreature) => {
            Column() {
              Image($r(`app.media.${creature.image}`))
                .width(100)
                .height(100)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)

              Text(creature.name.cn)
                .fontSize(12)
                .fontColor(DarkTheme.textPrimary)
                .margin({ top: 6 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(100)
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/CreatureDetail',
                params: { creatureId: creature.id }
              });
            })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .margin({ top: 24 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DarkTheme.accent)

      Text('加载中...')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorView() {
    Column() {
      Image($r('app.media.ic_search'))
        .width(64)
        .height(64)

      Text('神兽未找到')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Button('返回')
        .fontSize(14)
        .fontColor('#ffffff')
        .backgroundColor(DarkTheme.accent)
        .margin({ top: 24 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
