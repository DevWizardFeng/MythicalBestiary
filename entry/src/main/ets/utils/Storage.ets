/**
 * 神话志 - 本地存储工具
 */

import preferences from '@ohos.data.preferences';
import { StorageKeys, GlobalStateKeys } from '../common/Constants';
import {
  UserFavorites,
  UserHistory,
  UserCreature,
  UserSettings,
  DefaultUserSettings,
  createEmptyFavorites,
  createEmptyHistory,
  HistoryItem,
  EntryType,
  normalizeHistoryItem
} from '../model/UserData';
import {
  ChallengeStats,
  QuizResult,
  createEmptyChallengeStats,
  getTierByScore,
  UserAchievement
} from '../model/Quiz';
import {
  LeaderboardData,
  LeaderboardType,
  checkNewAchievements,
  PredefinedAchievements
} from '../model/Leaderboard';
import {
  UserCardCollection,
  Card,
  CheckInRecord,
  createEmptyCardCollection,
  drawRandomCard,
  upgradeCard,
  hasCheckedInToday,
  getTodayString,
  calculateConsecutiveDays
} from '../model/CardCollection';
import { MythicalCreature } from '../model/MythicalCreature';

/**
 * 挑战结果更新返回值接口
 */
export interface ChallengeUpdateResult {
  newAchievements: string[];
  tierUp: boolean;
}

/**
 * 故事阅读进度项接口
 */
interface StoryProgressItem {
  chapterIndex: number;
  timestamp: number;
}

/**
 * 收藏项接口（用于通用收藏方法）
 */
export interface FavoriteItem {
  type: 'creature' | 'deity' | 'story';
  id: string;
  name: string;
  image: string;
  timestamp: number;
}

/**
 * 存储管理器类
 */
export class StorageManager {
  private static instance: StorageManager;
  private context: Context | null = null;
  private preferencesMap: Map<string, preferences.Preferences> = new Map();

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  /**
   * 初始化上下文
   */
  init(context: Context): void {
    this.context = context;
  }

  /**
   * 确保context已初始化
   */
  private ensureContext(): void {
    if (!this.context) {
      try {
        this.context = getContext();
      } catch (e) {
        console.error('StorageManager: 获取context失败');
      }
    }
  }

  /**
   * 获取Preferences实例
   */
  private async getPreferences(name: string): Promise<preferences.Preferences | null> {
    // 确保context已初始化
    this.ensureContext();

    if (!this.context) {
      console.error('StorageManager: context未初始化');
      return null;
    }

    if (this.preferencesMap.has(name)) {
      return this.preferencesMap.get(name)!;
    }

    try {
      const pref = await preferences.getPreferences(this.context, name);
      this.preferencesMap.set(name, pref);
      return pref;
    } catch (error) {
      console.error(`StorageManager: 获取Preferences失败 - ${name}`, error);
      return null;
    }
  }

  // ==================== 收藏相关 ====================

  /**
   * 获取收藏列表
   */
  async getFavorites(): Promise<UserFavorites> {
    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return createEmptyFavorites();
    }

    try {
      const data = await pref.get(StorageKeys.FAVORITES, '');
      if (data && typeof data === 'string' && data.length > 0) {
        const parsed = JSON.parse(data) as UserFavorites;
        // 确保 deityIds 存在（兼容旧版本数据）
        if (!parsed.deityIds) {
          parsed.deityIds = [];
        }
        return parsed;
      }
    } catch (error) {
      console.error('StorageManager: 获取收藏失败', error);
    }

