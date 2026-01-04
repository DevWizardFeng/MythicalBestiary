/**
 * 神话志 - 设置页面
 * 数据管理等设置
 */

import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { DarkTheme } from '../common/Theme';
import { StorageUtil } from '../utils/Storage';

@Entry
@Component
struct Settings {
  async clearAllFavorites() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      await storage.clearAllFavorites();
      promptAction.showToast({
        message: '收藏已全部清空',
        duration: 2000
      });
    } catch (error) {
      console.error('Failed to clear favorites:', error);
      promptAction.showToast({
        message: '清除失败',
        duration: 2000
      });
    }
  }

  async clearBrowsingHistory() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      await storage.clearBrowsingHistory();
      promptAction.showToast({
        message: '浏览记录已清除',
        duration: 2000
      });
    } catch (error) {
      console.error('Failed to clear browsing history:', error);
      promptAction.showToast({
        message: '清除失败',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      Scroll() {
        Column({ space: 16 }) {
          // 数据管理
          Column({ space: 1 }) {
            this.SectionHeader('数据管理')

            this.ActionItem('清空所有收藏', '清除全部神兽和神祇收藏', () => {
              this.clearAllFavorites();
            })

            this.ActionItem('清除浏览记录', '清空所有浏览历史', () => {
              this.clearBrowsingHistory();
            })
          }
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 关于
          Column({ space: 1 }) {
            this.SectionHeader('关于')

            this.InfoItem('版本', 'v1.0.4')
            this.InfoItem('开发者', '个人开发：罗顺枫')
          }
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          Column()
            .height(32)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor(DarkTheme.textTertiary)
      .padding({ left: 16, top: 12, bottom: 8 })
      .width('100%')
  }

  @Builder
  ActionItem(title: string, subtitle: string, action: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(16)
          .fontColor(DarkTheme.textPrimary)

        Text(subtitle)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .padding(16)
    .onClick(() => {
      action();
    })
  }

  @Builder
  InfoItem(title: string, value: string) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)

      Blank()

      Text(value)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .padding(16)
  }
}
