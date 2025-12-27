/**
 * 神话志 - 排行榜与成就数据模型
 */

import { QuizMode, QuestionCategory, AchievementRarity, AchievementCategory, Achievement, AchievementCondition, UserAchievement, ChallengeStats } from './Quiz';

// 重新导出 Quiz.ets 中的类型供其他模块使用
export { Achievement, AchievementRarity, AchievementCategory, AchievementCondition, UserAchievement } from './Quiz';

/**
 * 排行榜类型
 */
export type LeaderboardType = 'daily' | 'weekly' | 'allTime';

/**
 * 排行榜条目
 */
export interface LeaderboardEntry {
  rank: number;
  name: string;
  avatar?: string;
  score: number;
  correctRate: number;
  maxCombo: number;
  timestamp: number;
  isPlayer?: boolean;
}

/**
 * 排行榜数据
 */
export interface LeaderboardData {
  type: LeaderboardType;
  entries: LeaderboardEntry[];
  playerRank?: number;
  lastUpdated: number;
}

/**
 * 排行榜类型名称接口
 */
export interface LeaderboardTypeNameInfo {
  cn: string;
  en: string;
}

/**
 * 分数范围接口
 */
interface ScoreRange {
  min: number;
  max: number;
}

/**
 * 排行榜类型名称 Map
 */
export const LeaderboardTypeNames: Map<LeaderboardType, LeaderboardTypeNameInfo> = new Map([
  ['daily', { cn: '每日榜', en: 'Daily' } as LeaderboardTypeNameInfo],
  ['weekly', { cn: '每周榜', en: 'Weekly' } as LeaderboardTypeNameInfo],
  ['allTime', { cn: '总榜', en: 'All Time' } as LeaderboardTypeNameInfo]
]);

/**
 * 获取排行榜类型名称
 */
export function getLeaderboardTypeName(type: LeaderboardType): LeaderboardTypeNameInfo {
  const name = LeaderboardTypeNames.get(type);
  if (name) return name;
  return { cn: '总榜', en: 'All Time' } as LeaderboardTypeNameInfo;
}

/**
 * 模拟玩家名称库
 */
const SimulatedNames: string[] = [
  '神话探索者', '远古智者', '传说猎人', '知识守护者',
  '星辰旅者', '神秘学者', '古籍解读者', '神话迷',
  '上古追寻者', '传说收集者', '文化探险家', '智慧之眼',
  '奥秘研究者', '神话记录者', '历史追踪者', '典籍守护者',
  '神兽观察者', '传奇寻访者', '知识探索家', '古老智者',
  '神话解密者', '远古研究者', '圣典学者', '传说验证者',
  '神秘追寻者', '知识猎人', '典籍研究者', '历史守护者',
  '奥秘解读者', '神话追踪者'
];

/**
 * 获取随机模拟玩家名称
 */
function getRandomName(usedNames: Set<string>): string {
  const availableNames = SimulatedNames.filter(name => !usedNames.has(name));
  if (availableNames.length === 0) {
    return `玩家${Math.floor(Math.random() * 10000)}`;
  }
  const randomIndex = Math.floor(Math.random() * availableNames.length);
  return availableNames[randomIndex];
}

/**
 * 生成模拟排行榜数据
 */
export function generateSimulatedLeaderboard(
  type: LeaderboardType,
  playerScore: number,
  playerCorrectRate: number,
  playerCombo: number
): LeaderboardData {
  const entries: LeaderboardEntry[] = [];
  const usedNames = new Set<string>();
  const now = Date.now();

  // 根据排行榜类型设置分数范围
  let scoreRange: ScoreRange;
  switch (type) {
    case 'daily':
      scoreRange = { min: 500, max: 3000 } as ScoreRange;
      break;
    case 'weekly':
      scoreRange = { min: 2000, max: 15000 } as ScoreRange;
      break;
    case 'allTime':
      scoreRange = { min: 10000, max: 100000 } as ScoreRange;
      break;
    default:
      scoreRange = { min: 10000, max: 100000 } as ScoreRange;
  }

  // 生成模拟玩家数据
  const simulatedCount = 20;
  const simulatedScores: number[] = [];

  for (let i = 0; i < simulatedCount; i++) {
    const score = Math.floor(Math.random() * (scoreRange.max - scoreRange.min) + scoreRange.min);
    simulatedScores.push(score);
  }

  // 添加玩家分数
  simulatedScores.push(playerScore);

  // 按分数降序排序
  simulatedScores.sort((a, b) => b - a);

  // 生成排行榜条目
  let playerRank = 0;
  for (let i = 0; i < simulatedScores.length; i++) {
    const score = simulatedScores[i];
    const isPlayer = score === playerScore && playerRank === 0;

    if (isPlayer) {
      playerRank = i + 1;
      entries.push({
        rank: i + 1,
        name: '我',
        score: playerScore,
        correctRate: playerCorrectRate,
        maxCombo: playerCombo,
        timestamp: now,
        isPlayer: true
      });
    } else {
      const name = getRandomName(usedNames);
      usedNames.add(name);
      entries.push({
        rank: i + 1,
        name: name,
        score: score,
        correctRate: Math.floor(Math.random() * 30 + 70), // 70-100%
        maxCombo: Math.floor(Math.random() * 15 + 3), // 3-18
        timestamp: now - Math.floor(Math.random() * 86400000), // 随机时间
        isPlayer: false
      });
    }
  }

  return {
    type: type,
    entries: entries.slice(0, 50), // 最多50条
    playerRank: playerRank,
    lastUpdated: now
  };
}

