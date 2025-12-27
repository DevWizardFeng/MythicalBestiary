/**
 * 神话志 - 问答挑战数据模型
 */

import { CultureType, AttributeType } from '../common/Constants';

/**
 * 题目分类
 */
export type QuestionCategory = 'creature' | 'deity' | 'culture' | 'attribute' | 'ability' | 'mixed';

/**
 * 难度等级
 */
export type DifficultyLevel = 'easy' | 'medium' | 'hard';

/**
 * 游戏模式
 */
export type QuizMode = 'classic' | 'speed' | 'endless' | 'category';

/**
 * 段位类型
 */
export type TierType = 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond';

/**
 * 成就分类
 */
export type AchievementCategory = 'combo' | 'score' | 'accuracy' | 'count' | 'special';

/**
 * 成就稀有度
 */
export type AchievementRarity = 'common' | 'rare' | 'epic' | 'legendary';

/**
 * 问答题目
 */
export interface QuizQuestion {
  id: string;
  category: QuestionCategory;
  difficulty: DifficultyLevel;
  question: string;
  options: string[];
  correctIndex: number;
  explanation: string;
  relatedId?: string;
  image?: string;
  timeLimit?: number;
}

/**
 * 游戏配置
 */
export interface QuizConfig {
  mode: QuizMode;
  category?: QuestionCategory;
  questionCount: number;
  baseTimePerQuestion: number;
}

/**
 * 游戏结果
 */
export interface QuizResult {
  sessionId: string;
  mode: QuizMode;
  category?: QuestionCategory;
  totalQuestions: number;
  correctAnswers: number;
  wrongAnswers: number;
  totalScore: number;
  maxCombo: number;
  averageTime: number;
  completedAt: number;
  isNewRecord: boolean;
}

/**
 * 段位信息
 */
export interface TierInfo {
  type: TierType;
  nameCn: string;
  nameEn: string;
  minScore: number;
  color: string;
  icon: string;
}

/**
 * 模式名称接口
 */
export interface ModeNameInfo {
  cn: string;
  en: string;
  desc: string;
}

/**
 * 分类名称接口
 */
export interface CategoryNameInfo {
  cn: string;
  en: string;
}

/**
 * 难度名称接口
 */
export interface DifficultyNameInfo {
  cn: string;
  en: string;
  color: string;
}

/**
 * 段位阈值配置
 */
export const TierThresholds: TierInfo[] = [
  { type: 'bronze', nameCn: '青铜', nameEn: 'Bronze', minScore: 0, color: '#cd7f32', icon: 'ic_rank_bronze' } as TierInfo,
  { type: 'silver', nameCn: '白银', nameEn: 'Silver', minScore: 1000, color: '#c0c0c0', icon: 'ic_rank_silver' } as TierInfo,
  { type: 'gold', nameCn: '黄金', nameEn: 'Gold', minScore: 5000, color: '#ffd700', icon: 'ic_rank_gold' } as TierInfo,
  { type: 'platinum', nameCn: '铂金', nameEn: 'Platinum', minScore: 15000, color: '#e5e4e2', icon: 'ic_rank_platinum' } as TierInfo,
  { type: 'diamond', nameCn: '钻石', nameEn: 'Diamond', minScore: 50000, color: '#b9f2ff', icon: 'ic_rank_diamond' } as TierInfo
];

/**
 * 根据累计积分获取段位
 */
export function getTierByScore(totalScore: number): TierInfo {
  for (let i = TierThresholds.length - 1; i >= 0; i--) {
    if (totalScore >= TierThresholds[i].minScore) {
      return TierThresholds[i];
    }
  }
  return TierThresholds[0];
}

/**
 * 获取下一段位所需积分
 */
export function getNextTierScore(totalScore: number): number {
  const currentTier = getTierByScore(totalScore);
  const currentIndex = TierThresholds.findIndex(t => t.type === currentTier.type);
  if (currentIndex < TierThresholds.length - 1) {
    return TierThresholds[currentIndex + 1].minScore;
  }
  return -1; // 已达最高段位
}

/**
 * 成就条件
 */
export interface AchievementCondition {
  type: 'combo' | 'score' | 'correctRate' | 'gamesPlayed' | 'categoryMaster' | 'special';
  value: number;
  category?: QuestionCategory;
}

/**
 * 成就定义
 */
export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: AchievementCategory;
  condition: AchievementCondition;
  rewardPoints: number;
  rarity: AchievementRarity;
}

/**
 * 用户成就进度
 */
export interface UserAchievement {
  achievementId: string;
  unlocked: boolean;
  unlockedAt?: number;
  progress?: number;
}

/**
 * 挑战统计数据
 */
export interface ChallengeStats {
  totalGamesPlayed: number;
  totalScore: number;
  highestScore: number;
  totalCorrectAnswers: number;
  totalQuestions: number;
  maxCombo: number;
  currentTier: TierType;
  achievements: UserAchievement[];
  lastPlayedAt: number;
  categoryStats: CategoryStats[];
}

/**
 * 分类统计
 */
export interface CategoryStats {
  category: QuestionCategory;
  totalQuestions: number;
  correctAnswers: number;
}

/**
 * 创建空的挑战统计
 */
export function createEmptyChallengeStats(): ChallengeStats {
  return {
    totalGamesPlayed: 0,
    totalScore: 0,
    highestScore: 0,
    totalCorrectAnswers: 0,
    totalQuestions: 0,
    maxCombo: 0,
    currentTier: 'bronze',
    achievements: [],
    lastPlayedAt: 0,
    categoryStats: []
  } as ChallengeStats;
}