    return createEmptyFavorites();
  }

  /**
   * 保存收藏列表
   */
  async saveFavorites(favorites: UserFavorites): Promise<void> {
    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.FAVORITES, JSON.stringify(favorites));
      await pref.flush();
      // 更新全局收藏数
      this.updateGlobalFavoriteCount(favorites);
    } catch (error) {
      console.error('StorageManager: 保存收藏失败', error);
    }
  }

  /**
   * 更新全局收藏数
   */
  private updateGlobalFavoriteCount(favorites: UserFavorites): void {
    const count = favorites.creatureIds.length + (favorites.deityIds?.length || 0);
    // 先删除再创建，强制触发 @StorageLink 更新（即使值相同）
    AppStorage.delete(GlobalStateKeys.FAVORITE_COUNT);
    AppStorage.setOrCreate(GlobalStateKeys.FAVORITE_COUNT, count);
  }

  /**
   * 添加收藏
   */
  async addFavorite(creatureId: string): Promise<void> {
    const favorites = await this.getFavorites();
    if (!favorites.creatureIds.includes(creatureId)) {
      favorites.creatureIds.push(creatureId);
      favorites.updatedAt = Date.now();
      await this.saveFavorites(favorites);
    }
  }

  /**
   * 移除收藏
   */
  async removeFavorite(creatureId: string): Promise<void> {
    const favorites = await this.getFavorites();
    const index = favorites.creatureIds.indexOf(creatureId);
    if (index > -1) {
      favorites.creatureIds.splice(index, 1);
      favorites.updatedAt = Date.now();
      await this.saveFavorites(favorites);
    }
  }

  /**
   * 检查是否已收藏
   */
  async isFavorite(creatureId: string): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.creatureIds.includes(creatureId);
  }

  // ==================== 神祇收藏相关 ====================

  /**
   * 添加神祇收藏
   */
  async addDeityFavorite(deityId: string): Promise<void> {
    const favorites = await this.getFavorites();
    if (!favorites.deityIds) {
      favorites.deityIds = [];
    }
    if (!favorites.deityIds.includes(deityId)) {
      favorites.deityIds.push(deityId);
      favorites.updatedAt = Date.now();
      await this.saveFavorites(favorites);
    }
  }

  /**
   * 移除神祇收藏
   */
  async removeDeityFavorite(deityId: string): Promise<void> {
    const favorites = await this.getFavorites();
    if (favorites.deityIds) {
      const index = favorites.deityIds.indexOf(deityId);
      if (index > -1) {
        favorites.deityIds.splice(index, 1);
        favorites.updatedAt = Date.now();
        await this.saveFavorites(favorites);
      }
    }
  }

  /**
   * 检查神祇是否已收藏
   */
  async isDeityFavorite(deityId: string): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.deityIds?.includes(deityId) ?? false;
  }

  /**
   * 获取神祇收藏列表
   */
  async getDeityFavorites(): Promise<string[]> {
    const favorites = await this.getFavorites();
    return favorites.deityIds || [];
  }

  // ==================== 历史记录相关 ====================

  /**
   * 获取浏览历史
   */
  async getHistory(): Promise<UserHistory> {
    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return createEmptyHistory();
    }

    try {
      const data = await pref.get(StorageKeys.HISTORY, '');
      if (data && typeof data === 'string' && data.length > 0) {
        const history = JSON.parse(data) as UserHistory;
        // 规范化历史记录项（兼容旧版本数据）
        history.items = history.items.map(item => normalizeHistoryItem(item));
        return history;
      }
    } catch (error) {
      console.error('StorageManager: 获取历史失败', error);
    }

    return createEmptyHistory();
  }

  /**
   * 保存浏览历史
   */
  async saveHistory(history: UserHistory): Promise<void> {
    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.HISTORY, JSON.stringify(history));
      await pref.flush();
      // 更新全局浏览数
      this.updateGlobalHistoryCount(history);
    } catch (error) {
      console.error('StorageManager: 保存历史失败', error);
    }
  }

  /**
   * 更新全局浏览数
   */
  private updateGlobalHistoryCount(history: UserHistory): void {
    // 先删除再创建，强制触发 @StorageLink 更新（即使值相同）
    AppStorage.delete(GlobalStateKeys.HISTORY_COUNT);
    AppStorage.setOrCreate(GlobalStateKeys.HISTORY_COUNT, history.items.length);
  }

  /**
   * 添加浏览历史（神兽，保持向后兼容）
   */
  async addHistory(creatureId: string): Promise<void> {
    await this.addHistoryWithType(creatureId, 'creature');
  }

  /**
   * 添加浏览历史（支持类型）
   */
  async addHistoryWithType(id: string, type: EntryType): Promise<void> {
    const history = await this.getHistory();

    // 移除已存在的相同记录
    history.items = history.items.filter(item => {
      const normalizedItem = normalizeHistoryItem(item);
      return !(normalizedItem.id === id && normalizedItem.type === type);
    });

    // 添加新记录到开头
    const newItem: HistoryItem = {
      id: id,
      type: type,
      timestamp: Date.now()
    };
    history.items.unshift(newItem);

    // 限制数量
    if (history.items.length > history.maxItems) {
      history.items = history.items.slice(0, history.maxItems);
    }

    await this.saveHistory(history);
  }

  /**
   * 清空浏览历史
   */
  async clearHistory(): Promise<void> {
    const history = createEmptyHistory();
    await this.saveHistory(history);
  }

  // ==================== 用户创建的神兽 ====================

  /**
   * 获取用户创建的神兽列表
   */
  async getUserCreatures(): Promise<UserCreature[]> {
    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return [];
    }

    try {
      const data = await pref.get(StorageKeys.USER_CREATURES, '');
      if (data && typeof data === 'string' && data.length > 0) {
        return JSON.parse(data) as UserCreature[];
      }
    } catch (error) {
      console.error('StorageManager: 获取用户神兽失败', error);
    }

    return [];
  }

  /**
   * 保存用户创建的神兽
   */
  async saveUserCreature(creature: UserCreature): Promise<void> {
    const creatures = await this.getUserCreatures();
    creatures.push(creature);

    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.USER_CREATURES, JSON.stringify(creatures));
      await pref.flush();
    } catch (error) {
      console.error('StorageManager: 保存用户神兽失败', error);
    }
  }

  /**
   * 删除用户创建的神兽
   */
  async deleteUserCreature(creatureId: string): Promise<void> {
    let creatures = await this.getUserCreatures();
    creatures = creatures.filter(c => c.id !== creatureId);

    const pref = await this.getPreferences('user_data');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.USER_CREATURES, JSON.stringify(creatures));
      await pref.flush();
    } catch (error) {
      console.error('StorageManager: 删除用户神兽失败', error);
    }
  }

  // ==================== 设置相关 ====================

  /**
   * 获取用户设置
   */
  async getSettings(): Promise<UserSettings> {
    const pref = await this.getPreferences('settings');
    if (!pref) {
      return DefaultUserSettings;
    }

    try {
      const data = await pref.get(StorageKeys.SETTINGS, '');
      if (data && typeof data === 'string' && data.length > 0) {
        const parsed = JSON.parse(data) as UserSettings;
        // 合并默认设置和已保存的设置
        const result: UserSettings = {
          theme: parsed.theme !== undefined ? parsed.theme : DefaultUserSettings.theme,
          autoPlayBanner: parsed.autoPlayBanner !== undefined ? parsed.autoPlayBanner : DefaultUserSettings.autoPlayBanner,
          showEnglishName: parsed.showEnglishName !== undefined ? parsed.showEnglishName : DefaultUserSettings.showEnglishName,
          cacheEnabled: parsed.cacheEnabled !== undefined ? parsed.cacheEnabled : DefaultUserSettings.cacheEnabled,
          enableNotifications: parsed.enableNotifications !== undefined ? parsed.enableNotifications : DefaultUserSettings.enableNotifications,
          enableAiGeneration: parsed.enableAiGeneration !== undefined ? parsed.enableAiGeneration : DefaultUserSettings.enableAiGeneration,
          language: parsed.language !== undefined ? parsed.language : DefaultUserSettings.language
        };
        return result;
      }
    } catch (error) {
      console.error('StorageManager: 获取设置失败', error);
    }

    return DefaultUserSettings;
  }

  /**
   * 保存用户设置
   */
  async saveSettings(settings: UserSettings): Promise<void> {
    const pref = await this.getPreferences('settings');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.SETTINGS, JSON.stringify(settings));
      await pref.flush();
    } catch (error) {
      console.error('StorageManager: 保存设置失败', error);
    }
  }

  /**
   * 更新主题设置
   */
  async updateTheme(value: 'dark' | 'light'): Promise<void> {
    const settings = await this.getSettings();
    settings.theme = value;
    await this.saveSettings(settings);
  }

  /**
   * 更新自动播放设置
   */
  async updateAutoPlayBanner(value: boolean): Promise<void> {
    const settings = await this.getSettings();
    settings.autoPlayBanner = value;
    await this.saveSettings(settings);
  }

  /**
   * 更新显示英文名设置
   */
  async updateShowEnglishName(value: boolean): Promise<void> {
    const settings = await this.getSettings();
    settings.showEnglishName = value;
    await this.saveSettings(settings);
  }

  /**
   * 更新缓存设置
   */
  async updateCacheEnabled(value: boolean): Promise<void> {
    const settings = await this.getSettings();
    settings.cacheEnabled = value;
    await this.saveSettings(settings);
  }

  // ==================== 挑战系统相关 ====================

  /**
   * 获取挑战统计数据
   */
  async getChallengeStats(): Promise<ChallengeStats> {
    const pref = await this.getPreferences('challenge_data');
    if (!pref) {
      return createEmptyChallengeStats();
    }

    try {
      const data = await pref.get(StorageKeys.CHALLENGE_STATS, '');
      if (data && typeof data === 'string' && data.length > 0) {
        return JSON.parse(data) as ChallengeStats;
      }
    } catch (error) {
      console.error('StorageManager: 获取挑战统计失败', error);
    }

    return createEmptyChallengeStats();
  }

  /**
   * 保存挑战统计数据
   */
  async saveChallengeStats(stats: ChallengeStats): Promise<void> {
    const pref = await this.getPreferences('challenge_data');
    if (!pref) {
      return;
    }

    try {
      await pref.put(StorageKeys.CHALLENGE_STATS, JSON.stringify(stats));
      await pref.flush();
      // 更新全局版本号，触发UI刷新
      this.incrementChallengeStatsVersion();
    } catch (error) {
      console.error('StorageManager: 保存挑战统计失败', error);
    }
  }

  /**
   * 递增挑战统计版本号（触发UI刷新）
   */
  private incrementChallengeStatsVersion(): void {
    const currentVersion = AppStorage.get<number>(GlobalStateKeys.CHALLENGE_STATS_VERSION) || 0;
    AppStorage.setOrCreate(GlobalStateKeys.CHALLENGE_STATS_VERSION, currentVersion + 1);
  }

  /**
   * 更新挑战统计（游戏结束后调用）
   */
  async updateChallengeStats(result: QuizResult): Promise<ChallengeUpdateResult> {
    const stats = await this.getChallengeStats();
    const oldTier = stats.currentTier;

    // 更新统计数据
    stats.totalGamesPlayed += 1;
    stats.totalScore += result.totalScore;
    stats.totalCorrectAnswers += result.correctAnswers;
    stats.totalQuestions += result.totalQuestions;
    stats.lastPlayedAt = Date.now();

    // 更新最高分
    if (result.totalScore > stats.highestScore) {
      stats.highestScore = result.totalScore;
    }

    // 更新最大连击
    if (result.maxCombo > stats.maxCombo) {
      stats.maxCombo = result.maxCombo;
    }

    // 更新段位
    const newTierInfo = getTierByScore(stats.totalScore);
    stats.currentTier = newTierInfo.type;
    const tierUp = stats.currentTier !== oldTier;

    // 更新分类统计
    if (result.category) {
      const catStats = stats.categoryStats.find(cs => cs.category === result.category);
      if (catStats) {
        catStats.totalQuestions += result.totalQuestions;
        catStats.correctAnswers += result.correctAnswers;
      } else {
        stats.categoryStats.push({
          category: result.category,
          totalQuestions: result.totalQuestions,
          correctAnswers: result.correctAnswers
        });
      }
    }

    // 检查新成就
    const correctRate = result.totalQuestions > 0 ? (result.correctAnswers / result.totalQuestions) * 100 : 0;
    const newlyUnlocked = checkNewAchievements(stats, result.maxCombo, correctRate);
    const newAchievementIds: string[] = [];

    for (const achievement of newlyUnlocked) {
      // 添加到已解锁成就列表
      const existingIndex = stats.achievements.findIndex(a => a.achievementId === achievement.id);
      if (existingIndex >= 0) {
        stats.achievements[existingIndex].unlocked = true;
        stats.achievements[existingIndex].unlockedAt = Date.now();
      } else {
        stats.achievements.push({
          achievementId: achievement.id,
          unlocked: true,
          unlockedAt: Date.now()
        });
      }
      // 成就奖励积分
      stats.totalScore += achievement.rewardPoints;
      newAchievementIds.push(achievement.id);
    }

    // 保存更新后的统计
    await this.saveChallengeStats(stats);

    const updateResult: ChallengeUpdateResult = {
      newAchievements: newAchievementIds,
      tierUp: tierUp
    } as ChallengeUpdateResult;
    return updateResult;
  }

  /**
   * 获取排行榜数据
   */
  async getLeaderboard(type: LeaderboardType): Promise<LeaderboardData | null> {
    const pref = await this.getPreferences('challenge_data');
    if (!pref) {
      return null;
    }

    try {
      let key: string;
      switch (type) {
        case 'daily':
          key = StorageKeys.LEADERBOARD_DAILY;
          break;
        case 'weekly':
          key = StorageKeys.LEADERBOARD_WEEKLY;
          break;
        default:
          key = StorageKeys.LEADERBOARD_ALLTIME;
      }
      const data = await pref.get(key, '');
      if (data && typeof data === 'string' && data.length > 0) {
        return JSON.parse(data) as LeaderboardData;
      }
    } catch (error) {
      console.error('StorageManager: 获取排行榜失败', error);
    }

    return null;
  }

  /**
   * 保存排行榜数据
   */
  async saveLeaderboard(data: LeaderboardData): Promise<void> {
    const pref = await this.getPreferences('challenge_data');
    if (!pref) {
      return;
    }

    try {
      let key: string;
      switch (data.type) {
        case 'daily':
          key = StorageKeys.LEADERBOARD_DAILY;
          break;
        case 'weekly':
          key = StorageKeys.LEADERBOARD_WEEKLY;
          break;
        default:
          key = StorageKeys.LEADERBOARD_ALLTIME;
      }
      await pref.put(key, JSON.stringify(data));
      await pref.flush();
    } catch (error) {
      console.error('StorageManager: 保存排行榜失败', error);
    }
  }

  // ==================== 故事收藏相关 ====================

  /**
   * 添加故事收藏
   */
  async addStoryFavorite(storyId: string): Promise<void> {
    const favorites = await this.getFavorites();
    if (!favorites.storyIds) {
      favorites.storyIds = [];
    }
    if (!favorites.storyIds.includes(storyId)) {
      favorites.storyIds.push(storyId);
      favorites.updatedAt = Date.now();
      await this.saveFavorites(favorites);
    }
  }

  /**
   * 移除故事收藏
   */
  async removeStoryFavorite(storyId: string): Promise<void> {
    const favorites = await this.getFavorites();
    if (favorites.storyIds) {
      const index = favorites.storyIds.indexOf(storyId);
      if (index > -1) {
        favorites.storyIds.splice(index, 1);
        favorites.updatedAt = Date.now();
        await this.saveFavorites(favorites);
      }
    }
  }

  /**
   * 检查故事是否已收藏
   */
  async isStoryFavorite(storyId: string): Promise<boolean> {
    const favorites = await this.getFavorites();
    return favorites.storyIds?.includes(storyId) ?? false;
  }

  /**
   * 获取故事收藏列表
   */
  async getStoryFavorites(): Promise<string[]> {
    const favorites = await this.getFavorites();
    return favorites.storyIds || [];
  }

  // ==================== 故事阅读进度相关 ====================

  /**
   * 保存故事阅读进度
   */
  async saveStoryProgress(storyId: string, chapterIndex: number): Promise<void> {
    const pref = await this.getPreferences('story_data');
    if (!pref) {
      return;
    }

    try {
      const progressData = await this.getStoryProgressData();
      progressData[storyId] = {
        chapterIndex: chapterIndex,
        timestamp: Date.now()
      };
      await pref.put(StorageKeys.STORY_PROGRESS, JSON.stringify(progressData));
      await pref.flush();
    } catch (error) {
      console.error('StorageManager: 保存故事进度失败', error);
    }
  }

  /**
   * 获取故事阅读进度
   */
  async getStoryProgress(storyId: string): Promise<number> {
    const progressData = await this.getStoryProgressData();
    return progressData[storyId]?.chapterIndex || 0;
  }

  /**
   * 获取所有故事进度数据
   */
  private async getStoryProgressData(): Promise<Record<string, StoryProgressItem>> {
    const pref = await this.getPreferences('story_data');
    if (!pref) {
      return {};
    }

    try {
      const data = await pref.get(StorageKeys.STORY_PROGRESS, '');
      if (data && typeof data === 'string' && data.length > 0) {
        return JSON.parse(data) as Record<string, StoryProgressItem>;
      }
    } catch (error) {
      console.error('StorageManager: 获取故事进度失败', error);
    }

    return {};
  }
}

