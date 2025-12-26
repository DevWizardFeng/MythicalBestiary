/**
 * 神话志 - 轮播组件
 */

import { MythicalCreature } from '../model/MythicalCreature';
import { DarkTheme } from '../common/Theme';
import { RarityColors } from '../common/Constants';

@Component
export struct Banner {
  @Prop creatures: MythicalCreature[];
  @State currentIndex: number = 0;
  private swiperController: SwiperController = new SwiperController();
  onItemClick?: (creature: MythicalCreature) => void;

  build() {
    Column() {
      Swiper(this.swiperController) {
        ForEach(this.creatures, (creature: MythicalCreature, index: number) => {
          this.BannerItem(creature)
        })
      }
      .width('100%')
      .height(200)
      .autoPlay(true)
      .interval(5000)
      .indicator(false)
      .loop(true)
      .onChange((index: number) => {
        this.currentIndex = index;
      })

      // 自定义指示器
      Row({ space: 6 }) {
        ForEach(this.creatures, (_: MythicalCreature, index: number) => {
          Circle()
            .width(this.currentIndex === index ? 16 : 6)
            .height(6)
            .fill(this.currentIndex === index ? DarkTheme.accent : DarkTheme.textTertiary)
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
        })
      }
      .margin({ top: 12 })
    }
  }

  @Builder
  BannerItem(creature: MythicalCreature) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 背景图片
      Image($r(`app.media.${creature.image}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      // 渐变遮罩
      Column()
        .width('100%')
        .height('60%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })

      // 信息区域
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(creature.name.cn)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Text(creature.name.en)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
        }

        Text(creature.description)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.7)')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .clip(true)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(creature);
      }
    })
  }
}
