/**
 * 神话志 - 每日签到页面
 * 抽取随机神兽卡牌，建立卡牌收集图鉴
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { CheckInRecord, Card, getRarityChineseName, getRarityCardColor } from '../model/CardCollection';
import { MythicalCreature } from '../model/MythicalCreature';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct DailyCheckIn {
  @State hasCheckedIn: boolean = false;
  @State isChecking: boolean = false;
  @State checkInRecord: CheckInRecord | null = null;
  @State drawnCreature: MythicalCreature | null = null;
  @State consecutiveDays: number = 0;
  @State totalCheckIns: number = 0;
  @State isCardFlipping: boolean = false;
  @State showCardFront: boolean = false;

  aboutToAppear() {
    this.loadCheckInStatus();
  }

  async loadCheckInStatus() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();

      this.hasCheckedIn = await storage.hasTodayCheckedIn();
      const stats = await storage.getCardStats();
      this.consecutiveDays = stats.consecutiveDays;
      this.totalCheckIns = stats.totalCheckIns;
    } catch (error) {
      console.error('加载签到状态失败:', error);
    }
  }

  async performCheckIn() {
    console.log('[DailyCheckIn] performCheckIn called');
    if (this.hasCheckedIn || this.isChecking) {
      console.log('[DailyCheckIn] Already checked in or currently checking');
      return;
    }

    this.isChecking = true;
    console.log('[DailyCheckIn] Starting check-in process...');

    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();
      console.log('[DailyCheckIn] Loaded creatures:', allCreatures.length);

      const storage = StorageUtil.getInstance();
      const record = await storage.dailyCheckIn(allCreatures);
      console.log('[DailyCheckIn] Check-in result:', record);

      if (record) {
        this.checkInRecord = record;
        this.consecutiveDays = record.consecutive;
        this.totalCheckIns++;

        // 获取抽到的神兽信息
        if (record.reward) {
          this.drawnCreature = dataLoader.getCreatureById(record.reward.creatureId) || null;
          console.log('[DailyCheckIn] Drew creature:', this.drawnCreature?.name.cn);
        }

        // 卡牌翻转动画
        setTimeout(() => {
          this.isCardFlipping = true;
          setTimeout(() => {
            this.showCardFront = true;
          }, 300);
        }, 500);

        this.hasCheckedIn = true;
        promptAction.showToast({ message: '签到成功！' });
        console.log('[DailyCheckIn] Check-in successful');
      } else {
        promptAction.showToast({ message: '今天已经签到过了' });
        console.log('[DailyCheckIn] Already checked in today');
      }
    } catch (error) {
      console.error('[DailyCheckIn] Check-in failed:', error);
      promptAction.showToast({ message: '签到失败，请重试' });
    } finally {
      this.isChecking = false;
      console.log('[DailyCheckIn] Check-in process complete');
    }
  }

  goBack() {
    router.back();
  }

  goToCardCollection() {
    // TODO: 跳转到卡牌图鉴页面
    promptAction.showToast({ message: '卡牌图鉴功能开发中' });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景图片
      Image($r('app.media.bg_main_mystical'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .fillColor(DarkTheme.textPrimary)
            .onClick(() => this.goBack())

          Text('每日签到')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 12 })

          Blank()

          Button('卡牌图鉴')
            .fontSize(14)
            .fontColor(DarkTheme.textPrimary)
            .backgroundColor('rgba(255,215,0,0.2)')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => this.goToCardCollection())
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        Scroll() {
          Column({ space: 24 }) {
            // 签到统计
            this.StatsSection()

            // 签到卡牌区域
            if (!this.hasCheckedIn || this.checkInRecord) {
              this.CheckInCardSection()
            } else {
              this.AlreadyCheckedSection()
            }

            // 签到说明
            this.InstructionSection()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatsSection() {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(`${this.consecutiveDays}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)

        Text('连续签到')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('rgba(30,30,60,0.7)')
      .borderRadius(12)

      Column({ space: 4 }) {
        Text(`${this.totalCheckIns}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)

        Text('累计签到')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor('rgba(30,30,60,0.7)')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  CheckInCardSection() {
    Column({ space: 16 }) {
      Text(this.hasCheckedIn ? '今日奖励' : '点击抽取今日卡牌')
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)

      // 卡牌区域
      Stack() {
        if (!this.showCardFront) {
          // 卡牌背面
          Column() {
            Image($r('app.media.ic_tab_wiki'))
              .width(80)
              .height(80)
              .fillColor(DarkTheme.accent)

            Text('神兽卡牌')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)
              .margin({ top: 16 })
          }
          .width(280)
          .height(400)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(30,30,60,0.9)')
          .borderRadius(16)
          .border({
            width: 2,
            color: this.drawnCreature ?
              getRarityCardColor(this.drawnCreature.rarity) : DarkTheme.accent
          })
          .rotate({
            y: this.isCardFlipping ? 1 : 0,
            centerX: '50%',
            centerY: '50%',
            angle: this.isCardFlipping ? 90 : 0
          })
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
        } else {
          // 卡牌正面
          this.CardFrontView()
        }
      }
      .width('100%')
      .height(420)
      .justifyContent(FlexAlign.Center)

      // 签到按钮
      if (!this.hasCheckedIn) {
        Button(this.isChecking ? '抽取中...' : '立即签到')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a3e')
          .backgroundColor(DarkTheme.accent)
          .width('100%')
          .height(48)
          .borderRadius(24)
          .enabled(!this.isChecking)
          .onClick(() => this.performCheckIn())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(16)
  }

  @Builder
  CardFrontView() {
    if (this.drawnCreature && this.checkInRecord?.reward) {
      Column({ space: 12 }) {
        // 神兽图片
        Image($r(`app.media.${this.drawnCreature.image}`))
          .width(200)
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        // 神兽名称
        Text(this.drawnCreature.name.cn)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        // 稀有度
        Text(getRarityChineseName(this.checkInRecord.reward.rarity))
          .fontSize(14)
          .fontColor(getRarityCardColor(this.checkInRecord.reward.rarity))
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(12)

        // 等级
        Text(`★ ${this.checkInRecord.reward.level}`)
          .fontSize(16)
          .fontColor(DarkTheme.accent)
      }
      .width(280)
      .height(400)
      .padding(20)
      .backgroundColor('rgba(30,30,60,0.9)')
      .borderRadius(16)
      .border({
        width: 2,
        color: getRarityCardColor(this.checkInRecord.reward.rarity)
      })
      .rotate({
        y: 1,
        centerX: '50%',
        centerY: '50%',
        angle: 0
      })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
    }
  }

  @Builder
  AlreadyCheckedSection() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_check'))
        .width(80)
        .height(80)
        .fillColor('#4caf50')

      Text('今日已签到')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text('明天再来吧！')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .padding(48)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(16)
  }

  @Builder
  InstructionSection() {
    Column({ space: 12 }) {
      Text('签到说明')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text('• 每日签到可随机获得一张神兽卡牌')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      Text('• 卡牌稀有度：普通60%、稀有25%、史诗10%、传说5%')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      Text('• 重复卡牌可升级，最高5星')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      Text('• 连续签到可获得额外奖励')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
}