/**
 * 全局存储管理器实例
 */
export const storageManager = StorageManager.getInstance();

/**
 * 简化的存储工具类（适配页面使用）
 */
export class StorageUtil {
  private static instance: StorageUtil;
  private manager: StorageManager;
  private searchHistory: string[] = [];
  private initialized: boolean = false;

  private constructor() {
    this.manager = StorageManager.getInstance();
  }

  static getInstance(): StorageUtil {
    if (!StorageUtil.instance) {
      StorageUtil.instance = new StorageUtil();
    }
    return StorageUtil.instance;
  }

  async initialize(): Promise<void> {
    if (this.initialized) return;
    try {
      const context = getContext();
      this.manager.init(context);
      // 加载搜索历史
      await this.loadSearchHistory();
      // 初始化全局状态
      await this.initGlobalState();
      this.initialized = true;
    } catch (e) {
      console.warn('StorageUtil: 初始化失败');
    }
  }

  /**
   * 初始化全局状态（收藏数、浏览数、挑战统计版本）
   */
  private async initGlobalState(): Promise<void> {
    try {
      const favorites = await this.manager.getFavorites();
      const favoriteCount = favorites.creatureIds.length + (favorites.deityIds?.length || 0);
      AppStorage.setOrCreate(GlobalStateKeys.FAVORITE_COUNT, favoriteCount);

      const history = await this.manager.getHistory();
      AppStorage.setOrCreate(GlobalStateKeys.HISTORY_COUNT, history.items.length);

      // 初始化挑战统计版本号
      AppStorage.setOrCreate(GlobalStateKeys.CHALLENGE_STATS_VERSION, 0);
    } catch (e) {
      console.warn('StorageUtil: 初始化全局状态失败');
      AppStorage.setOrCreate(GlobalStateKeys.FAVORITE_COUNT, 0);
      AppStorage.setOrCreate(GlobalStateKeys.HISTORY_COUNT, 0);
      AppStorage.setOrCreate(GlobalStateKeys.CHALLENGE_STATS_VERSION, 0);
    }
  }