/**
 * 预定义成就列表
 */
export const PredefinedAchievements: Achievement[] = [
  // 连击成就
  {
    id: 'ach_combo_5',
    name: '连击新手',
    description: '单局达成5连击',
    icon: 'ic_combo',
    category: 'combo',
    condition: { type: 'combo', value: 5 },
    rewardPoints: 100,
    rarity: 'common'
  },
  {
    id: 'ach_combo_10',
    name: '连击达人',
    description: '单局达成10连击',
    icon: 'ic_combo',
    category: 'combo',
    condition: { type: 'combo', value: 10 },
    rewardPoints: 300,
    rarity: 'rare'
  },
  {
    id: 'ach_combo_20',
    name: '连击大师',
    description: '单局达成20连击',
    icon: 'ic_combo',
    category: 'combo',
    condition: { type: 'combo', value: 20 },
    rewardPoints: 1000,
    rarity: 'epic'
  },
  {
    id: 'ach_combo_50',
    name: '连击传说',
    description: '单局达成50连击',
    icon: 'ic_combo',
    category: 'combo',
    condition: { type: 'combo', value: 50 },
    rewardPoints: 3000,
    rarity: 'legendary'
  },

  // 正确率成就
  {
    id: 'ach_perfect_game',
    name: '完美挑战',
    description: '单局全部答对',
    icon: 'ic_medal_gold',
    category: 'accuracy',
    condition: { type: 'correctRate', value: 100 },
    rewardPoints: 500,
    rarity: 'rare'
  },
  {
    id: 'ach_high_accuracy',
    name: '精准答题者',
    description: '单局正确率达到90%',
    icon: 'ic_medal_silver',
    category: 'accuracy',
    condition: { type: 'correctRate', value: 90 },
    rewardPoints: 200,
    rarity: 'common'
  },

  // 游戏次数成就
  {
    id: 'ach_games_10',
    name: '初入江湖',
    description: '完成10次挑战',
    icon: 'ic_trophy',
    category: 'count',
    condition: { type: 'gamesPlayed', value: 10 },
    rewardPoints: 200,
    rarity: 'common'
  },
  {
    id: 'ach_games_50',
    name: '挑战常客',
    description: '完成50次挑战',
    icon: 'ic_trophy',
    category: 'count',
    condition: { type: 'gamesPlayed', value: 50 },
    rewardPoints: 500,
    rarity: 'rare'
  },
  {
    id: 'ach_games_100',
    name: '挑战达人',
    description: '完成100次挑战',
    icon: 'ic_trophy',
    category: 'count',
    condition: { type: 'gamesPlayed', value: 100 },
    rewardPoints: 1000,
    rarity: 'epic'
  },
  {
    id: 'ach_games_500',
    name: '挑战传奇',
    description: '完成500次挑战',
    icon: 'ic_trophy',
    category: 'count',
    condition: { type: 'gamesPlayed', value: 500 },
    rewardPoints: 5000,
    rarity: 'legendary'
  },

  // 累计分数成就
  {
    id: 'ach_score_1000',
    name: '千分学者',
    description: '累计获得1000分',
    icon: 'ic_trophy',
    category: 'score',
    condition: { type: 'score', value: 1000 },
    rewardPoints: 100,
    rarity: 'common'
  },
  {
    id: 'ach_score_10000',
    name: '万分学者',
    description: '累计获得10000分',
    icon: 'ic_trophy',
    category: 'score',
    condition: { type: 'score', value: 10000 },
    rewardPoints: 500,
    rarity: 'rare'
  },
  {
    id: 'ach_score_50000',
    name: '五万分大师',
    description: '累计获得50000分',
    icon: 'ic_trophy',
    category: 'score',
    condition: { type: 'score', value: 50000 },
    rewardPoints: 2000,
    rarity: 'epic'
  },
  {
    id: 'ach_score_100000',
    name: '十万分传说',
    description: '累计获得100000分',
    icon: 'ic_trophy',
    category: 'score',
    condition: { type: 'score', value: 100000 },
    rewardPoints: 5000,
    rarity: 'legendary'
  },

  // 专题专家成就
  {
    id: 'ach_creature_expert',
    name: '神兽专家',
    description: '神兽题目正确率90%以上(至少20题)',
    icon: 'ic_culture_chinese',
    category: 'special',
    condition: { type: 'categoryMaster', value: 90, category: 'creature' },
    rewardPoints: 800,
    rarity: 'epic'
  },
  {
    id: 'ach_deity_expert',
    name: '神祇专家',
    description: '神祇题目正确率90%以上(至少20题)',
    icon: 'ic_culture_greek',
    category: 'special',
    condition: { type: 'categoryMaster', value: 90, category: 'deity' },
    rewardPoints: 800,
    rarity: 'epic'
  },
  {
    id: 'ach_culture_expert',
    name: '文化专家',
    description: '文化题目正确率90%以上(至少20题)',
    icon: 'ic_culture_norse',
    category: 'special',
    condition: { type: 'categoryMaster', value: 90, category: 'culture' },
    rewardPoints: 800,
    rarity: 'epic'
  }
];

