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
  private creatureId: string = '';

  private tabs: string[] = ['神话传说', '能力特点', '文化象征'];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.creatureId) {
      this.creatureId = params.creatureId;
      this.loadData();
    }
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
    .padding({ left: 16, right: 16, top: 48, bottom: 12 })
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
      Text('神话传说')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

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
      Text('能力特点')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

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
      Text('文化象征')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

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