  // 收藏相关
  async getFavorites(): Promise<string[]> {
    const favorites = await this.manager.getFavorites();
    return favorites.creatureIds;
  }

  async addFavorite(creatureId: string): Promise<void> {
    await this.manager.addFavorite(creatureId);
  }

  async removeFavorite(creatureId: string): Promise<void> {
    await this.manager.removeFavorite(creatureId);
  }

  async isFavorite(creatureId: string): Promise<boolean> {
    return await this.manager.isFavorite(creatureId);
  }

  // 神祇收藏相关
  async getDeityFavorites(): Promise<string[]> {
    return await this.manager.getDeityFavorites();
  }

  async addDeityFavorite(deityId: string): Promise<void> {
    await this.manager.addDeityFavorite(deityId);
  }

  async removeDeityFavorite(deityId: string): Promise<void> {
    await this.manager.removeDeityFavorite(deityId);
  }

  async isDeityFavorite(deityId: string): Promise<boolean> {
    return await this.manager.isDeityFavorite(deityId);
  }

  // 浏览历史相关
  async getBrowsingHistory(): Promise<import('../model/UserData').BrowsingRecord[]> {
    const history = await this.manager.getHistory();
    return history.items;
  }

  async addBrowsingHistory(creatureId: string): Promise<void> {
    await this.manager.addHistory(creatureId);
  }

