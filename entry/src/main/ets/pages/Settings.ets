/**
 * 神话志 - 设置页面
 * 主题、缓存等设置
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { StorageUtil } from '../utils/Storage';
import { UserSettings } from '../model/UserData';

interface SettingItem {
  title: string;
  subtitle: string;
  hasToggle?: boolean;
  toggleValue?: boolean;
  hasArrow?: boolean;
  action?: () => void;
}

@Entry
@Component
struct Settings {
  @State settings: UserSettings = {
    theme: 'dark',
    autoPlayBanner: true,
    showEnglishName: true,
    cacheEnabled: true
  };

  aboutToAppear() {
    this.loadSettings();
  }

  async loadSettings() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      const savedSettings = await storage.getSettings();
      if (savedSettings) {
        this.settings = savedSettings;
      }
    } catch (error) {
      console.error('Failed to load settings:', error);
    }
  }

  async saveSettings() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.saveSettings(this.settings);
    } catch (error) {
      console.error('Failed to save settings:', error);
    }
  }

  async clearCache() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.clearBrowsingHistory();
      await storage.clearSearchHistory();
      // 简单提示
      console.info('Cache cleared');
    } catch (error) {
      console.error('Failed to clear cache:', error);
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
          // 显示设置
          Column({ space: 1 }) {
            this.SectionHeader('显示设置')

            this.ToggleItem('自动播放轮播', '首页轮播图自动切换', this.settings.autoPlayBanner, (value: boolean) => {
              this.settings.autoPlayBanner = value;
              this.saveSettings();
            })

            this.ToggleItem('显示英文名', '在列表中显示神兽英文名', this.settings.showEnglishName, (value: boolean) => {
              this.settings.showEnglishName = value;
              this.saveSettings();
            })
          }
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 数据管理
          Column({ space: 1 }) {
            this.SectionHeader('数据管理')

            this.ActionItem('清除浏览记录', '清空所有浏览历史', () => {
              this.clearCache();
            })

            this.ActionItem('清除搜索记录', '清空所有搜索历史', async () => {
              const storage = StorageUtil.getInstance();
              await storage.clearSearchHistory();
            })
          }
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 关于
          Column({ space: 1 }) {
            this.SectionHeader('关于')

            this.InfoItem('版本', 'v1.0.0')
            this.InfoItem('开发者', '神话志团队')
          }
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          Column()
            .height(32)
        }
        .padding({ top: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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
  ToggleItem(title: string, subtitle: string, value: boolean, onChange: (value: boolean) => void) {
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

      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor(DarkTheme.accent)
        .onChange((isOn: boolean) => {
          onChange(isOn);
        })
    }
    .width('100%')
    .padding(16)
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
