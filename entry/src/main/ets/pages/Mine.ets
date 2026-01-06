/**
 * 神话志 - 我的页面
 * 个人中心、收藏、历史、设置
 */

import router from '@ohos.router';
import { DarkTheme, CardStyle } from '../common/Theme';
import { GlobalStateKeys } from '../common/Constants';
import { StorageUtil } from '../utils/Storage';
import { UserSettings } from '../model/UserData';

interface MenuItem {
  icon: Resource;
  title: string;
  subtitle: string;
  route: string;
  badge?: number;
}

@Component
export struct Mine {
  // 使用 @StorageLink 绑定全局状态，实现数据同步
  @StorageLink('globalFavoriteCount') favoriteCount: number = 0;
  @StorageLink('globalHistoryCount') historyCount: number = 0;
  @State settings: UserSettings | null = null;

  aboutToAppear() {
    this.initData();
  }

  async initData() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      this.settings = await storage.getSettings();
    } catch (error) {
      console.error('Failed to load user data:', error);
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Image($r('app.media.ic_search'))
          .width(24)
          .height(24)
          .visibility(Visibility.Hidden)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Scroll() {
        Column({ space: 16 }) {
          // 用户卡片
          this.UserCard()

          // 功能入口
          Column({ space: 1 }) {
            // 我的收藏 - 直接使用 this.favoriteCount，确保 @StorageLink 变化时触发更新
            Row() {
              Image($r('app.media.ic_favorite_filled'))
                .width(24)
                .height(24)
                .clip(true)
                .borderRadius(12)

              Column({ space: 2 }) {
                Text('我的收藏')
                  .fontSize(16)
                  .fontColor(DarkTheme.textPrimary)

                Text(`已收藏 ${this.favoriteCount} 项`)
                  .fontSize(12)
                  .fontColor(DarkTheme.textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })

              Blank()

              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
            }
            .width('100%')
            .padding(16)
            .onClick(() => {
              router.pushUrl({ url: 'pages/Favorites' });
            })

            // 浏览历史 - 直接使用 this.historyCount，确保 @StorageLink 变化时触发更新
            Row() {
              Image($r('app.media.ic_browse'))
                .width(24)
                .height(24)
                .clip(true)
                .borderRadius(12)

              Column({ space: 2 }) {
                Text('浏览历史')
                  .fontSize(16)
                  .fontColor(DarkTheme.textPrimary)

                Text(`已浏览 ${this.historyCount} 项`)
                  .fontSize(12)
                  .fontColor(DarkTheme.textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })

              Blank()

              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
            }
            .width('100%')
            .padding(16)
            .onClick(() => {
              router.pushUrl({ url: 'pages/History' });
            })
          }
          .backgroundColor(CardStyle.glassBackground)
          .borderRadius(CardStyle.borderRadius)
          .border({
            width: CardStyle.borderWidth,
            color: CardStyle.borderColor
          })
          .shadow({
            radius: CardStyle.shadowRadius,
            color: CardStyle.shadowColor,
            offsetX: CardStyle.shadowOffsetX,
            offsetY: CardStyle.shadowOffsetY
          })
          .margin({ left: 16, right: 16 })

          // 互动功能
          Column({ space: 1 }) {
            this.MenuItem({
              icon: $r('app.media.ic_attr_light'),
              title: '每日占卜',
              subtitle: '测测今日守护',
              route: 'pages/DailyDivination'
            })

            this.MenuItem({
              icon: $r('app.media.ic_star'),
              title: '守护神祇测试',
              subtitle: '发现你的守护神祇',
              route: 'pages/DeityTest'
            })

            this.MenuItem({
              icon: $r('app.media.ic_attr_fire'),
              title: '属性测试',
              subtitle: '发现你的神兽属性',
              route: 'pages/AttributeTest'
            })
          }
          .backgroundColor(CardStyle.glassBackground)
          .borderRadius(CardStyle.borderRadius)
          .border({
            width: CardStyle.borderWidth,
            color: CardStyle.borderColor
          })
          .shadow({
            radius: CardStyle.shadowRadius,
            color: CardStyle.shadowColor,
            offsetX: CardStyle.shadowOffsetX,
            offsetY: CardStyle.shadowOffsetY
          })
          .margin({ left: 16, right: 16 })

          // 设置
          Column({ space: 1 }) {
            this.MenuItem({
              icon: $r('app.media.ic_encyclopedia'),
              title: '设置',
              subtitle: '主题、缓存等',
              route: 'pages/Settings'
            })
          }
          .backgroundColor(CardStyle.glassBackground)
          .borderRadius(CardStyle.borderRadius)
          .border({
            width: CardStyle.borderWidth,
            color: CardStyle.borderColor
          })
          .shadow({
            radius: CardStyle.shadowRadius,
            color: CardStyle.shadowColor,
            offsetX: CardStyle.shadowOffsetX,
            offsetY: CardStyle.shadowOffsetY
          })
          .margin({ left: 16, right: 16 })

          // 关于
          Column() {
            Text('神话志 v1.0.6')
              .fontSize(12)
              .fontColor(DarkTheme.textTertiary)

            Text('探索神话世界的奇妙生物与神祇')
              .fontSize(12)
              .fontColor(DarkTheme.textTertiary)
              .margin({ top: 4 })
          }
          .width('100%')
          .padding({ top: 24, bottom: 24 })

          // 底部占位
          Column()
            .height(20)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  UserCard() {
    Row() {
      // 头像
      Image($r('app.media.ic_culture_chinese'))
        .width(64)
        .height(64)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(32)

      Column({ space: 4 }) {
        Text('神话探索者')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Text('开启神话探索之旅')
          .fontSize(14)
          .fontColor(DarkTheme.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })

      Blank()

      // 统计数据 - 直接访问 this.状态变量，确保 @StorageLink 变化时触发更新
      Row({ space: 24 }) {
        // 收藏统计 - 直接使用 this.favoriteCount
        Column({ space: 4 }) {
          Text(this.favoriteCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.accent)

          Text('收藏')
            .fontSize(12)
            .fontColor(DarkTheme.textSecondary)
        }

        // 浏览统计 - 直接使用 this.historyCount
        Column({ space: 4 }) {
          Text(this.historyCount.toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.accent)

          Text('浏览')
            .fontSize(12)
            .fontColor(DarkTheme.textSecondary)
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .shadow({
      radius: CardStyle.shadowRadius,
      color: CardStyle.shadowColor,
      offsetX: CardStyle.shadowOffsetX,
      offsetY: CardStyle.shadowOffsetY
    })
    .margin({ left: 16, right: 16 })
  }

  @Builder
  StatItem(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.accent)

      Text(label)
        .fontSize(12)
        .fontColor(DarkTheme.textSecondary)
    }
  }

  @Builder
  MenuItem(item: MenuItem) {
    Row() {
      Image(item.icon)
        .width(24)
        .height(24)
        .clip(true)
        .borderRadius(12)

      Column({ space: 2 }) {
        Text(item.title)
          .fontSize(16)
          .fontColor(DarkTheme.textPrimary)

        Text(item.subtitle)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Blank()

      if (item.badge && item.badge > 0) {
        Text(item.badge.toString())
          .fontSize(12)
          .fontColor('#ffffff')
          .backgroundColor(DarkTheme.accent)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
          .margin({ right: 8 })
      }

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      router.pushUrl({ url: item.route });
    })
  }
}
