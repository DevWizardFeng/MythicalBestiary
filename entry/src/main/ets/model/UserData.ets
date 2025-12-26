/**
 * 神话志 - 用户数据模型
 */

/**
 * 条目类型：神兽或神祇
 */
export type EntryType = 'creature' | 'deity';

/**
 * 用户收藏数据
 */
export interface UserFavorites {
  creatureIds: string[];     // 收藏的神兽ID列表
  deityIds: string[];        // 收藏的神祇ID列表
  updatedAt: number;         // 最后更新时间戳
}

/**
 * 浏览历史项
 */
export interface HistoryItem {
  id: string;                // 条目ID（神兽或神祇）
  type: EntryType;           // 条目类型
  timestamp: number;         // 浏览时间戳
  // 向后兼容：旧版本数据可能只有creatureId
  creatureId?: string;
}

/**
 * 浏览记录（HistoryItem的别名）
 */
export type BrowsingRecord = HistoryItem;

/**
 * 用户浏览历史
 */
export interface UserHistory {
  items: HistoryItem[];
  maxItems: number;          // 最大保存数量
}

/**
 * 用户创建的神兽配置
 */
export interface UserCreatureConfig {
  generationType: 'ai' | 'manual';
  culture?: string;
  type?: string;
  primaryAttribute?: string;
  secondaryAttribute?: string;
  alignment?: string;
  colorScheme?: string;
  features?: string[];
  prompt?: string;
}

/**
 * 用户创建的神兽
 */
export interface UserCreature {
  id: string;                      // 用户神兽ID
  name: string;                    // 用户给神兽起的名字
  config: UserCreatureConfig;      // 配置
  story?: string;                  // 用户自定义传说
  imageBase64?: string;            // 图片Base64编码
  createdAt: number;               // 创建时间戳
}

/**
 * 用户设置
 */
export interface UserSettings {
  theme: 'dark' | 'light';         // 主题模式
  autoPlayBanner: boolean;         // 自动播放轮播
  showEnglishName: boolean;        // 显示英文名
  cacheEnabled: boolean;           // 启用缓存
  enableNotifications?: boolean;   // 是否开启通知（可选）
  enableAiGeneration?: boolean;    // 是否启用AI生成（可选）
  language?: 'zh' | 'en';          // 语言设置（可选）
}

/**
 * 默认用户设置
 */
export const DefaultUserSettings: UserSettings = {
  theme: 'dark',
  autoPlayBanner: true,
  showEnglishName: true,
  cacheEnabled: true,
  enableNotifications: true,
  enableAiGeneration: true,
  language: 'zh'
};

/**
 * 每日占卜结果
 */
export interface DivinationResult {
  date: string;                    // 日期 (YYYY-MM-DD)
  creatureId?: string;             // 抽中的神兽ID（可选）
  deityId?: string;                // 抽中的神祇ID（可选）
  divinationType: 'creature' | 'deity';  // 占卜类型
  fortune: FortuneLevel;           // 运势等级
  description: string;             // 运势描述
  luckyColor: string;              // 幸运色
  luckyNumber: number;             // 幸运数字
}

/**
 * 运势等级
 */
export type FortuneLevel = 'great_luck' | 'luck' | 'medium_luck' | 'small_luck' | 'neutral' | 'small_bad' | 'bad';

/**
 * 运势等级名称Map
 */
const FortuneLevelNamesMap: Map<string, string> = new Map([
  ['great_luck', '大吉'],
  ['luck', '吉'],
  ['medium_luck', '中吉'],
  ['small_luck', '小吉'],
  ['neutral', '平'],
  ['small_bad', '小凶'],
  ['bad', '凶']
]);

/**
 * 获取运势等级名称
 */
export function getFortuneLevelName(level: FortuneLevel): string {
  return FortuneLevelNamesMap.get(level) || '未知';
}

/**
 * 运势等级颜色Map
 */
const FortuneLevelColorsMap: Map<string, string> = new Map([
  ['great_luck', '#ffd700'],
  ['luck', '#4caf50'],
  ['medium_luck', '#8bc34a'],
  ['small_luck', '#cddc39'],
  ['neutral', '#9e9e9e'],
  ['small_bad', '#ff9800'],
  ['bad', '#f44336']
]);

/**
 * 获取运势等级颜色
 */
export function getFortuneLevelColor(level: FortuneLevel): string {
  return FortuneLevelColorsMap.get(level) || '#9e9e9e';
}

/**
 * 属性测试答案
 */
export interface AttributeTestAnswer {
  questionId: number;
  selectedOption: number;
}

/**
 * 属性测试结果
 */
