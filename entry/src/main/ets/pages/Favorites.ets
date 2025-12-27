/**
 * 神话志 - 收藏页面
 * 用户收藏的神兽和神祇列表
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { CreatureCard } from '../components/CreatureCard';

@Entry
@Component
struct Favorites {
  @State currentTab: 'creature' | 'deity' = 'creature';
  @State favoriteCreatures: MythicalCreature[] = [];
  @State favoriteDeities: Deity[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  onPageShow() {
    // 返回页面时刷新收藏数据
    this.loadData();
  }

  async loadData() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      const creatureIds = await storage.getFavorites();
      const deityIds = await storage.getDeityFavorites();

      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();
      const allDeities = dataLoader.getAllDeities();

      this.favoriteCreatures = allCreatures.filter(c => creatureIds.includes(c.id));
      this.favoriteDeities = allDeities.filter(d => deityIds.includes(d.id));
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load favorites:', error);
      this.isLoading = false;
    }
  }

  getTotalCount(): number {
    return this.favoriteCreatures.length + this.favoriteDeities.length;
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.bg_favorites'))
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

          Text('我的收藏')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 16 })

          Blank()

          Text(`${this.getTotalCount()}项`)
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // Tab切换
        Row({ space: 0 }) {
          this.TabItem('神兽', 'creature')
          this.TabItem('神祇', 'deity')
        }
        .width('100%')
        .height(44)
        .backgroundColor(DarkTheme.backgroundCard)

        if (this.isLoading) {
          this.LoadingView()
        } else {
          if (this.currentTab === 'creature') {
            this.CreatureContent()
          } else {
            this.DeityContent()
          }
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabItem(title: string, tab: 'creature' | 'deity') {
    Column() {
      Row({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontWeight(this.currentTab === tab ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === tab ? DarkTheme.accent : DarkTheme.textSecondary)

        Text(`(${tab === 'creature' ? this.favoriteCreatures.length : this.favoriteDeities.length})`)
          .fontSize(12)
          .fontColor(this.currentTab === tab ? DarkTheme.accent : DarkTheme.textTertiary)
      }

      if (this.currentTab === tab) {
        Column()
          .width(24)
          .height(3)
          .backgroundColor(DarkTheme.accent)
          .borderRadius(2)
          .margin({ top: 6 })
      }
    }
    .width('50%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = tab;
    })
  }

  @Builder
  CreatureContent() {
    if (this.favoriteCreatures.length === 0) {
      this.EmptyView('暂无收藏的神兽', '去发现感兴趣的神兽吧')
    } else {
      Grid() {
        ForEach(this.favoriteCreatures, (creature: MythicalCreature) => {
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
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .layoutWeight(1)
    }
  }

  @Builder
  DeityContent() {
    if (this.favoriteDeities.length === 0) {
      this.EmptyView('暂无收藏的神祇', '去发现感兴趣的神祇吧')
    } else {
      Grid() {
        ForEach(this.favoriteDeities, (deity: Deity) => {
          GridItem() {
            this.DeityCard(deity)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .layoutWeight(1)
    }
  }

  @Builder
  DeityCard(deity: Deity) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r(`app.media.${deity.image}`))
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 渐变遮罩
        Column()
          .width('100%')
          .height('50%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['rgba(0,0,0,0.6)', 0], ['rgba(0,0,0,0)', 1]]
          })

        // 文化标签
        Text(getCultureName(deity.culture as CultureType).cn)
          .fontSize(10)
          .fontColor('#ffffff')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(getCultureColor(deity.culture as CultureType))
          .borderRadius(8)
          .position({ x: 8, y: 8 })
      }
      .width('100%')
      .height(140)

      Column({ space: 4 }) {
        Text(deity.name.cn)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 4 }) {
          ForEach(deity.domain.slice(0, 2), (domain: string, index: number) => {
            Text(domain)
              .fontSize(10)
              .fontColor(DarkTheme.accent)
              .backgroundColor(DarkTheme.accent + '22')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }, (domain: string, index: number) => `${deity.id}_fav_${index}`)
        }
      }
      .padding(8)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
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

  @Builder
  EmptyView(title: string, subtitle: string) {
    Column() {
      Image($r('app.media.ic_favorite'))
        .width(64)
        .height(64)

      Text(title)
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Text(subtitle)
        .fontSize(14)
        .fontColor(DarkTheme.textTertiary)
        .margin({ top: 8 })

      Button('去探索')
        .fontSize(14)
        .fontColor('#ffffff')
        .backgroundColor(DarkTheme.accent)
        .margin({ top: 24 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
