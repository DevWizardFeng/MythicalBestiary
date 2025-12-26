/**
 * 神话志 - 本地存储工具
 */

import preferences from '@ohos.data.preferences';
import { StorageKeys } from '../common/Constants';
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
   * 获取Preferences实例
   */
  private async getPreferences(name: string): Promise<preferences.Preferences | null> {
    if (!this.context) {
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
    } catch (error) {
      console.error('StorageManager: 保存收藏失败', error);
    }
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
    } catch (error) {
      console.error('StorageManager: 保存历史失败', error);
    }
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
      this.initialized = true;
    } catch (e) {
      console.warn('StorageUtil: 初始化失败');
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

  async clearBrowsingHistory(): Promise<void> {
    await this.manager.clearHistory();
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
}