  async addBrowsingHistoryWithType(id: string, type: EntryType): Promise<void> {
    await this.manager.addHistoryWithType(id, type);
  }

  async clearAllFavorites(): Promise<void> {
    // 清空所有收藏（神兽和神祇）
    try {
      const pref = await preferences.getPreferences(getContext(), 'user_data');
      const emptyFavorites = JSON.stringify({ creatureIds: [], deityIds: [], updatedAt: Date.now() });
      await pref.put(StorageKeys.FAVORITES, emptyFavorites);
      await pref.flush();
      // 更新全局状态
      AppStorage.delete(GlobalStateKeys.FAVORITE_COUNT);
      AppStorage.setOrCreate(GlobalStateKeys.FAVORITE_COUNT, 0);
    } catch (e) {
      console.error('清空收藏失败:', e);
    }
  }

  async clearBrowsingHistory(): Promise<void> {
    // 直接使用 preferences 清除，确保数据被正确删除
    try {
      const pref = await preferences.getPreferences(getContext(), 'user_data');
      const emptyHistory = JSON.stringify({ items: [], maxItems: 100 });
      await pref.put(StorageKeys.HISTORY, emptyHistory);
      await pref.flush();
      // 更新全局状态
      AppStorage.delete(GlobalStateKeys.HISTORY_COUNT);
      AppStorage.setOrCreate(GlobalStateKeys.HISTORY_COUNT, 0);
    } catch (e) {
      console.error('清空浏览历史失败:', e);
    }
  }