export interface AttributeTestResult {
  attribute: string;               // 测出的属性
  score: number;                   // 分数
  description: string;             // 描述
  recommendedCreatures: string[];  // 推荐的守护神兽ID
  completedAt: number;             // 完成时间戳
}

/**
 * 守护神祇测试结果
 */
export interface DeityTestResult {
  deityId: string;                 // 匹配的守护神祇ID
  domains: string[];               // 匹配的神职领域
  matchScore: number;              // 匹配分数
  description: string;             // 结果描述
  completedAt: number;             // 完成时间戳
}

/**
 * 创建空的用户收藏
 */
export function createEmptyFavorites(): UserFavorites {
  return {
    creatureIds: [],
    deityIds: [],
    updatedAt: Date.now()
  };
}

/**
 * 创建空的浏览历史
 */
export function createEmptyHistory(): UserHistory {
  return {
    items: [],
    maxItems: 100
  };
}

/**
 * 添加到收藏
 */
export function addToFavorites(favorites: UserFavorites, creatureId: string): UserFavorites {
  if (!favorites.creatureIds.includes(creatureId)) {
    return {
      creatureIds: [...favorites.creatureIds, creatureId],
      deityIds: favorites.deityIds || [],
      updatedAt: Date.now()
    };
  }
  return favorites;
}

/**
 * 从收藏移除
 */
export function removeFromFavorites(favorites: UserFavorites, creatureId: string): UserFavorites {
  return {
    creatureIds: favorites.creatureIds.filter(id => id !== creatureId),
    deityIds: favorites.deityIds || [],
    updatedAt: Date.now()
  };
}

/**
 * 检查是否已收藏
 */
export function isFavorite(favorites: UserFavorites, creatureId: string): boolean {
  return favorites.creatureIds.includes(creatureId);
}

/**
 * 添加神祇到收藏
 */
export function addDeityToFavorites(favorites: UserFavorites, deityId: string): UserFavorites {
  const deityIds = favorites.deityIds || [];
  if (!deityIds.includes(deityId)) {
    return {
      creatureIds: favorites.creatureIds,
      deityIds: [...deityIds, deityId],
      updatedAt: Date.now()
    };
  }
  return favorites;
}

/**
 * 从收藏移除神祇
 */
export function removeDeityFromFavorites(favorites: UserFavorites, deityId: string): UserFavorites {
  const deityIds = favorites.deityIds || [];
  return {
    creatureIds: favorites.creatureIds,
    deityIds: deityIds.filter(id => id !== deityId),
    updatedAt: Date.now()
  };
}

/**
 * 检查神祇是否已收藏
 */
export function isDeityFavorite(favorites: UserFavorites, deityId: string): boolean {
  const deityIds = favorites.deityIds || [];
  return deityIds.includes(deityId);
}

/**
 * 添加浏览历史（旧版本，保持向后兼容）
 */
export function addToHistory(history: UserHistory, creatureId: string): UserHistory {
  // 使用新的类型化函数
  return addToHistoryWithType(history, creatureId, 'creature');
}

/**
 * 添加浏览历史（支持类型）
 */
export function addToHistoryWithType(history: UserHistory, id: string, type: EntryType): UserHistory {
  // 移除已存在的相同记录（兼容新旧数据格式）
  const filteredItems = history.items.filter(item => {
    // 新格式：检查id和type
    if (item.id && item.type) {
      return !(item.id === id && item.type === type);
    }
    // 旧格式：检查creatureId（只对creature类型生效）
    if (item.creatureId && type === 'creature') {
      return item.creatureId !== id;
    }
    return true;
  });

  // 创建新记录（新格式）
  const newItem: HistoryItem = {
    id: id,
    type: type,
    timestamp: Date.now()
  };

  // 添加新记录到开头
  const newItems: HistoryItem[] = [newItem];
  for (const item of filteredItems) {
    newItems.push(item);
  }

  // 限制数量
  const limitedItems = newItems.slice(0, history.maxItems);

  const result: UserHistory = {
    items: limitedItems,
    maxItems: history.maxItems
  };
  return result;
}

/**
 * 规范化历史记录项（将旧格式转换为新格式）
 */
export function normalizeHistoryItem(item: HistoryItem): HistoryItem {
  // 如果已经是新格式，直接返回
  if (item.id && item.type) {
    return item;
  }
  // 将旧格式转换为新格式
  if (item.creatureId) {
    return {
      id: item.creatureId,
      type: 'creature',
      timestamp: item.timestamp
    };
  }
  // 无法识别的格式，返回原始数据
  return item;
}

/**
 * 清空浏览历史
 */
export function clearHistory(history: UserHistory): UserHistory {
  const result: UserHistory = {
    items: [],
    maxItems: history.maxItems
  };
  return result;
}
