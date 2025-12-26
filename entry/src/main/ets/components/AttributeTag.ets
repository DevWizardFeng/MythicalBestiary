/**
 * 神话志 - 属性标签组件
 */

import { AttributeType, getAttributeColor, getAttributeName, ColorPair, NamePair } from '../common/Constants';
import { DarkTheme } from '../common/Theme';

@Component
export struct AttributeTag {
  @Prop attribute: AttributeType = 'fire';
  @Prop showText: boolean = true;
  @Prop tagSize: 'small' | 'medium' | 'large' = 'medium';

  build() {
    Row({ space: this.getSpacing() }) {
      Image($r(`app.media.ic_attr_${this.attribute}`))
        .width(this.getIconSize())
        .height(this.getIconSize())
        .clip(true)
        .borderRadius(this.getIconSize() / 2)

      if (this.showText) {
        Text(this.getName().cn)
          .fontSize(this.getFontSize())
          .fontColor(this.getColor().primary)
      }
    }
    .padding({
      left: this.getPadding(),
      right: this.getPadding(),
      top: this.getPadding() / 2,
      bottom: this.getPadding() / 2
    })
    .backgroundColor(this.getColor().primary + '22')
    .borderRadius(this.getBorderRadius())
    .border({
      width: 1,
      color: this.getColor().primary + '44'
    })
  }

  private getColor(): ColorPair {
    return getAttributeColor(this.attribute);
  }

  private getName(): NamePair {
    return getAttributeName(this.attribute);
  }

  private getIconSize(): number {
    if (this.tagSize === 'small') {
      return 12;
    } else if (this.tagSize === 'medium') {
      return 16;
    } else {
      return 20;
    }
  }

  private getFontSize(): number {
    if (this.tagSize === 'small') {
      return 10;
    } else if (this.tagSize === 'medium') {
      return 12;
    } else {
      return 14;
    }
  }

  private getSpacing(): number {
    if (this.tagSize === 'small') {
      return 2;
    } else if (this.tagSize === 'medium') {
      return 4;
    } else {
      return 6;
    }
  }

  private getPadding(): number {
    if (this.tagSize === 'small') {
      return 4;
    } else if (this.tagSize === 'medium') {
      return 8;
    } else {
      return 12;
    }
  }

  private getBorderRadius(): number {
    if (this.tagSize === 'small') {
      return 4;
    } else if (this.tagSize === 'medium') {
      return 6;
    } else {
      return 8;
    }
  }
}

/**
 * 属性标签列表组件
 */
@Component
export struct AttributeTagList {
  @Prop attributes: AttributeType[] = [];
  @Prop tagSize: 'small' | 'medium' | 'large' = 'medium';

  build() {
    Row({ space: 8 }) {
      ForEach(this.attributes, (attr: AttributeType) => {
        AttributeTag({
          attribute: attr,
          tagSize: this.tagSize
        })
      })
    }
  }
}