  // 搜索历史相关
  private async loadSearchHistory(): Promise<void> {
    try {
      const pref = await preferences.getPreferences(getContext(), 'search_data');
      const data = await pref.get('search_history', '[]');
      if (typeof data === 'string') {
        this.searchHistory = JSON.parse(data);
      }
    } catch (e) {
      this.searchHistory = [];
    }
  }

  async getSearchHistory(): Promise<string[]> {
    return this.searchHistory;
  }

  async addSearchHistory(keyword: string): Promise<void> {
    if (!keyword.trim()) return;
    // 移除重复
    this.searchHistory = this.searchHistory.filter(k => k !== keyword);
    // 添加到开头
    this.searchHistory.unshift(keyword);
    // 限制数量
    if (this.searchHistory.length > 20) {
      this.searchHistory = this.searchHistory.slice(0, 20);
    }
    // 保存
    try {
      const pref = await preferences.getPreferences(getContext(), 'search_data');
      await pref.put('search_history', JSON.stringify(this.searchHistory));
      await pref.flush();
    } catch (e) {
      console.error('保存搜索历史失败');
    }
  }

  async clearSearchHistory(): Promise<void> {
    this.searchHistory = [];
    try {
      const pref = await preferences.getPreferences(getContext(), 'search_data');
      await pref.put('search_history', '[]');
      await pref.flush();
    } catch (e) {
      console.error('清空搜索历史失败');
    }
  }

