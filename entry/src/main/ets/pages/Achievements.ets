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
          .fontColor('#ffd700')

        Text('已解锁')
          .fontSize(12)
          .fontColor('#d0d0e8')
      }
      .layoutWeight(1)

      // 分隔线
      Column()
        .width(1)
        .height(40)
        .backgroundColor('rgba(120, 120, 160, 0.4)')

      // 总数
      Column({ space: 4 }) {
        Text(`${PredefinedAchievements.length}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')

        Text('总成就')
          .fontSize(12)
          .fontColor('#d0d0e8')
      }
      .layoutWeight(1)

      // 分隔线
      Column()
        .width(1)
        .height(40)
        .backgroundColor('rgba(120, 120, 160, 0.4)')

      // 奖励积分
      Column({ space: 4 }) {
        Text(`+${this.totalPoints}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#66ff66')

        Text('奖励积分')
          .fontSize(12)
          .fontColor('#d0d0e8')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('rgba(25, 25, 55, 0.92)')
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: 1,
      color: 'rgba(100, 100, 140, 0.3)'
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
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedFilter === value ? '#ffffff' : '#b0b0c8')
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(this.selectedFilter === value ? 'rgba(255, 215, 0, 0.25)' : 'rgba(25, 25, 55, 0.92)')
    .borderRadius(20)
    .border({
      width: 1,
      color: this.selectedFilter === value ? '#ffd700' : 'rgba(100, 100, 140, 0.3)'
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
          .fillColor(isUnlocked ? getAchievementRarityColor(achievement.rarity) : '#6b6b8a')
      }
      .width(56)
      .height(56)
      .backgroundColor(isUnlocked ?
        getAchievementRarityColor(achievement.rarity) + '33' :
        'rgba(40, 40, 70, 0.9)')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)

      // 信息
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(achievement.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(isUnlocked ? '#ffffff' : '#8a8aa0')

          Text(getAchievementRarityName(achievement.rarity))
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(isUnlocked ? '#ffffff' : '#8a8aa0')
            .backgroundColor(isUnlocked ?
              getAchievementRarityColor(achievement.rarity) + '88' :
              'rgba(60, 60, 90, 0.9)')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
        }

        Text(achievement.description)
          .fontSize(12)
          .fontColor(isUnlocked ? '#d0d0e8' : '#7a7a98')

        if (isUnlocked) {
          Text(this.formatUnlockTime(this.getUnlockTime(achievement.id)))
            .fontSize(10)
            .fontColor('#b0b0c8')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 奖励积分
      Column({ space: 2 }) {
        Text(`+${achievement.rewardPoints}`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(isUnlocked ? '#ffffff' : '#7a7a98')
          .backgroundColor(isUnlocked ? getAchievementRarityColor(achievement.rarity) + '66' : 'transparent')
          .padding(isUnlocked ? { left: 8, right: 8, top: 4, bottom: 4 } : 0)
          .borderRadius(8)

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
    .backgroundColor('rgba(25, 25, 55, 0.92)')
    .borderRadius(12)
    .border({
      width: 1,
      color: isUnlocked ? getAchievementRarityColor(achievement.rarity) + '66' : 'rgba(100, 100, 140, 0.3)'
    })
  }

  formatUnlockTime(timestamp: number | undefined): string {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `解锁于 ${month}月${day}日`;
  }
}
