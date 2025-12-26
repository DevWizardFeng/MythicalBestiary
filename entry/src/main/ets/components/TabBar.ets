/**
 * 神话志 - 底部导航栏组件
 */

import { DarkTheme } from '../common/Theme';

export interface TabItem {
  icon: Resource;
  iconSelected: Resource;
  label: string;
}

@Component
export struct TabBar {
  @Prop currentIndex: number = 0;
  @Prop tabs: TabItem[];
  onTabChange?: (index: number) => void;

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        Column({ space: 4 }) {
          Image(this.currentIndex === index ? tab.iconSelected : tab.icon)
            .width(24)
            .height(24)

          Text(tab.label)
            .fontSize(10)
            .fontColor(this.currentIndex === index ? DarkTheme.accent : DarkTheme.textSecondary)
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.onTabChange && this.currentIndex !== index) {
            this.onTabChange(index);
          }
        })
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor(DarkTheme.backgroundCard)
    .border({
      width: { top: 1 },
      color: DarkTheme.divider
    })
  }
}
