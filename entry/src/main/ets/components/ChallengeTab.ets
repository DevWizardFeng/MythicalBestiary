/**
 * 神话志 - 挑战Tab组件
 * 知识挑战主页面：段位显示、模式选择、成就入口
 */

import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { DarkTheme, CardStyle } from '../common/Theme';
import { RouterPaths, GlobalStateKeys } from '../common/Constants';
import {
  ChallengeStats,
  QuizMode,
  TierInfo,
  getTierByScore,
  getNextTierScore,
  TierThresholds,
  createEmptyChallengeStats,
  getQuizModeName
} from '../model/Quiz';
import { StorageManager } from '../utils/Storage';
import { DataLoader } from '../utils/DataLoader';

interface QuizModeItem {
  mode: QuizMode;
  icon: Resource;
  color: string;
}

@Component
export struct ChallengeTab {
  @State stats: ChallengeStats = createEmptyChallengeStats();
  @State isLoading: boolean = true;
  @State currentTier: TierInfo = TierThresholds[0];
  @State nextTierScore: number = 1000;
  @State progressPercent: number = 0;
  @State questionCount: number = 0;
  @State isRefreshing: boolean = false;
  @Prop @Watch('onRefreshKeyChange') refreshKey: number = 0;
  // 监听全局挑战统计版本号变化，自动刷新数据
  @StorageLink(GlobalStateKeys.CHALLENGE_STATS_VERSION) @Watch('onStatsVersionChange') statsVersion: number = 0;

  private quizModes: QuizModeItem[] = [
    { mode: 'classic', icon: $r('app.media.ic_mode_classic'), color: '#4CAF50' },
    { mode: 'speed', icon: $r('app.media.ic_mode_speed'), color: '#FF9800' },
    { mode: 'endless', icon: $r('app.media.ic_mode_endless'), color: '#9C27B0' },
    { mode: 'category', icon: $r('app.media.ic_mode_category'), color: '#2196F3' }
  ];

  aboutToAppear() {
    this.loadData();
  }

  // 当refreshKey变化时重新加载数据
  onRefreshKeyChange(): void {
    this.loadData();
  }

  // 当全局统计版本号变化时重新加载数据
  onStatsVersionChange(): void {
    this.loadData();
  }

