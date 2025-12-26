/**
 * 神话志 - 每日占卜页面
 * 随机推荐今日守护神兽或守护神祇
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { RarityColors, RarityNames, CultureNames, AttributeNames, RarityType, CultureType, AttributeType,
  getRarityColor, getRarityName, getCultureName, getAttributeName, getCultureColor, RarityInfo, CultureNameInfo, NamePair } from '../common/Constants';

type DivinationType = 'creature' | 'deity';

@Entry
@Component
struct DailyDivination {
  @State divinationType: DivinationType = 'creature';
  @State creature: MythicalCreature | null = null;
  @State deity: Deity | null = null;
  @State isRevealed: boolean = false;
  @State isAnimating: boolean = false;
  @State fortune: string = '';
  @State isDataLoaded: boolean = false;

  private creatureFortunes: string[] = [
    '今日运势大吉，万事顺遂',
    '守护神兽将为你带来好运',
    '今日适宜冒险，勇往直前',
    '保持平和心态，好运自来',
    '今日贵人相助，事半功倍',
    '神兽护佑，心想事成',
    '今日适宜学习，收获满满',
    '保持善念，福报无限'
  ];

  private deityFortunes: string[] = [
    '神祇庇佑，诸事顺遂',
    '今日受到神力加持，勇往直前',
    '守护神祇将指引你前行',
    '保持虔诚之心，好运自来',
    '神恩浩荡，心想事成',
    '今日灵感迸发，创造无限',
    '守护神赐予你力量与勇气',
    '神圣加护，万事亨通'
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.isDataLoaded = true;
      // 默认加载神兽占卜
      this.loadRandomCreature();
    } catch (error) {
      console.error('Failed to load data:', error);
    }
  }

  loadRandomCreature() {
    try {
      const dataLoader = DataLoader.getInstance();
      const allCreatures = dataLoader.getAllCreatures();

      // 使用今日日期作为随机种子，确保每天结果一致
      const today = new Date();
      const seed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate();
      const index = seed % allCreatures.length;

      this.creature = allCreatures[index];
      this.fortune = this.creatureFortunes[seed % this.creatureFortunes.length];
    } catch (error) {
      console.error('Failed to load creature:', error);
    }
  }

  loadRandomDeity() {
    try {
      const dataLoader = DataLoader.getInstance();
      const allDeities = dataLoader.getAllDeities();

      // 使用今日日期+1作为随机种子（与神兽不同）
      const today = new Date();
      const seed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate() + 1;
      const index = seed % allDeities.length;

      this.deity = allDeities[index];
      this.fortune = this.deityFortunes[seed % this.deityFortunes.length];
    } catch (error) {
      console.error('Failed to load deity:', error);
    }
  }

  switchDivinationType(type: DivinationType) {
    if (this.divinationType === type) return;
    this.divinationType = type;
    this.isRevealed = false;
    if (type === 'creature') {
      this.loadRandomCreature();
    } else {
      this.loadRandomDeity();
    }
  }

  reveal() {
    this.isAnimating = true;
    setTimeout(() => {
      this.isRevealed = true;
      this.isAnimating = false;
    }, 1500);
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.LeftTop,
          colors: [['#1a1a2e', 0], ['#16213e', 0.5], ['#0f3460', 1]]
        })

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.back();
            })

          Blank()

          Text('每日占卜')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Blank()

          Column()
            .width(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 48, bottom: 16 })

        if (!this.isRevealed) {
          // 占卜前
          this.DivinationCard()
        } else {
          // 占卜结果
          if (this.divinationType === 'creature') {
            this.CreatureResultCard()
          } else {
            this.DeityResultCard()
          }
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  DivinationCard() {
    Column() {
      Blank()
        .layoutWeight(1)

      // 占卜类型选择
      Row({ space: 24 }) {
        Column({ space: 8 }) {
          Image($r('app.media.ic_attr_nature'))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Contain)
            .clip(true)
            .borderRadius(32)
            .backgroundColor(this.divinationType === 'creature' ? 'rgba(255,215,0,0.2)' : 'rgba(255,255,255,0.1)')
          Text('守护神兽')
            .fontSize(14)
            .fontColor(this.divinationType === 'creature' ? '#ffd700' : 'rgba(255,255,255,0.6)')
        }
        .onClick(() => {
          this.switchDivinationType('creature');
        })

        Column({ space: 8 }) {
          Image($r('app.media.ic_attr_light'))
            .width(64)
            .height(64)
            .objectFit(ImageFit.Contain)
            .clip(true)
            .borderRadius(32)
            .backgroundColor(this.divinationType === 'deity' ? 'rgba(255,215,0,0.2)' : 'rgba(255,255,255,0.1)')
          Text('守护神祇')
            .fontSize(14)
            .fontColor(this.divinationType === 'deity' ? '#ffd700' : 'rgba(255,255,255,0.6)')
        }
        .onClick(() => {
          this.switchDivinationType('deity');
        })
      }
      .margin({ bottom: 32 })

      // 神秘卡片
      Column() {
        if (this.isAnimating) {
          LoadingProgress()
            .width(64)
            .height(64)
            .color('#ffd700')
        } else {
          Image($r('app.media.ic_attr_light'))
            .width(80)
            .height(80)
            .objectFit(ImageFit.Contain)
            .clip(true)
            .borderRadius(40)

          Text('点击揭晓')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.6)')
            .margin({ top: 16 })
        }
      }
      .width(200)
      .height(280)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,215,0,0.1)')
      .borderRadius(16)
      .border({
        width: 2,
        color: 'rgba(255,215,0,0.3)'
      })
      .onClick(() => {
        if (!this.isAnimating) {
          this.reveal();
        }
      })

      Text('今日守护')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .margin({ top: 32 })

      Text(this.divinationType === 'creature' ? '点击卡片揭晓你的守护神兽' : '点击卡片揭晓你的守护神祇')
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.6)')
        .margin({ top: 8 })

      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  CreatureResultCard() {
    Scroll() {
      Column({ space: 24 }) {
        // 神兽图片
        Stack({ alignContent: Alignment.Bottom }) {
          Image($r(`app.media.${this.creature?.image}`))
            .width('100%')
            .height(300)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)

          // 渐变遮罩
          Column()
            .width('100%')
            .height('50%')
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['rgba(0,0,0,0.8)', 0], ['rgba(0,0,0,0)', 1]]
            })
            .borderRadius({ bottomLeft: 16, bottomRight: 16 })

          // 名称
          Column({ space: 4 }) {
            Text(this.creature?.name.cn)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffffff')

            Text(this.creature?.name.en)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .padding(16)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(300)
        .margin({ left: 16, right: 16 })

        // 运势提示
        Column({ space: 8 }) {
          Text('今日运势')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.5)')

          Text(this.fortune)
            .fontSize(18)
            .fontColor('#ffd700')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(255,215,0,0.1)')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })

        // 神兽信息
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text(getRarityName(this.creature?.rarity as RarityType).cn)
              .fontSize(12)
              .fontColor('#ffffff')
              .backgroundColor(getRarityColor(this.creature?.rarity as RarityType))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)

            Text(getCultureName(this.creature?.culture as CultureType).cn)
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.7)')
              .backgroundColor('rgba(255,255,255,0.1)')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)

            Text(getAttributeName(this.creature?.attributes.primary as AttributeType).cn)
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.7)')
              .backgroundColor('rgba(255,255,255,0.1)')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)
          }

          Text(this.creature?.description || '')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
            .lineHeight(22)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(255,255,255,0.05)')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .alignItems(HorizontalAlign.Start)

        // 查看详情按钮
        Button('查看详情')
          .fontSize(16)
          .fontColor('#1a1a2e')
          .backgroundColor('#ffd700')
          .width('calc(100% - 32vp)')
          .height(48)
          .borderRadius(24)
          .margin({ left: 16, right: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CreatureDetail',
              params: { creatureId: this.creature?.id }
            });
          })

        Column()
          .height(32)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  DeityResultCard() {
    Scroll() {
      Column({ space: 24 }) {
        // 神祇图片
        Stack({ alignContent: Alignment.Bottom }) {
          Image($r(`app.media.${this.deity?.image}`))
            .width('100%')
            .height(300)
            .objectFit(ImageFit.Cover)
            .borderRadius(16)

          // 渐变遮罩
          Column()
            .width('100%')
            .height('50%')
            .linearGradient({
              direction: GradientDirection.Top,
              colors: [['rgba(0,0,0,0.8)', 0], ['rgba(0,0,0,0)', 1]]
            })
            .borderRadius({ bottomLeft: 16, bottomRight: 16 })

          // 名称
          Column({ space: 4 }) {
            Row({ space: 8 }) {
              Text(this.deity?.name.cn)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')

              Text('神祇')
                .fontSize(12)
                .fontColor('#ffffff')
                .backgroundColor(DarkTheme.accentSecondary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(8)
            }

            Text(this.deity?.name.en)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .padding(16)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(300)
        .margin({ left: 16, right: 16 })

        // 运势提示
        Column({ space: 8 }) {
          Text('今日运势')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.5)')

          Text(this.fortune)
            .fontSize(18)
            .fontColor('#ffd700')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(255,215,0,0.1)')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })

        // 神祇信息
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text(getCultureName(this.deity?.culture as CultureType).cn)
              .fontSize(12)
              .fontColor('#ffffff')
              .backgroundColor(getCultureColor(this.deity?.culture as CultureType))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(8)

            ForEach(this.deity?.domain.slice(0, 3), (domain: string, index: number) => {
              Text(domain)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.7)')
                .backgroundColor('rgba(255,255,255,0.1)')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(8)
            }, (domain: string, index: number) => `deity_div_${index}`)
          }

          Text(this.deity?.description || '')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
            .lineHeight(22)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('rgba(255,255,255,0.05)')
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .alignItems(HorizontalAlign.Start)

        // 查看详情按钮
        Button('查看详情')
          .fontSize(16)
          .fontColor('#1a1a2e')
          .backgroundColor('#ffd700')
          .width('calc(100% - 32vp)')
          .height(48)
          .borderRadius(24)
          .margin({ left: 16, right: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DeityDetail',
              params: { deityId: this.deity?.id }
            });
          })

        Column()
          .height(32)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
