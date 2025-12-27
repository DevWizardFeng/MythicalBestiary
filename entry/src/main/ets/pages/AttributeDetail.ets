/**
 * 神话志 - 属性详情页
 * 属性特点与相克关系
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { AttributeType, getAttributeColor, getAttributeName, ColorPair, NamePair } from '../common/Constants';
import { Attribute } from '../model/Attribute';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';
import { CreatureCard } from '../components/CreatureCard';

interface RouterParams {
  attributeId: string;
}

@Entry
@Component
struct AttributeDetail {
  @State attribute: Attribute | null = null;
  @State creatures: MythicalCreature[] = [];
  @State isLoading: boolean = true;
  private attributeId: string = '';

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.attributeId) {
      this.attributeId = params.attributeId;
      this.loadData();
    }
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      // 获取属性信息
      const attributes = dataLoader.getAttributes();
      this.attribute = attributes.find((a: Attribute) => a.id === this.attributeId) || null;

      // 获取该属性的神兽
      const allCreatures = dataLoader.getAllCreatures();
      this.creatures = allCreatures
        .filter((c: MythicalCreature) => c.attributes.primary === this.attributeId)
        .slice(0, 10);

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load attribute detail:', error);
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.bg_attribute_detail'))
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

          Text(this.attribute?.nameCn || '属性详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 16 })

          Blank()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.attribute) {
          Scroll() {
            Column({ space: 24 }) {
              // 属性卡片
              this.AttributeCard()

              // 属性含义
              this.MeaningSection()

              // 相克关系
              this.RelationshipSection()

              // 该属性神兽
              if (this.creatures.length > 0) {
                this.CreaturesSection()
              }

              Column()
                .height(32)
            }
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AttributeCard() {
    Column({ space: 16 }) {
      Image($r(`app.media.ic_attr_${this.attribute?.id}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(40)

      Text(this.attribute?.nameCn)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.attribute?.nameEn)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .padding(24)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(16)
    .margin({ left: 16, right: 16 })
  }

  @Builder
  MeaningSection() {
    Column({ space: 12 }) {
      Text('属性含义')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.attribute?.meaning || '暂无描述')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RelationshipSection() {
    Column({ space: 16 }) {
      Text('相克关系')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      // 克制
      if (this.attribute?.strengths && this.attribute.strengths.length > 0) {
        Row({ space: 8 }) {
          Text('克制')
            .fontSize(14)
            .fontColor('#4ade80')
            .width(48)

          ForEach(this.attribute.strengths, (attrId: AttributeType) => {
            Row({ space: 4 }) {
              Image($r(`app.media.ic_attr_${attrId}`))
                .width(16)
                .height(16)
                .clip(true)
                .borderRadius(8)

              Text(getAttributeName(attrId).cn)
                .fontSize(12)
                .fontColor(DarkTheme.textSecondary)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(DarkTheme.backgroundSecondary)
            .borderRadius(12)
          })
        }
        .width('100%')
      }

      // 被克
      if (this.attribute?.weaknesses && this.attribute.weaknesses.length > 0) {
        Row({ space: 8 }) {
          Text('被克')
            .fontSize(14)
            .fontColor('#f87171')
            .width(48)

          ForEach(this.attribute.weaknesses, (attrId: AttributeType) => {
            Row({ space: 4 }) {
              Image($r(`app.media.ic_attr_${attrId}`))
                .width(16)
                .height(16)
                .clip(true)
                .borderRadius(8)

              Text(getAttributeName(attrId).cn)
                .fontSize(12)
                .fontColor(DarkTheme.textSecondary)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(DarkTheme.backgroundSecondary)
            .borderRadius(12)
          })
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .margin({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CreaturesSection() {
    Column({ space: 12 }) {
      Row() {
        Text(`${this.attribute?.nameCn}属性神兽`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Text('查看全部')
          .fontSize(14)
          .fontColor(DarkTheme.accent)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CreatureList',
              params: { filterType: 'attribute', filterValue: this.attributeId }
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Grid() {
        ForEach(this.creatures, (creature: MythicalCreature) => {
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
      .padding({ left: 16, right: 16 })
    }
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