  // 设置相关
  async getSettings(): Promise<UserSettings> {
    return await this.manager.getSettings();
  }

  async saveSettings(settings: UserSettings): Promise<void> {
    await this.manager.saveSettings(settings);
  }

  // ========== 卡牌收集系统相关 ==========

  /**
   * 获取卡牌收集数据
   */
  async getCardCollection(): Promise<UserCardCollection> {
    try {
      const pref = await preferences.getPreferences(getContext(), 'card_data');
      const data = await pref.get(StorageKeys.CARD_COLLECTION, '');

      if (data && typeof data === 'string' && data.length > 0) {
        const parsed: Record<string, Object> = JSON.parse(data) as Record<string, Object>;
        // 将普通对象转换为Map
        const cards: Map<string, Card> = new Map<string, Card>();
        if (parsed.cards) {
          const cardsObj = parsed.cards as Record<string, Object>;
          const entries = Object.entries(cardsObj);
          for (let i = 0; i < entries.length; i++) {
            const entry = entries[i];
            cards.set(entry[0], entry[1] as Card);
          }
        }

        const collection: UserCardCollection = {
          cards: cards,
          checkInHistory: (parsed.checkInHistory as CheckInRecord[]) || [],
          lastCheckIn: (parsed.lastCheckIn as string) || '',
          consecutiveDays: (parsed.consecutiveDays as number) || 0,
          totalCheckIns: (parsed.totalCheckIns as number) || 0
        };
        return collection;
      }
    } catch (e) {
      console.error('获取卡牌收集数据失败:', e);
    }

    return createEmptyCardCollection();
  }

  /**
   * 保存卡牌收集数据
   */
  async saveCardCollection(collection: UserCardCollection): Promise<void> {
    try {
      const pref = await preferences.getPreferences(getContext(), 'card_data');
      // 将Map转换为普通对象用于序列化
      const cardsObj: Record<string, Card> = {};
      collection.cards.forEach((value: Card, key: string) => {
        cardsObj[key] = value;
      });

      const toSave: CardCollectionSaveData = {
        cards: cardsObj,
        checkInHistory: collection.checkInHistory,
        lastCheckIn: collection.lastCheckIn,
        consecutiveDays: collection.consecutiveDays,
        totalCheckIns: collection.totalCheckIns
      };
      await pref.put(StorageKeys.CARD_COLLECTION, JSON.stringify(toSave));
      await pref.flush();
    } catch (e) {
      console.error('保存卡牌收集数据失败:', e);
    }
  }

