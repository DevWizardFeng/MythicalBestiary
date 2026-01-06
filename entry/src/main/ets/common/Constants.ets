/**
 * 神话志 - 全局常量定义
 */

/**
 * 属性类型
 */
export type AttributeType = 'fire' | 'water' | 'wind' | 'thunder' | 'light' | 'dark' | 'nature';

/**
 * 文化类型
 */
export type CultureType = 'chinese' | 'greek' | 'norse' | 'japanese' | 'indian' | 'egyptian' | 'celtic';

/**
 * 生物类型
 */
export type CreatureType = 'dragon' | 'phoenix' | 'beast' | 'spirit' | 'giant' | 'undead';

/**
 * 阵营类型
 */
export type AlignmentType = 'guardian' | 'neutral' | 'evil';

/**
 * 稀有度类型
 */
export type RarityType = 'legendary' | 'epic' | 'rare' | 'common';

/**
 * 颜色配对接口
 */
export interface ColorPair {
  primary: string;
  secondary: string;
}

/**
 * 名称配对接口
 */
export interface NamePair {
  cn: string;
  en: string;
}

/**
 * 文化名称接口
 */
export interface CultureNameInfo {
  cn: string;
  en: string;
  region: string;
}

/**
 * 稀有度信息接口
 */
export interface RarityInfo {
  cn: string;
  en: string;
  stars: number;
}

/**
 * 属性配色
 */
export const AttributeColors: Map<string, ColorPair> = new Map([
  ['fire', { primary: '#ff4500', secondary: '#ff8c00' } as ColorPair],
  ['water', { primary: '#1e90ff', secondary: '#00ced1' } as ColorPair],
  ['wind', { primary: '#7fffd4', secondary: '#98fb98' } as ColorPair],
  ['thunder', { primary: '#9370db', secondary: '#8a2be2' } as ColorPair],
  ['light', { primary: '#ffd700', secondary: '#ffffe0' } as ColorPair],
  ['dark', { primary: '#2f4f4f', secondary: '#191970' } as ColorPair],
  ['nature', { primary: '#228b22', secondary: '#3cb371' } as ColorPair]
]);

/**
 * 获取属性颜色
 */
export function getAttributeColor(attr: AttributeType): ColorPair {
  return AttributeColors.get(attr) || { primary: '#888888', secondary: '#666666' } as ColorPair;
}

/**
 * 属性中文名称
 */
export const AttributeNames: Map<string, NamePair> = new Map([
  ['fire', { cn: '火', en: 'Fire' } as NamePair],
  ['water', { cn: '水', en: 'Water' } as NamePair],
  ['wind', { cn: '风', en: 'Wind' } as NamePair],
  ['thunder', { cn: '雷', en: 'Thunder' } as NamePair],
  ['light', { cn: '光', en: 'Light' } as NamePair],
  ['dark', { cn: '暗', en: 'Dark' } as NamePair],
  ['nature', { cn: '自然', en: 'Nature' } as NamePair]
]);

/**
 * 获取属性名称
 */
export function getAttributeName(attr: AttributeType): NamePair {
  return AttributeNames.get(attr) || { cn: '未知', en: 'Unknown' } as NamePair;
}

/**
 * 属性相克关系
 */
export const AttributeStrengths: Map<string, AttributeType[]> = new Map([
  ['fire', ['nature', 'wind']],
  ['water', ['fire']],
  ['wind', ['thunder']],
  ['thunder', ['water']],
  ['light', ['dark']],
  ['dark', ['light']],
  ['nature', ['water']]
]);

/**
 * 文化配色
 */
export const CultureColors: Map<string, string> = new Map([
  ['chinese', '#d4af37'],
  ['greek', '#4169e1'],
  ['norse', '#4682b4'],
  ['japanese', '#dc143c'],
  ['indian', '#ff8c00'],
  ['egyptian', '#daa520'],
  ['celtic', '#228b22']
]);

/**
 * 获取文化颜色
 */
export function getCultureColor(culture: CultureType): string {
  return CultureColors.get(culture) || '#888888';
}

