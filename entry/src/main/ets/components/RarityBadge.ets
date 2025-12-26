/**
 * 神话志 - 稀有度徽章组件
 */

import { RarityType, getRarityColor, getRarityName, RarityInfo } from '../common/Constants';

@Component
export struct RarityBadge {
  @Prop rarity: RarityType = 'common';
  @Prop showStars: boolean = false;
  @Prop badgeSize: 'small' | 'medium' | 'large' = 'medium';

  build() {
    Row({ space: this.getSpacing() }) {
      if (this.showStars) {
        this.Stars()
      } else {
        Text(this.getRarityInfo().cn)
          .fontSize(this.getFontSize())
          .fontColor('#ffffff')
          .fontWeight(FontWeight.Medium)
      }
    }
    .padding({
      left: this.getPadding(),
      right: this.getPadding(),
      top: this.getPadding() / 2,
      bottom: this.getPadding() / 2
    })
    .backgroundColor(getRarityColor(this.rarity))
    .borderRadius(this.getBorderRadius())
  }

  @Builder
  Stars() {
    Row({ space: 1 }) {
      ForEach(this.getStarsArray(), (_: number, index: number) => {
        Image($r('app.media.ic_rarity_' + this.rarity))
          .width(this.getStarSize())
          .height(this.getStarSize())
      })
    }
  }

  private getRarityInfo(): RarityInfo {
    return getRarityName(this.rarity);
  }

  private getStarsArray(): number[] {
    const count = this.getRarityInfo().stars;
    const arr: number[] = [];
    for (let i = 0; i < count; i++) {
      arr.push(i);
    }
    return arr;
  }

  private getFontSize(): number {
    if (this.badgeSize === 'small') {
      return 10;
    } else if (this.badgeSize === 'medium') {
      return 12;
    } else {
      return 14;
    }
  }

  private getSpacing(): number {
    if (this.badgeSize === 'small') {
      return 1;
    } else if (this.badgeSize === 'medium') {
      return 2;
    } else {
      return 3;
    }
  }

  private getPadding(): number {
    if (this.badgeSize === 'small') {
      return 4;
    } else if (this.badgeSize === 'medium') {
      return 8;
    } else {
      return 12;
    }
  }

  private getBorderRadius(): number {
    if (this.badgeSize === 'small') {
      return 4;
    } else if (this.badgeSize === 'medium') {
      return 6;
    } else {
      return 8;
    }
  }

  private getStarSize(): number {
    if (this.badgeSize === 'small') {
      return 8;
    } else if (this.badgeSize === 'medium') {
      return 10;
    } else {
      return 12;
    }
  }
}
