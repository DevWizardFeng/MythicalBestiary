/**
 * 神话志 - 百科主页
 * 属性元素、文化体系、能力词典
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { AttributeType, CultureType, AttributeNames, AttributeColors, CultureNames } from '../common/Constants';
import { DataLoader } from '../utils/DataLoader';
import { Attribute } from '../model/Attribute';
import { CultureSystem } from '../model/CultureSystem';

interface CategoryItem {
  id: string;
  title: string;
  subtitle: string;
  icon: Resource;
  color: string;
  route: string;
}

@Component
export struct Encyclopedia {
  @State attributes: Attribute[] = [];
  @State cultures: CultureSystem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.attributes = dataLoader.getAttributes();
      this.cultures = dataLoader.getCultures();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load encyclopedia data:', error);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('神话百科')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column({ space: 24 }) {
            // 元素属性
            Column({ space: 12 }) {
              this.SectionHeader('元素属性', '了解神兽的属性特点与相克关系')

              Grid() {
                ForEach(this.attributes, (attr: Attribute) => {
                  GridItem() {
                    this.AttributeItem(attr)
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .rowsGap(12)
              .columnsGap(12)
              .width('100%')
              .height(180)
              .padding({ left: 16, right: 16 })
            }

            // 文化体系
            Column({ space: 12 }) {
              this.SectionHeader('文化体系', '探索不同文明的神话传说')

              Column({ space: 12 }) {
                ForEach(this.cultures, (culture: CultureSystem) => {
                  this.CultureItem(culture)
                })
              }
              .padding({ left: 16, right: 16 })
            }

            // 神祇图鉴入口
            Column({ space: 12 }) {
              this.SectionHeader('神祇图鉴', '各大文明的至高神祇')

              Row() {
                Image($r('app.media.ic_star'))
                  .width(48)
                  .height(48)
                  .objectFit(ImageFit.Contain)
                  .clip(true)
                  .borderRadius(24)

                Column({ space: 4 }) {
                  Text('查看全部神祇')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(DarkTheme.textPrimary)

                  Text('了解各大文明的主神与神族关系')
                    .fontSize(12)
                    .fontColor(DarkTheme.textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                Blank()

                Image($r('app.media.ic_back'))
                  .width(20)
                  .height(20)
                  .rotate({ angle: 180 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(DarkTheme.backgroundCard)
              .borderRadius(12)
              .margin({ left: 16, right: 16 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/DeityList' });
              })
            }

            // 能力词典入口
            Column({ space: 12 }) {
              this.SectionHeader('能力词典', '神兽的各种神奇能力')

              Row() {
                Column({ space: 4 }) {
                  Text('查看全部能力')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(DarkTheme.textPrimary)

                  Text('了解神兽拥有的各种神奇力量')
                    .fontSize(12)
                    .fontColor(DarkTheme.textSecondary)
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Image($r('app.media.ic_back'))
                  .width(20)
                  .height(20)
                  .rotate({ angle: 180 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(DarkTheme.backgroundCard)
              .borderRadius(12)
              .margin({ left: 16, right: 16 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/AbilityList' });
              })
            }

            // 底部占位
            Column()
              .height(20)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  SectionHeader(title: string, subtitle: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(subtitle)
        .fontSize(12)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16 })
  }

  @Builder
  AttributeItem(attr: Attribute) {
    Column({ space: 8 }) {
      Image($r(`app.media.ic_attr_${attr.id}`))
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(20)

      Text(attr.nameCn)
        .fontSize(12)
        .fontColor(DarkTheme.textPrimary)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/AttributeDetail',
        params: { attributeId: attr.id }
      });
    })
  }

  @Builder
  CultureItem(culture: CultureSystem) {
    Row() {
      Image($r(`app.media.ic_culture_${culture.id}`))
        .width(48)
        .height(48)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(24)

      Column({ space: 4 }) {
        Text(culture.nameCn)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(DarkTheme.textPrimary)

        Text(culture.background || '')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Image($r('app.media.ic_back'))
        .width(16)
        .height(16)
        .rotate({ angle: 180 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/CultureDetail',
        params: { cultureId: culture.id }
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

      Text('加载中...')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