/**
 * 检查成就是否解锁
 */
export function checkAchievementUnlocked(
  achievement: Achievement,
  stats: ChallengeStats,
  currentGameMaxCombo?: number,
  currentGameCorrectRate?: number
): boolean {
  const condition = achievement.condition;

  switch (condition.type) {
    case 'combo':
      // 检查当前局最大连击或历史最大连击
      const maxCombo = Math.max(stats.maxCombo, currentGameMaxCombo || 0);
      return maxCombo >= condition.value;

    case 'score':
      return stats.totalScore >= condition.value;

    case 'correctRate':
      // 检查当前局正确率
      return (currentGameCorrectRate || 0) >= condition.value;

    case 'gamesPlayed':
      return stats.totalGamesPlayed >= condition.value;

    case 'categoryMaster':
      // 检查特定分类的正确率
      if (condition.category) {
        const catStats = stats.categoryStats.find(cs => cs.category === condition.category);
        if (catStats && catStats.totalQuestions >= 20) {
          const rate = (catStats.correctAnswers / catStats.totalQuestions) * 100;
          return rate >= condition.value;
        }
      }
      return false;

    default:
      return false;
  }
}

/**
 * 检查并返回新解锁的成就
 */
export function checkNewAchievements(
  stats: ChallengeStats,
  currentGameMaxCombo: number,
  currentGameCorrectRate: number
): Achievement[] {
  const newUnlocked: Achievement[] = [];

  for (const achievement of PredefinedAchievements) {
    // 检查是否已解锁
    const alreadyUnlocked = stats.achievements.some(
      ua => ua.achievementId === achievement.id && ua.unlocked
    );

    if (!alreadyUnlocked) {
      // 检查是否满足解锁条件
      if (checkAchievementUnlocked(achievement, stats, currentGameMaxCombo, currentGameCorrectRate)) {
        newUnlocked.push(achievement);
      }
    }
  }

  return newUnlocked;
}

/**
 * 获取成就稀有度颜色
 */
export function getAchievementRarityColor(rarity: AchievementRarity): string {
  switch (rarity) {
    case 'common':
      return '#9e9e9e';
    case 'rare':
      return '#4cc9f0';
    case 'epic':
      return '#9d4edd';
    case 'legendary':
      return '#ffd700';
    default:
      return '#9e9e9e';
  }
}

/**
 * 获取成就稀有度名称
 */
export function getAchievementRarityName(rarity: AchievementRarity): string {
  switch (rarity) {
    case 'common':
      return '普通';
    case 'rare':
      return '稀有';
    case 'epic':
      return '史诗';
    case 'legendary':
      return '传说';
    default:
      return '未知';
  }
}

/**
 * 计算成就完成进度
 */
export function calculateAchievementProgress(
  achievement: Achievement,
  stats: ChallengeStats
): number {
  const condition = achievement.condition;

  switch (condition.type) {
    case 'combo':
      return Math.min(stats.maxCombo / condition.value, 1) * 100;

    case 'score':
      return Math.min(stats.totalScore / condition.value, 1) * 100;

    case 'gamesPlayed':
      return Math.min(stats.totalGamesPlayed / condition.value, 1) * 100;

    case 'categoryMaster':
      if (condition.category) {
        const catStats = stats.categoryStats.find(cs => cs.category === condition.category);
        if (catStats && catStats.totalQuestions > 0) {
          const rate = (catStats.correctAnswers / catStats.totalQuestions) * 100;
          return Math.min(rate / condition.value, 1) * 100;
        }
      }
      return 0;

    default:
      return 0;
  }
}
