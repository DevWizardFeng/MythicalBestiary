/**
 * 神话志 - 文化详情页
 * 文化体系详细介绍
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureSystem } from '../model/CultureSystem';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { CreatureCard } from '../components/CreatureCard';
import { TTSManager, TTSState } from '../utils/TTSManager';
import { promptAction } from '@kit.ArkUI';

interface RouterParams {
  cultureId: string;
}

@Entry
@Component
struct CultureDetail {
  @State culture: CultureSystem | null = null;
  @State deities: Deity[] = [];
  @State creatures: MythicalCreature[] = [];
  @State isLoading: boolean = true;
  @State isTTSPlaying: boolean = false;
  private cultureId: string = '';
  private ttsManager: TTSManager = new TTSManager();

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.cultureId) {
      this.cultureId = params.cultureId;
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

      // 获取文化信息
      const cultures = dataLoader.getCultures();
      this.culture = cultures.find((c: CultureSystem) => c.id === this.cultureId) || null;

      // 获取该文化的主神
      this.deities = dataLoader.getDeitiesByCulture(this.cultureId);

      // 获取该文化的神兽
      const allCreatures = dataLoader.getAllCreatures();
      this.creatures = allCreatures
        .filter((c: MythicalCreature) => c.culture === this.cultureId)
        .slice(0, 10);

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load culture detail:', error);
      this.isLoading = false;
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
    if (!this.culture) return

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
    if (!this.culture) return ''

    const parts: string[] = []

    // 名称
    parts.push(`${this.culture.nameCn}神话体系。`)
    if (this.culture.nameEn) {
      parts.push(`英文名称：${this.culture.nameEn}。`)
    }

    // 文化背景
    if (this.culture.background) {
      parts.push(this.culture.background)
    }

    // 宇宙观
    if (this.culture.cosmology) {
      parts.push(`宇宙观：${this.culture.cosmology}`)
    }

    // 文化特色
    if (this.culture.features && this.culture.features.length > 0) {
      parts.push(`文化特色：${this.culture.features.join('、')}。`)
    }

    return parts.join(' ')
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.bg_culture_detail'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.back();
            })

          Text(this.culture?.nameCn || '文化详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 16 })

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
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(18)
          .onClick(() => this.toggleTTS())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.culture) {
          Scroll() {
            Column({ space: 24 }) {
              // 文化卡片
              this.CultureCard()

              // 文化介绍
              this.DescriptionSection()

              // 宇宙观
              if (this.culture.cosmology) {
                this.CosmologySection()
              }

              // 文化特色
              if (this.culture.features && this.culture.features.length > 0) {
                this.FeaturesSection()
              }

              // 该文化主神（优先展示）
              if (this.deities.length > 0) {
                this.DeitiesSection()
              }

              // 该文化神兽
              if (this.creatures.length > 0) {
                this.CreaturesSection()
              }

              Column()
                .height(32)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CultureCard() {
    Column({ space: 16 }) {
      Image($r(`app.media.ic_culture_${this.culture?.id}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(40)

      Text(this.culture?.nameCn)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.culture?.nameEn)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      Text(this.culture?.region || '')
        .fontSize(12)
        .fontColor(DarkTheme.textTertiary)
    }
    .width('100%')
    .padding(24)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
  }

  @Builder
  DescriptionSection() {
    Column({ space: 12 }) {
      Text('文化简介')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.culture?.background || '暂无描述')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CosmologySection() {
    Column({ space: 12 }) {
      Text('宇宙观')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.culture?.cosmology || '')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  FeaturesSection() {
    Column({ space: 12 }) {
      Text('文化特色')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.culture?.features || [], (feature: string) => {
          Text(feature)
            .fontSize(13)
            .fontColor(DarkTheme.textSecondary)
            .backgroundColor(DarkTheme.backgroundSecondary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
        })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DeitiesSection() {
    Column({ space: 12 }) {
      Row() {
        Text(`${this.culture?.nameCn}主神`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Text('查看全部')
          .fontSize(14)
          .fontColor(DarkTheme.accent)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DeityList',
              params: { culture: this.cultureId }
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 横向滚动展示主神
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.deities, (deity: Deity) => {
            this.DeityCard(deity)
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  DeityCard(deity: Deity) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r(`app.media.${deity.image}`))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        Column()
          .width('100%')
          .height('50%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
          })
      }
      .width(140)
      .height(180)

      Column({ space: 4 }) {
        Text(deity.name.cn)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(deity.domain.slice(0, 2).join(' / '))
          .fontSize(11)
          .fontColor(DarkTheme.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(8)
      .alignItems(HorizontalAlign.Start)
    }
    .width(140)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DeityDetail',
        params: { deityId: deity.id }
      });
    })
  }

  @Builder
  CreaturesSection() {
    Column({ space: 12 }) {
      Row() {
        Text(`${this.culture?.nameCn}神兽`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Text('查看全部')
          .fontSize(14)
          .fontColor(DarkTheme.accent)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CreatureList',
              params: { filterType: 'culture', filterValue: this.cultureId }
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Grid() {
        ForEach(this.creatures, (creature: MythicalCreature) => {
          GridItem() {
            CreatureCard({
              creature: creature,
              mode: 'grid',
              onItemClick: (c: MythicalCreature) => {
                router.pushUrl({
                  url: 'pages/CreatureDetail',
                  params: { creatureId: c.id }
                });
              }
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DarkTheme.accent)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