/**
 * 积分配置类
 */
export class ScoreConfig {
  static readonly BASE_SCORE: number = 100;
  static readonly COMBO_MULTIPLIER: number = 0.1;
  static readonly MAX_COMBO_BONUS: number = 2.0;
  static readonly TIME_BONUS_MAX: number = 50;

  static getDifficultyMultiplier(difficulty: DifficultyLevel): number {
    if (difficulty === 'easy') return 1.0;
    if (difficulty === 'medium') return 1.5;
    if (difficulty === 'hard') return 2.0;
    return 1.0;
  }
}

/**
 * 计算单题得分
 */
export function calculateScore(
  isCorrect: boolean,
  combo: number,
  timeRemaining: number,
  maxTime: number,
  difficulty: DifficultyLevel
): number {
  if (!isCorrect) {
    return 0;
  }

  const baseScore = ScoreConfig.BASE_SCORE;
  const diffMultiplier = ScoreConfig.getDifficultyMultiplier(difficulty);
  const comboBonus = Math.min(combo * ScoreConfig.COMBO_MULTIPLIER, ScoreConfig.MAX_COMBO_BONUS);
  const timeBonus = Math.floor((timeRemaining / maxTime) * ScoreConfig.TIME_BONUS_MAX);

  return Math.floor(baseScore * diffMultiplier * (1 + comboBonus) + timeBonus);
}

/**
 * 游戏模式配置 Map
 */
export const QuizModeConfigs: Map<QuizMode, QuizConfig> = new Map([
  ['classic', { mode: 'classic', questionCount: 10, baseTimePerQuestion: 15 } as QuizConfig],
  ['speed', { mode: 'speed', questionCount: 20, baseTimePerQuestion: 8 } as QuizConfig],
  ['endless', { mode: 'endless', questionCount: -1, baseTimePerQuestion: 15 } as QuizConfig],
  ['category', { mode: 'category', questionCount: 10, baseTimePerQuestion: 15 } as QuizConfig]
]);

/**
 * 游戏模式名称 Map
 */
export const QuizModeNames: Map<QuizMode, ModeNameInfo> = new Map([
  ['classic', { cn: '经典模式', en: 'Classic', desc: '10道题，每题15秒' } as ModeNameInfo],
  ['speed', { cn: '极速模式', en: 'Speed', desc: '20道题，每题8秒' } as ModeNameInfo],
  ['endless', { cn: '无尽模式', en: 'Endless', desc: '答错3次结束' } as ModeNameInfo],
  ['category', { cn: '专题模式', en: 'Category', desc: '选择分类挑战' } as ModeNameInfo]
]);

/**
 * 题目分类名称 Map
 */
export const CategoryNames: Map<QuestionCategory, CategoryNameInfo> = new Map([
  ['creature', { cn: '神兽', en: 'Creature' } as CategoryNameInfo],
  ['deity', { cn: '神祇', en: 'Deity' } as CategoryNameInfo],
  ['culture', { cn: '文化', en: 'Culture' } as CategoryNameInfo],
  ['attribute', { cn: '属性', en: 'Attribute' } as CategoryNameInfo],
  ['ability', { cn: '能力', en: 'Ability' } as CategoryNameInfo],
  ['mixed', { cn: '综合', en: 'Mixed' } as CategoryNameInfo]
]);

/**
 * 难度名称 Map
 */
export const DifficultyNames: Map<DifficultyLevel, DifficultyNameInfo> = new Map([
  ['easy', { cn: '简单', en: 'Easy', color: '#4caf50' } as DifficultyNameInfo],
  ['medium', { cn: '中等', en: 'Medium', color: '#ff9800' } as DifficultyNameInfo],
  ['hard', { cn: '困难', en: 'Hard', color: '#f44336' } as DifficultyNameInfo]
]);

/**
 * 获取模式配置
 */
export function getQuizModeConfig(mode: QuizMode): QuizConfig {
  const config = QuizModeConfigs.get(mode);
  if (config) return config;
  return { mode: 'classic', questionCount: 10, baseTimePerQuestion: 15 } as QuizConfig;
}

/**
 * 获取模式名称
 */
export function getQuizModeName(mode: QuizMode): ModeNameInfo {
  const name = QuizModeNames.get(mode);
  if (name) return name;
  return { cn: '经典模式', en: 'Classic', desc: '10道题，每题15秒' } as ModeNameInfo;
}

/**
 * 获取分类名称
 */
export function getCategoryName(category: QuestionCategory): CategoryNameInfo {
  const name = CategoryNames.get(category);
  if (name) return name;
  return { cn: '综合', en: 'Mixed' } as CategoryNameInfo;
}

/**
 * 获取难度名称
 */
export function getDifficultyName(difficulty: DifficultyLevel): DifficultyNameInfo {
  const name = DifficultyNames.get(difficulty);
  if (name) return name;
  return { cn: '简单', en: 'Easy', color: '#4caf50' } as DifficultyNameInfo;
}

/**
 * 生成唯一会话ID
 */
export function generateSessionId(): string {
  return `quiz_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * 随机打乱数组
 */
export function shuffleArray<T>(array: T[]): T[] {
  const shuffled: T[] = [];
  for (const item of array) {
    shuffled.push(item);
  }
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

/**
 * 从数组中随机选取指定数量的元素
 */
export function pickRandom<T>(array: T[], count: number): T[] {
  const shuffled = shuffleArray(array);
  return shuffled.slice(0, Math.min(count, array.length));
}
