/**
 * 神话志 - 答题结果页面
 * 显示得分、正确率、连击、成就解锁等
 */

import router from '@ohos.router';
import { DarkTheme, CardStyle } from '../common/Theme';
import { RouterPaths } from '../common/Constants';
import {
  QuizResult as QuizResultData,
  TierInfo,
  getTierByScore,
  TierThresholds,
  ChallengeStats,
  getQuizModeName
} from '../model/Quiz';
import { Achievement, PredefinedAchievements, getAchievementRarityColor, getAchievementRarityName } from '../model/Leaderboard';
import { StorageManager } from '../utils/Storage';

interface RouterParams {
  result: string;
}

@Entry
@Component
struct QuizResultPage {
  @State result: QuizResultData | null = null;
  @State isLoading: boolean = true;
  @State stats: ChallengeStats | null = null;
  @State isNewHighScore: boolean = false;
  @State tierUp: boolean = false;
  @State oldTier: TierInfo | null = null;
  @State newTier: TierInfo | null = null;
  @State newAchievements: Achievement[] = [];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.result) {
      try {
        this.result = JSON.parse(params.result) as QuizResultData;
        this.processResult();
      } catch (error) {
        console.error('QuizResult: Failed to parse result', error);
        router.back();
      }
    } else {
      router.back();
    }
  }

  async processResult() {
    if (!this.result) {
      return;
    }

    try {
      const storageManager = StorageManager.getInstance();

      // 获取旧统计数据
      const oldStats = await storageManager.getChallengeStats();
      this.oldTier = getTierByScore(oldStats.totalScore);

      // 检查是否新纪录
      if (this.result.totalScore > oldStats.highestScore) {
        this.isNewHighScore = true;
        this.result.isNewRecord = true;
      }

      // 更新统计数据
      const updateResult = await storageManager.updateChallengeStats(this.result);

      // 获取新统计数据
      this.stats = await storageManager.getChallengeStats();
      this.newTier = getTierByScore(this.stats.totalScore);

      // 检查是否升段
      if (updateResult.tierUp) {
        this.tierUp = true;
      }

      // 获取新解锁的成就
      if (updateResult.newAchievements.length > 0) {
        this.newAchievements = PredefinedAchievements.filter(
          a => updateResult.newAchievements.includes(a.id)
        );
      }

      this.isLoading = false;
    } catch (error) {
      console.error('QuizResult: Failed to process result', error);
      this.isLoading = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(DarkTheme.background)

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.result) {
        this.ResultView()
      }
    }
    .width('100%')
    .height('100%')
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
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ResultView() {
    Scroll() {
      Column({ space: 20 }) {
        // 关闭按钮
        Row() {
          Blank()
          Image($r('app.media.ic_close'))
            .width(24)
            .height(24)
            .fillColor(DarkTheme.textSecondary)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .padding({ top: 12, right: 16 })

        // 结果标题
        this.ResultHeader()

        // 分数展示
        this.ScoreSection()

        // 段位升级
        if (this.tierUp && this.newTier) {
          this.TierUpSection()
        }

        // 统计数据
        if (this.stats) {
          this.StatsSection()
        }

        // 新成就
        if (this.newAchievements.length > 0) {
          this.AchievementsSection()
        }

        // 操作按钮
        this.ActionButtons()

        Blank()
          .height(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  @Builder
  ResultHeader() {
    Column({ space: 8 }) {
      // 模式标签
      Text(getQuizModeName(this.result!.mode).cn)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .backgroundColor(DarkTheme.backgroundSecondary)
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .borderRadius(12)

      // 结果标题
      if (this.isNewHighScore) {
        Text('新纪录！')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)
      } else if (this.getAccuracyRate() >= 80) {
        Text('挑战成功！')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
      } else if (this.getAccuracyRate() >= 60) {
        Text('表现不错')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9800')
      } else {
        Text('继续努力')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 20 })
  }

  getAccuracyRate(): number {
    if (!this.result || this.result.totalQuestions === 0) {
      return 0;
    }
    return Math.floor((this.result.correctAnswers / this.result.totalQuestions) * 100);
  }

  @Builder
  ScoreSection() {
    Column({ space: 16 }) {
      // 大分数
      Text(`${this.result!.totalScore}`)
        .fontSize(64)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.accent)

      Text('总得分')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)

      // 详细统计
      Row({ space: 0 }) {
        this.ScoreItem('正确', `${this.result!.correctAnswers}`, '#4CAF50')
        this.DividerLine()
        this.ScoreItem('错误', `${this.result!.wrongAnswers}`, '#F44336')
        this.DividerLine()
        this.ScoreItem('正确率', `${this.getAccuracyRate()}%`, DarkTheme.accent)
        this.DividerLine()
        this.ScoreItem('最高连击', `${this.result!.maxCombo}`, '#FF6B35')
      }
      .width('100%')
      .backgroundColor(CardStyle.glassBackground)
      .borderRadius(CardStyle.borderRadius)
      .border({
        width: CardStyle.borderWidth,
        color: CardStyle.borderColor
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 20, bottom: 20 })
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
  }

  @Builder
  ScoreItem(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(11)
        .fontColor(DarkTheme.textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  DividerLine() {
    Column()
      .width(1)
      .height(32)
      .backgroundColor(CardStyle.borderColor)
  }

  @Builder
  TierUpSection() {
    Column({ space: 12 }) {
      Text('段位提升！')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.accent)

      Row({ space: 16 }) {
        // 旧段位
        if (this.oldTier) {
          Column({ space: 4 }) {
            Image($r(`app.media.${this.oldTier.icon}`))
              .width(40)
              .height(40)

            Text(this.oldTier.nameCn)
              .fontSize(12)
              .fontColor(this.oldTier.color)
          }
          .opacity(0.5)
        }

        // 箭头
        Image($r('app.media.ic_arrow_right'))
          .width(24)
          .height(24)
          .fillColor(DarkTheme.accent)

        // 新段位
        Column({ space: 4 }) {
          Image($r(`app.media.${this.newTier!.icon}`))
            .width(48)
            .height(48)

          Text(this.newTier!.nameCn)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.newTier!.color)
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(DarkTheme.accent + '11')
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: 2,
      color: DarkTheme.accent + '44'
    })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  StatsSection() {
    Column({ space: 12 }) {
      Text('累计数据')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .width('100%')

      Row({ space: 12 }) {
        this.StatCard('总挑战', `${this.stats!.totalGamesPlayed}次`)
        this.StatCard('累计分数', `${this.stats!.totalScore}`)
        this.StatCard('历史最高', `${this.stats!.highestScore}`)
      }
      .width('100%')
    }
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(label)
        .fontSize(11)
        .fontColor(DarkTheme.textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(12)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
  }

  @Builder
  AchievementsSection() {
    Column({ space: 12 }) {
      Text('新解锁成就')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .width('100%')

      ForEach(this.newAchievements, (achievement: Achievement) => {
        this.AchievementCard(achievement)
      })
    }
  }

  @Builder
  AchievementCard(achievement: Achievement) {
    Row({ space: 12 }) {
      // 图标
      Column() {
        Image($r(`app.media.${achievement.icon}`))
          .width(32)
          .height(32)
          .fillColor(getAchievementRarityColor(achievement.rarity))
      }
      .width(56)
      .height(56)
      .backgroundColor(getAchievementRarityColor(achievement.rarity) + '22')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)

      // 信息
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(achievement.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Text(getAchievementRarityName(achievement.rarity))
            .fontSize(10)
            .fontColor(getAchievementRarityColor(achievement.rarity))
            .backgroundColor(getAchievementRarityColor(achievement.rarity) + '22')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
        }

        Text(achievement.description)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 奖励积分
      Text(`+${achievement.rewardPoints}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.accent)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(12)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
  }

  @Builder
  ActionButtons() {
    Column({ space: 12 }) {
      // 再来一局
      Button('再来一局')
        .type(ButtonType.Normal)
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(DarkTheme.accent)
        .borderRadius(25)
        .onClick(() => {
          router.replaceUrl({
            url: RouterPaths.QUIZ_GAME,
            params: { mode: this.result!.mode, category: this.result!.category }
          });
        })

      // 返回挑战主页
      Button('返回挑战')
        .type(ButtonType.Normal)
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)
        .backgroundColor(CardStyle.glassBackground)
        .borderRadius(25)
        .border({
          width: CardStyle.borderWidth,
          color: CardStyle.borderColor
        })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .margin({ top: 20 })
  }
}