  async loadData() {
    try {
      this.isRefreshing = true;

      // 加载统计数据
      const storageManager = StorageManager.getInstance();
      this.stats = await storageManager.getChallengeStats();

      // 计算段位和进度
      this.currentTier = getTierByScore(this.stats.totalScore);
      this.nextTierScore = getNextTierScore(this.stats.totalScore);

      if (this.nextTierScore > 0) {
        const currentTierMin = this.currentTier.minScore;
        const progress = this.stats.totalScore - currentTierMin;
        const total = this.nextTierScore - currentTierMin;
        this.progressPercent = Math.min(Math.floor((progress / total) * 100), 100);
      } else {
        this.progressPercent = 100; // 最高段位
      }

      // 加载题库数量
      const dataLoader = DataLoader.getInstance();
      await dataLoader.loadQuizData();
      this.questionCount = dataLoader.getQuestionCount();

      this.isLoading = false;
      this.isRefreshing = false;
    } catch (error) {
      console.error('ChallengeTab: Failed to load data', error);
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // 顶部标题
        this.HeaderSection()

        // 段位卡片
        this.TierCard()

        // 游戏模式选择
        this.GameModeSection()

        // 快捷入口
        this.QuickActions()

        // 底部间距
        Blank()
          .height(80)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }

  @Builder
  HeaderSection() {
    Row() {
      Column({ space: 4 }) {
        Text('知识挑战')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Text(`题库共${this.questionCount}道题`)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 成就入口
      Column() {
        Image($r('app.media.ic_trophy'))
          .width(24)
          .height(24)
          .fillColor(DarkTheme.accent)
      }
      .width(44)
      .height(44)
      .backgroundColor(CardStyle.glassBackground)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: RouterPaths.ACHIEVEMENTS });
      })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  TierCard() {
    Column({ space: 12 }) {
      Row() {
        // 段位图标
        Image($r(`app.media.${this.currentTier.icon}`))
          .width(64)
          .height(64)
          .objectFit(ImageFit.Cover)
          .borderRadius(32)
          .clip(true)

        Column({ space: 4 }) {
          Text(this.currentTier.nameCn)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentTier.color)

          Text(`累计积分 ${this.stats.totalScore}`)
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })

        Blank()

        // 挑战次数
        Column({ space: 2 }) {
          Text(`${this.stats.totalGamesPlayed}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Text('挑战次数')
            .fontSize(10)
            .fontColor(DarkTheme.textSecondary)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      // 进度条
      if (this.nextTierScore > 0) {
        Column({ space: 4 }) {
          Row() {
            Text(`距离${this.getNextTierName()}还需 ${this.nextTierScore - this.stats.totalScore} 分`)
              .fontSize(12)
              .fontColor(DarkTheme.textSecondary)

            Blank()

            Text(`${this.progressPercent}%`)
              .fontSize(12)
              .fontColor(DarkTheme.accent)
          }
          .width('100%')

          Stack({ alignContent: Alignment.Start }) {
            // 背景
            Column()
              .width('100%')
              .height(8)
              .backgroundColor(DarkTheme.backgroundSecondary)
              .borderRadius(4)

            // 进度
            Column()
              .width(`${this.progressPercent}%`)
              .height(8)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [[this.currentTier.color, 0], [DarkTheme.accent, 1]]
              })
              .borderRadius(4)
          }
          .width('100%')
        }
        .width('100%')
      } else {
        Text('已达最高段位！')
          .fontSize(14)
          .fontColor(DarkTheme.accent)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
  }

  getNextTierName(): string {
    const currentIndex = TierThresholds.findIndex(t => t.type === this.currentTier.type);
    if (currentIndex < TierThresholds.length - 1) {
      return TierThresholds[currentIndex + 1].nameCn;
    }
    return '';
  }

  @Builder
  GameModeSection() {
    Column({ space: 12 }) {
      Text('选择挑战模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .width('100%')

      Grid() {
        ForEach(this.quizModes, (item: QuizModeItem) => {
          GridItem() {
            this.GameModeCard(item)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .height(220)
    }
    .width('100%')
  }

  @Builder
  GameModeCard(item: QuizModeItem) {
    Column({ space: 8 }) {
      // 图标
      Column() {
        Image(item.icon)
          .width(36)
          .height(36)
          .fillColor(item.color)
      }
      .width(56)
      .height(56)
      .backgroundColor(item.color + '22')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)

      // 模式名称
      Text(getQuizModeName(item.mode).cn)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      // 描述
      Text(getQuizModeName(item.mode).desc)
        .fontSize(11)
        .fontColor(DarkTheme.textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (item.mode === 'category') {
        // 专题模式需要选择分类
        router.pushUrl({
          url: RouterPaths.QUIZ_GAME,
          params: { mode: item.mode, showCategorySelect: true }
        });
      } else {
        router.pushUrl({
          url: RouterPaths.QUIZ_GAME,
          params: { mode: item.mode }
        });
      }
    })
  }

  @Builder
  QuickActions() {
    Row({ space: 12 }) {
      // 刷新数据
      this.RefreshButton()

      // 成就
      this.ActionButton('成就徽章', $r('app.media.ic_medal_gold'), () => {
        router.pushUrl({ url: RouterPaths.ACHIEVEMENTS });
      })
    }
    .width('100%')
  }

  @Builder
  RefreshButton() {
    Row({ space: 8 }) {
      if (this.isRefreshing) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color(DarkTheme.textPrimary)
      } else {
        Image($r('app.media.ic_refresh'))
          .width(20)
          .height(20)
          .fillColor(DarkTheme.textPrimary)
      }

      Text(this.isRefreshing ? '刷新中...' : '刷新数据')
        .fontSize(14)
        .fontColor(DarkTheme.textPrimary)
    }
    .layoutWeight(1)
    .height(48)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .justifyContent(FlexAlign.Center)
    .opacity(this.isRefreshing ? 0.6 : 1.0)
    .onClick(async () => {
      if (!this.isRefreshing) {
        await this.loadData();
        promptAction.showToast({
          message: '数据已刷新',
          duration: 1500,
          bottom: 100
        });
      }
    })
  }

  @Builder
  ActionButton(label: string, icon: Resource, onClick: () => void) {
    Row({ space: 8 }) {
      Image(icon)
        .width(20)
        .height(20)
        .fillColor(DarkTheme.textPrimary)

      Text(label)
        .fontSize(14)
        .fontColor(DarkTheme.textPrimary)
    }
    .layoutWeight(1)
    .height(48)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .justifyContent(FlexAlign.Center)
    .onClick(onClick)
  }
}
