/**
 * 神话志 - 神兽卡片组件
 */

import { MythicalCreature } from '../model/MythicalCreature';
import { AttributeType, RarityType, CultureType,
  getAttributeColor, getRarityColor, getRarityName, getCultureName, ColorPair, RarityInfo, CultureNameInfo } from '../common/Constants';
import { DarkTheme, CardStyle } from '../common/Theme';

@Component
export struct CreatureCard {
  @Prop creature: MythicalCreature;
  @Prop mode: string = 'grid';
  onItemClick?: (creature: MythicalCreature) => void;

  build() {
    Column() {
      if (this.mode === 'grid') {
        this.GridCard()
      } else {
        this.ListCard()
      }
    }
    .width(this.mode === 'grid' ? '100%' : '100%')
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
    .clip(true)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.creature);
      }
    })
  }

  @Builder
  GridCard() {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.TopEnd }) {
        Image($r(`app.media.${this.creature.image}`))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)

        // 稀有度标记
        this.RarityBadgeBuilder()
      }
      .width('100%')
      .height(120)

      // 信息区域
      Column() {
        // 名称
        Text(this.creature.name.cn)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 标签行
        Row({ space: 4 }) {
          // 文化标签
          this.CultureTag()

          // 属性标签
          this.AttributeTagBuilder()
        }
        .width('100%')
        .margin({ top: 4 })
      }
      .width('100%')
      .padding(8)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ListCard() {
    Row() {
      // 图片
      Image($r(`app.media.${this.creature.image}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 信息
      Column() {
        // 名称和稀有度
        Row() {
          Text(this.creature.name.cn)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Blank()

          this.RarityBadgeBuilder()
        }
        .width('100%')

        // 英文名
        Text(this.creature.name.en)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
          .margin({ top: 2 })

        Blank()

        // 标签行
        Row({ space: 6 }) {
          this.CultureTag()
          this.AttributeTagBuilder()
        }
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(96)
    .padding(8)
  }

  @Builder
  RarityBadgeBuilder() {
    Text(getRarityName(this.creature.rarity).cn)
      .fontSize(10)
      .fontColor('#ffffff')
      .backgroundColor(getRarityColor(this.creature.rarity))
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .borderRadius(4)
      .margin(4)
  }

  @Builder
  CultureTag() {
    Row({ space: 2 }) {
      Image($r(`app.media.ic_culture_${this.creature.culture}`))
        .width(12)
        .height(12)
        .clip(true)
        .borderRadius(6)

      Text(getCultureName(this.creature.culture).cn.replace('神话', ''))
        .fontSize(10)
        .fontColor(DarkTheme.textSecondary)
    }
    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
    .backgroundColor(DarkTheme.backgroundSecondary)
    .borderRadius(4)
  }

  @Builder
  AttributeTagBuilder() {
    Row({ space: 2 }) {
      Image($r(`app.media.ic_attr_${this.creature.attributes.primary}`))
        .width(12)
        .height(12)
        .clip(true)
        .borderRadius(6)
    }
    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
    .backgroundColor(getAttributeColor(this.creature.attributes.primary).primary + '33')
    .borderRadius(4)
  }
}