/**
 * 文化中文名称
 */
export const CultureNames: Map<string, CultureNameInfo> = new Map([
  ['chinese', { cn: '中国神话', en: 'Chinese Mythology', region: '中国' } as CultureNameInfo],
  ['greek', { cn: '希腊神话', en: 'Greek Mythology', region: '希腊' } as CultureNameInfo],
  ['norse', { cn: '北欧神话', en: 'Norse Mythology', region: '北欧' } as CultureNameInfo],
  ['japanese', { cn: '日本神话', en: 'Japanese Mythology', region: '日本' } as CultureNameInfo],
  ['indian', { cn: '印度神话', en: 'Indian Mythology', region: '印度' } as CultureNameInfo],
  ['egyptian', { cn: '埃及神话', en: 'Egyptian Mythology', region: '埃及' } as CultureNameInfo],
  ['celtic', { cn: '凯尔特神话', en: 'Celtic Mythology', region: '凯尔特' } as CultureNameInfo]
]);

/**
 * 获取文化名称
 */
export function getCultureName(culture: CultureType): CultureNameInfo {
  return CultureNames.get(culture) || { cn: '未知', en: 'Unknown', region: '未知' } as CultureNameInfo;
}

/**
 * 生物类型名称
 */
export const CreatureTypeNames: Map<string, NamePair> = new Map([
  ['dragon', { cn: '龙族', en: 'Dragon' } as NamePair],
  ['phoenix', { cn: '神鸟', en: 'Phoenix' } as NamePair],
  ['beast', { cn: '魔兽', en: 'Beast' } as NamePair],
  ['spirit', { cn: '精灵', en: 'Spirit' } as NamePair],
  ['giant', { cn: '巨人', en: 'Giant' } as NamePair],
  ['undead', { cn: '不死', en: 'Undead' } as NamePair]
]);

/**
 * 获取生物类型名称
 */
export function getCreatureTypeName(type: CreatureType): NamePair {
  return CreatureTypeNames.get(type) || { cn: '未知', en: 'Unknown' } as NamePair;
}

/**
 * 阵营名称
 */
export const AlignmentNames: Map<string, NamePair> = new Map([
  ['guardian', { cn: '守护', en: 'Guardian' } as NamePair],
  ['neutral', { cn: '中立', en: 'Neutral' } as NamePair],
  ['evil', { cn: '灾厄', en: 'Evil' } as NamePair]
]);

/**
 * 获取阵营名称
 */
export function getAlignmentName(alignment: AlignmentType): NamePair {
  return AlignmentNames.get(alignment) || { cn: '未知', en: 'Unknown' } as NamePair;
}

/**
 * 稀有度配色
 */
export const RarityColors: Map<string, string> = new Map([
  ['legendary', '#ffd700'],
  ['epic', '#9d4edd'],
  ['rare', '#4cc9f0'],
  ['common', '#9e9e9e']
]);

/**
 * 获取稀有度颜色
 */
export function getRarityColor(rarity: RarityType): string {
  return RarityColors.get(rarity) || '#888888';
}

/**
 * 稀有度名称
 */
export const RarityNames: Map<string, RarityInfo> = new Map([
  ['legendary', { cn: '传说', en: 'Legendary', stars: 5 } as RarityInfo],
  ['epic', { cn: '史诗', en: 'Epic', stars: 4 } as RarityInfo],
  ['rare', { cn: '稀有', en: 'Rare', stars: 3 } as RarityInfo],
  ['common', { cn: '普通', en: 'Common', stars: 2 } as RarityInfo]
]);

/**
 * 获取稀有度名称
 */
export function getRarityName(rarity: RarityType): RarityInfo {
  return RarityNames.get(rarity) || { cn: '未知', en: 'Unknown', stars: 0 } as RarityInfo;
}

/**
 * 应用尺寸常量
 */
