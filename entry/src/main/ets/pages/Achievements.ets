/**
 * 神话志 - 成就页面
 * 展示已解锁和未解锁的成就徽章
 */

import router from '@ohos.router';
import { DarkTheme, CardStyle } from '../common/Theme';
import {
  Achievement,
  AchievementRarity,
  PredefinedAchievements,
  getAchievementRarityColor,
  getAchievementRarityName
} from '../model/Leaderboard';
import { ChallengeStats, createEmptyChallengeStats, UserAchievement } from '../model/Quiz';
import { StorageManager } from '../utils/Storage';

@Entry
@Component
struct Achievements {
  @State stats: ChallengeStats = createEmptyChallengeStats();
  @State isLoading: boolean = true;
  @State selectedFilter: 'all' | 'unlocked' | 'locked' = 'all';
  @State unlockedCount: number = 0;
  @State totalPoints: number = 0;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const storageManager = StorageManager.getInstance();
      this.stats = await storageManager.getChallengeStats();

      // 计算已解锁成就数和总积分
      const unlockedIds = this.stats.achievements
        .filter(a => a.unlocked)
        .map(a => a.achievementId);

      this.unlockedCount = unlockedIds.length;

      // 计算成就奖励积分
      this.totalPoints = PredefinedAchievements
        .filter(a => unlockedIds.includes(a.id))
        .reduce((sum, a) => sum + a.rewardPoints, 0);

      this.isLoading = false;
    } catch (error) {
      console.error('Achievements: Failed to load data', error);
      this.isLoading = false;
    }
  }

  isAchievementUnlocked(achievementId: string): boolean {
    const record = this.stats.achievements.find(a => a.achievementId === achievementId);
    return record?.unlocked ?? false;
  }

  getUnlockTime(achievementId: string): number | undefined {
    const record = this.stats.achievements.find(a => a.achievementId === achievementId);
    return record?.unlockedAt;
  }

  getFilteredAchievements(): Achievement[] {
    if (this.selectedFilter === 'unlocked') {
      return PredefinedAchievements.filter(a => this.isAchievementUnlocked(a.id));
    } else if (this.selectedFilter === 'locked') {
      return PredefinedAchievements.filter(a => !this.isAchievementUnlocked(a.id));
    }
    return PredefinedAchievements;
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.bg_achievements'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航栏
        this.NavigationBar()

        if (this.isLoading) {
          this.LoadingView()
        } else {
          Scroll() {
            Column({ space: 16 }) {
              // 统计卡片
              this.StatsCard()

              // 筛选标签
              this.FilterTabs()

              // 成就列表
              this.AchievementList()

              Blank()
                .height(40)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12 })
            .alignItems(HorizontalAlign.Start)
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .align(Alignment.Top)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NavigationBar() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor(DarkTheme.textPrimary)
        .onClick(() => {
          router.back();
        })

      Text('成就徽章')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .margin({ left: 16 })

      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(DarkTheme.background)
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

  @Builder
  StatsCard() {
    Row({ space: 0 }) {
      // 已解锁
      Column({ space: 4 }) {
        Text(`${this.unlockedCount}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)

        Text('已解锁')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .layoutWeight(1)

      // 分隔线
      Column()
        .width(1)
        .height(40)
        .backgroundColor(CardStyle.borderColor)

      // 总数
      Column({ space: 4 }) {
        Text(`${PredefinedAchievements.length}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Text('总成就')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .layoutWeight(1)

      // 分隔线
      Column()
        .width(1)
        .height(40)
        .backgroundColor(CardStyle.borderColor)

      // 奖励积分
      Column({ space: 4 }) {
        Text(`+${this.totalPoints}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')

        Text('奖励积分')
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
  }

  @Builder
  FilterTabs() {
    Row({ space: 8 }) {
      this.FilterTab('全部', 'all', PredefinedAchievements.length)
      this.FilterTab('已解锁', 'unlocked', this.unlockedCount)
      this.FilterTab('未解锁', 'locked', PredefinedAchievements.length - this.unlockedCount)
    }
    .width('100%')
  }

  @Builder
  FilterTab(label: string, value: 'all' | 'unlocked' | 'locked', count: number) {
    Column() {
      Text(`${label} (${count})`)
        .fontSize(13)
        .fontColor(this.selectedFilter === value ? DarkTheme.accent : DarkTheme.textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.selectedFilter === value ? DarkTheme.accent + '22' : CardStyle.glassBackground)
    .borderRadius(20)
    .border({
      width: this.selectedFilter === value ? 1 : CardStyle.borderWidth,
      color: this.selectedFilter === value ? DarkTheme.accent : CardStyle.borderColor
    })
    .onClick(() => {
      this.selectedFilter = value;
    })
  }

  @Builder
  AchievementList() {
    Column({ space: 12 }) {
      ForEach(this.getFilteredAchievements(), (achievement: Achievement) => {
        this.AchievementCard(achievement, this.isAchievementUnlocked(achievement.id))
      })
    }
    .width('100%')
  }

  @Builder
  AchievementCard(achievement: Achievement, isUnlocked: boolean) {
    Row({ space: 12 }) {
      // 图标
      Column() {
        Image($r(`app.media.${achievement.icon}`))
          .width(32)
          .height(32)
          .fillColor(isUnlocked ? getAchievementRarityColor(achievement.rarity) : DarkTheme.textTertiary)
      }
      .width(56)
      .height(56)
      .backgroundColor(isUnlocked ?
        getAchievementRarityColor(achievement.rarity) + '22' :
        DarkTheme.backgroundSecondary)
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)

      // 信息
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(achievement.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(isUnlocked ? DarkTheme.textPrimary : DarkTheme.textTertiary)

          Text(getAchievementRarityName(achievement.rarity))
            .fontSize(10)
            .fontColor(isUnlocked ? getAchievementRarityColor(achievement.rarity) : DarkTheme.textTertiary)
            .backgroundColor(isUnlocked ?
              getAchievementRarityColor(achievement.rarity) + '22' :
              DarkTheme.backgroundSecondary)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
        }

        Text(achievement.description)
          .fontSize(12)
          .fontColor(isUnlocked ? DarkTheme.textSecondary : DarkTheme.textTertiary)

        if (isUnlocked) {
          Text(this.formatUnlockTime(this.getUnlockTime(achievement.id)))
            .fontSize(10)
            .fontColor(DarkTheme.textSecondary)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 奖励积分
      Column({ space: 2 }) {
        Text(`+${achievement.rewardPoints}`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(isUnlocked ? DarkTheme.accent : DarkTheme.textTertiary)

        if (isUnlocked) {
          Image($r('app.media.ic_correct'))
            .width(16)
            .height(16)
            .fillColor('#4CAF50')
        }
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(12)
    .border({
      width: CardStyle.borderWidth,
      color: isUnlocked ? getAchievementRarityColor(achievement.rarity) + '44' : CardStyle.borderColor
    })
    .opacity(isUnlocked ? 1 : 0.7)
  }

  formatUnlockTime(timestamp: number | undefined): string {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `解锁于 ${month}月${day}日`;
  }
}