  /**
   * 每日签到
   * @param creatures 所有神兽列表
   * @returns 签到记录，包含获得的卡牌
   */
  async dailyCheckIn(creatures: MythicalCreature[]): Promise<CheckInRecord | null> {
    try {
      console.log('[Storage] dailyCheckIn called, creatures:', creatures.length);
      const collection = await this.getCardCollection();
      const today = getTodayString();
      console.log('[Storage] Today:', today, 'Last check-in:', collection.lastCheckIn);

      // 检查今天是否已签到
      if (hasCheckedInToday(collection.lastCheckIn)) {
        console.log('[Storage] Already checked in today');
        return null;
      }

      // 计算连续签到天数
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayString = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`;

      let consecutiveDays = 1;
      if (collection.lastCheckIn === yesterdayString) {
        consecutiveDays = collection.consecutiveDays + 1;
      }
      console.log('[Storage] Consecutive days:', consecutiveDays);

      // 随机抽取一张卡牌
      const drawnCreature = drawRandomCard(creatures);
      console.log('[Storage] Drew creature:', drawnCreature.name.cn, 'Rarity:', drawnCreature.rarity);
      const existingCard = collection.cards.get(drawnCreature.id);

      let newCard: Card;
      if (existingCard) {
        // 已有卡牌，升级
        const upgraded = upgradeCard(existingCard);
        newCard = upgraded || existingCard;
        collection.cards.set(drawnCreature.id, newCard);
      } else {
        // 新卡牌
        newCard = {
          id: drawnCreature.id,
          creatureId: drawnCreature.id,
          rarity: drawnCreature.rarity,
          obtainedAt: Date.now(),
          level: 1,
          duplicates: 0
        };
        collection.cards.set(drawnCreature.id, newCard);
      }

      // 创建签到记录
      const record: CheckInRecord = {
        date: today,
        timestamp: Date.now(),
        reward: newCard,
        consecutive: consecutiveDays
      };

      // 更新收集数据
      collection.checkInHistory.unshift(record);
      if (collection.checkInHistory.length > 30) {
        collection.checkInHistory = collection.checkInHistory.slice(0, 30);
      }
      collection.lastCheckIn = today;
      collection.consecutiveDays = consecutiveDays;
      collection.totalCheckIns += 1;

      console.log('[Storage] Saving collection - consecutive:', collection.consecutiveDays, 'total:', collection.totalCheckIns);
      // 保存
      await this.saveCardCollection(collection);
      console.log('[Storage] Collection saved successfully');

      return record;
    } catch (e) {
      console.error('每日签到失败:', e);
      return null;
    }
  }

  /**
   * 获取卡牌详情
   */
  async getCard(creatureId: string): Promise<Card | null> {
    const collection = await this.getCardCollection();
    return collection.cards.get(creatureId) || null;
  }

  /**
   * 检查今天是否已签到
   */
  async hasTodayCheckedIn(): Promise<boolean> {
    const collection = await this.getCardCollection();
    return hasCheckedInToday(collection.lastCheckIn);
  }

  /**
   * 获取签到历史
   */
  async getCheckInHistory(limit: number = 10): Promise<CheckInRecord[]> {
    const collection = await this.getCardCollection();
    return collection.checkInHistory.slice(0, limit);
  }

  /**
   * 获取卡牌收集统计
   */
  async getCardStats(): Promise<CardStats> {
    const collection = await this.getCardCollection();
    const stats: CardStats = {
      totalCards: 0,
      collectedCards: collection.cards.size,
      completionRate: 0,
      consecutiveDays: collection.consecutiveDays,
      totalCheckIns: collection.totalCheckIns
    };
    return stats;
  }

  // ========== 故事相关 ==========

  /**
   * 获取故事收藏列表
   */
  async getStoryFavorites(): Promise<string[]> {
    return await this.manager.getStoryFavorites();
  }

  /**
   * 添加故事收藏
   */
  async addStoryFavorite(storyId: string): Promise<void> {
    await this.manager.addStoryFavorite(storyId);
  }

  /**
   * 移除故事收藏
   */
  async removeStoryFavorite(storyId: string): Promise<void> {
    await this.manager.removeStoryFavorite(storyId);
  }

  /**
   * 检查故事是否已收藏
   */
  async isStoryFavorite(storyId: string): Promise<boolean> {
    return await this.manager.isStoryFavorite(storyId);
  }

  /**
   * 保存故事阅读进度
   */
  async saveStoryProgress(storyId: string, chapterIndex: number): Promise<void> {
    await this.manager.saveStoryProgress(storyId, chapterIndex);
  }

  /**
   * 获取故事阅读进度
   */
  async getStoryProgress(storyId: string): Promise<number> {
    return await this.manager.getStoryProgress(storyId);
  }

  /**
   * 添加通用收藏项
   */
  async addFavoriteItem(item: FavoriteItem): Promise<void> {
    switch (item.type) {
      case 'creature':
        await this.manager.addFavorite(item.id);
        break;
      case 'deity':
        await this.manager.addDeityFavorite(item.id);
        break;
      case 'story':
        await this.manager.addStoryFavorite(item.id);
        break;
    }
  }

  /**
   * 移除通用收藏项
   */
  async removeFavoriteItem(id: string): Promise<void> {
    // 尝试从所有收藏类型中移除
    await this.manager.removeFavorite(id);
    await this.manager.removeDeityFavorite(id);
    await this.manager.removeStoryFavorite(id);
  }

  /**
   * 添加历史记录（通用方法）
   */
  async addHistoryItem(item: FavoriteItem): Promise<void> {
    await this.manager.addHistoryWithType(item.id, item.type);
  }
}

/**
 * 卡牌统计接口
 */
export interface CardStats {
  totalCards: number;
  collectedCards: number;
  completionRate: number;
  consecutiveDays: number;
  totalCheckIns: number;
}

/**
 * 卡牌收集保存数据接口
 */
interface CardCollectionSaveData {
  cards: Record<string, Card>;
  checkInHistory: CheckInRecord[];
  lastCheckIn: string;
  consecutiveDays: number;
  totalCheckIns: number;
}

/**
 * Storage 类别名（兼容 StoryDetail 等页面使用）
 */
export class Storage {
  private static _instance: StorageUtil | null = null;

  /**
   * 获取单例实例
   */
  static getInstance(): StorageUtil {
    if (!Storage._instance) {
      Storage._instance = StorageUtil.getInstance();
    }
    return Storage._instance;
  }
}
