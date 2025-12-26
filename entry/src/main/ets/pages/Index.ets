/**
 * 神话志 - 主入口页面
 * 底部Tabs导航：首页 | 图鉴 | 百科 | 我的
 */

import { DarkTheme } from '../common/Theme';
import { Home } from './Home';
import { GuideTab } from '../components/GuideTab';
import { Encyclopedia } from './Encyclopedia';
import { Mine } from './Mine';
import { StorageUtil } from '../utils/Storage';

interface TabConfig {
  icon: Resource;
  iconSelected: Resource;
  label: string;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  aboutToAppear() {
    // 应用启动时初始化存储，确保全局状态被初始化
    this.initStorage();
  }

  async initStorage() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
    } catch (e) {
      console.error('Failed to initialize storage');
    }
  }

  private tabs: TabConfig[] = [
    {
      icon: $r('app.media.ic_home'),
      iconSelected: $r('app.media.ic_home_selected'),
      label: '首页'
    },
    {
      icon: $r('app.media.ic_browse'),
      iconSelected: $r('app.media.ic_browse_selected'),
      label: '图鉴'
    },
    {
      icon: $r('app.media.ic_encyclopedia'),
      iconSelected: $r('app.media.ic_encyclopedia_selected'),
      label: '百科'
    },
    {
      icon: $r('app.media.ic_mine'),
      iconSelected: $r('app.media.ic_mine_selected'),
      label: '我的'
    }
  ];

  @Builder
  TabBuilder(index: number) {
    Column({ space: 4 }) {
      Image(this.currentIndex === index ? this.tabs[index].iconSelected : this.tabs[index].icon)
        .width(24)
        .height(24)

      Text(this.tabs[index].label)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? DarkTheme.accent : DarkTheme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          Home()
        }
        .tabBar(this.TabBuilder(0))

        TabContent() {
          GuideTab()
        }
        .tabBar(this.TabBuilder(1))

        TabContent() {
          Encyclopedia()
        }
        .tabBar(this.TabBuilder(2))

        TabContent() {
          Mine()
        }
        .tabBar(this.TabBuilder(3))
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .barBackgroundColor(DarkTheme.backgroundCard)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .scrollable(false)
      .animationDuration(0)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }
}
