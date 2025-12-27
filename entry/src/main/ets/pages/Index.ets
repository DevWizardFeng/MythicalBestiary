/**
 * 神话志 - 主入口页面
 * 底部Tabs导航：首页 | 挑战 | 图鉴 | 百科 | 我的
 */

import { DarkTheme } from '../common/Theme';
import { Home } from './Home';
import { ChallengeTab } from '../components/ChallengeTab';
import { GuideTab } from '../components/GuideTab';
import { Encyclopedia } from './Encyclopedia';
import { Mine } from './Mine';
import { StorageUtil } from '../utils/Storage';
import { curves } from '@kit.ArkUI';

interface TabConfig {
  icon: Resource;
  iconSelected: Resource;
  label: string;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State tabScales: number[] = [1, 1, 1, 1, 1];
  @State challengeRefreshKey: number = 0;

  aboutToAppear() {
    // 应用启动时初始化存储，确保全局状态被初始化
    this.initStorage();
  }

  onPageShow() {
    // 页面显示时刷新当前Tab数据（从其他页面返回时触发）
    if (this.currentIndex === 1) {
      // 当前在挑战Tab，刷新数据
      this.challengeRefreshKey++;
    }
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
      icon: $r('app.media.ic_tab_home'),
      iconSelected: $r('app.media.ic_tab_home_selected'),
      label: '首页'
    },
    {
      icon: $r('app.media.ic_tab_challenge'),
      iconSelected: $r('app.media.ic_tab_challenge_selected'),
      label: '挑战'
    },
    {
      icon: $r('app.media.ic_tab_guide'),
      iconSelected: $r('app.media.ic_tab_guide_selected'),
      label: '图鉴'
    },
    {
      icon: $r('app.media.ic_tab_wiki'),
      iconSelected: $r('app.media.ic_tab_wiki_selected'),
      label: '百科'
    },
    {
      icon: $r('app.media.ic_tab_mine'),
      iconSelected: $r('app.media.ic_tab_mine_selected'),
      label: '我的'
    }
  ];

  @Builder
  TabBuilder(index: number) {
    Column({ space: 4 }) {
      Image(this.currentIndex === index ? this.tabs[index].iconSelected : this.tabs[index].icon)
        .width(24)
        .height(24)
        .scale({ x: this.tabScales[index], y: this.tabScales[index] })

      Text(this.tabs[index].label)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? DarkTheme.accent : DarkTheme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 触发Tab图标跳动动画
  private animateTabBounce(index: number) {
    // 先缩小
    this.getUIContext()?.animateTo({
      duration: 100,
      curve: Curve.EaseOut
    }, () => {
      this.tabScales[index] = 0.8;
    });

    // 然后放大回弹
    setTimeout(() => {
      this.getUIContext()?.animateTo({
        curve: curves.springMotion(0.3, 0.6)
      }, () => {
        this.tabScales[index] = 1;
      });
    }, 100);
  }

  build() {
    Stack() {
      // 背景图层
      Image($r('app.media.bg_main_mystical'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 内容层
      Column() {
        Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
          TabContent() {
            Home()
          }
          .tabBar(this.TabBuilder(0))

          TabContent() {
            ChallengeTab({ refreshKey: this.challengeRefreshKey })
          }
          .tabBar(this.TabBuilder(1))

          TabContent() {
            GuideTab()
          }
          .tabBar(this.TabBuilder(2))

          TabContent() {
            Encyclopedia()
          }
          .tabBar(this.TabBuilder(3))

          TabContent() {
            Mine()
          }
          .tabBar(this.TabBuilder(4))
        }
        .width('100%')
        .height('100%')
        .barHeight(56)
        .barBackgroundColor('rgba(30, 30, 60, 0.85)')
        .onChange((index: number) => {
          this.animateTabBounce(index);
          this.currentIndex = index;
          // 切换到挑战Tab时刷新数据
          if (index === 1) {
            this.challengeRefreshKey++;
          }
        })
        .scrollable(false)
        .animationDuration(0)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