export class AppDimensions {
  static readonly CARD_WIDTH: number = 160;
  static readonly CARD_HEIGHT: number = 200;
  static readonly CARD_BORDER_RADIUS: number = 12;
  static readonly ICON_SMALL: number = 16;
  static readonly ICON_MEDIUM: number = 24;
  static readonly ICON_LARGE: number = 32;
  static readonly SPACING_XS: number = 4;
  static readonly SPACING_SM: number = 8;
  static readonly SPACING_MD: number = 16;
  static readonly SPACING_LG: number = 24;
  static readonly SPACING_XL: number = 32;
  static readonly FONT_XS: number = 10;
  static readonly FONT_SM: number = 12;
  static readonly FONT_MD: number = 14;
  static readonly FONT_LG: number = 16;
  static readonly FONT_XL: number = 20;
  static readonly FONT_XXL: number = 24;
  static readonly FONT_TITLE: number = 28;
  static readonly TAB_BAR_HEIGHT: number = 56;
  static readonly STATUS_BAR_HEIGHT: number = 48;
}

/**
 * 存储键常量
 */
export class StorageKeys {
  static readonly FAVORITES: string = 'favorites';
  static readonly HISTORY: string = 'history';
  static readonly USER_CREATURES: string = 'user_creatures';
  static readonly SETTINGS: string = 'settings';
  static readonly THEME: string = 'theme';
  // 挑战系统相关
  static readonly CHALLENGE_STATS: string = 'challenge_stats';
  static readonly LEADERBOARD_DAILY: string = 'leaderboard_daily';
  static readonly LEADERBOARD_WEEKLY: string = 'leaderboard_weekly';
  static readonly LEADERBOARD_ALLTIME: string = 'leaderboard_alltime';
  static readonly QUIZ_HISTORY: string = 'quiz_history';
  // 卡牌收集系统相关
  static readonly CARD_COLLECTION: string = 'card_collection';
  static readonly CHECK_IN_HISTORY: string = 'check_in_history';
  static readonly LAST_CHECK_IN: string = 'last_check_in';
  static readonly CONSECUTIVE_DAYS: string = 'consecutive_days';
  // 故事阅读相关
  static readonly STORY_PROGRESS: string = 'story_progress';
}

/**
 * AppStorage 全局状态键常量
 */
export class GlobalStateKeys {
  static readonly FAVORITE_COUNT: string = 'globalFavoriteCount';
  static readonly HISTORY_COUNT: string = 'globalHistoryCount';
  static readonly CHALLENGE_STATS_VERSION: string = 'challengeStatsVersion';
}

/**
 * 路由路径常量
 */
export class RouterPaths {
  static readonly INDEX: string = 'pages/Index';
  static readonly HOME: string = 'pages/Home';
  static readonly CREATURE_LIST: string = 'pages/CreatureList';
  static readonly CREATURE_DETAIL: string = 'pages/CreatureDetail';
  static readonly DEITY_LIST: string = 'pages/DeityList';
  static readonly DEITY_DETAIL: string = 'pages/DeityDetail';
  static readonly SEARCH: string = 'pages/Search';
  static readonly ENCYCLOPEDIA: string = 'pages/Encyclopedia';
  static readonly ATTRIBUTE_DETAIL: string = 'pages/AttributeDetail';
  static readonly CULTURE_DETAIL: string = 'pages/CultureDetail';
  static readonly ABILITY_LIST: string = 'pages/AbilityList';
  static readonly MINE: string = 'pages/Mine';
  static readonly FAVORITES: string = 'pages/Favorites';
  static readonly HISTORY: string = 'pages/History';
  static readonly SETTINGS: string = 'pages/Settings';
  static readonly DAILY_DIVINATION: string = 'pages/DailyDivination';
  static readonly ATTRIBUTE_TEST: string = 'pages/AttributeTest';
  static readonly TOPIC_LIST: string = 'pages/TopicList';
  static readonly TOPIC_DETAIL: string = 'pages/TopicDetail';
  // 挑战系统相关
  static readonly QUIZ_GAME: string = 'pages/QuizGame';
  static readonly QUIZ_RESULT: string = 'pages/QuizResult';
  static readonly LEADERBOARD: string = 'pages/Leaderboard';
  static readonly ACHIEVEMENTS: string = 'pages/Achievements';
}
