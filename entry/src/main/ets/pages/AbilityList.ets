/**
 * 神话志 - 能力词典页
 * 展示所有神兽能力
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { Ability } from '../model/Ability';
import { DataLoader } from '../utils/DataLoader';

@Entry
@Component
struct AbilityList {
  @State abilities: Ability[] = [];
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.abilities = dataLoader.getAbilities();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load abilities:', error);
      this.isLoading = false;
    }
  }

  getFilteredAbilities(): Ability[] {
    if (this.searchKeyword.length === 0) {
      return this.abilities;
    }
    const keyword = this.searchKeyword.toLowerCase();
    return this.abilities.filter((a: Ability) =>
      a.nameCn.toLowerCase().includes(keyword) ||
      a.nameEn.toLowerCase().includes(keyword) ||
      a.description.toLowerCase().includes(keyword)
    );
  }

  getCategoryName(category: string): string {
    const names: Record<string, string> = {
      'offensive': '攻击型',
      'defensive': '防御型',
      'support': '辅助型',
      'special': '特殊型'
    };
    return names[category] || category;
  }

  getCategoryColor(category: string): string {
    const colors: Record<string, string> = {
      'offensive': '#ef4444',
      'defensive': '#3b82f6',
      'support': '#22c55e',
      'special': '#a855f7'
    };
    return colors[category] || DarkTheme.accent;
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

        Text('能力词典')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .margin({ left: 16 })

        Blank()

        Text(`${this.abilities.length}个`)
          .fontSize(14)
          .fontColor(DarkTheme.textSecondary)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 搜索栏
      Row({ space: 8 }) {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)

        TextInput({ text: this.searchKeyword, placeholder: '搜索能力...' })
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .placeholderColor(DarkTheme.textTertiary)
          .backgroundColor('transparent')
          .layoutWeight(1)
          .height('100%')
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
      }
      .width('100%')
      .height(40)
      .padding({ left: 12, right: 12 })
      .margin({ left: 16, right: 16, bottom: 12 })
      .backgroundColor(DarkTheme.backgroundSecondary)
      .borderRadius(20)

      if (this.isLoading) {
        this.LoadingView()
      } else {
        List() {
          ForEach(this.getFilteredAbilities(), (ability: Ability) => {
            ListItem() {
              this.AbilityItem(ability)
            }
            .padding({ left: 16, right: 16, bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  AbilityItem(ability: Ability) {
    Column({ space: 8 }) {
      Row() {
        Text(ability.nameCn)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Text(this.getCategoryName(ability.category))
          .fontSize(12)
          .fontColor(this.getCategoryColor(ability.category))
          .backgroundColor(this.getCategoryColor(ability.category) + '22')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
      }
      .width('100%')

      Text(ability.nameEn)
        .fontSize(12)
        .fontColor(DarkTheme.textTertiary)
        .width('100%')

      Text(ability.description)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
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
