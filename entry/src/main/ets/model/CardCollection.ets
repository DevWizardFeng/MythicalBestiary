/**
 * 神话志 - 卡牌收集数据模型
 */

import { MythicalCreature } from './MythicalCreature';
import { RarityType } from '../common/Constants';

/**
 * 卡牌数据接口
 */
export interface Card {
  id: string;              // 卡牌ID（与神兽ID一致）
  creatureId: string;      // 对应的神兽ID
  rarity: RarityType;      // 稀有度
  obtainedAt: number;      // 获得时间戳
  level: number;           // 卡牌等级（1-5星）
  duplicates: number;      // 重复获得次数
}

/**
 * 签到记录接口
 */
export interface CheckInRecord {
  date: string;            // 签到日期 (YYYY-MM-DD)
  timestamp: number;       // 签到时间戳
  reward: Card | null;     // 获得的卡牌
  consecutive: number;     // 连续签到天数
}

/**
 * 卡牌收集统计接口
 */
export interface CollectionStats {
  totalCards: number;          // 总卡牌数
  collectedCards: number;      // 已收集卡牌数
  legendaryCards: number;      // 传说卡牌数
  epicCards: number;           // 史诗卡牌数
  rareCards: number;           // 稀有卡牌数
  commonCards: number;         // 普通卡牌数
  totalLevel: number;          // 总等级
  completionRate: number;      // 完成度百分比
}

/**
 * 用户卡牌收集数据接口
 */
export interface UserCardCollection {
  cards: Map<string, Card>;         // 已收集的卡牌 (key: creatureId)
  checkInHistory: CheckInRecord[];  // 签到历史
  lastCheckIn: string;              // 最后签到日期 (YYYY-MM-DD)
  consecutiveDays: number;          // 连续签到天数
  totalCheckIns: number;            // 总签到次数
}

/**
 * 创建空的卡牌收集数据
 */
export function createEmptyCardCollection(): UserCardCollection {
  return {
    cards: new Map(),
    checkInHistory: [],
    lastCheckIn: '',
    consecutiveDays: 0,
    totalCheckIns: 0
  };
}

/**
 * 计算卡牌收集统计
 */
export function calculateCollectionStats(
  collection: UserCardCollection,
  totalCreatures: number
): CollectionStats {
  const cards = Array.from(collection.cards.values());

  return {
    totalCards: totalCreatures,
    collectedCards: cards.length,
    legendaryCards: cards.filter(c => c.rarity === 'legendary').length,
    epicCards: cards.filter(c => c.rarity === 'epic').length,
    rareCards: cards.filter(c => c.rarity === 'rare').length,
    commonCards: cards.filter(c => c.rarity === 'common').length,
    totalLevel: cards.reduce((sum, c) => sum + c.level, 0),
    completionRate: totalCreatures > 0 ? Math.round((cards.length / totalCreatures) * 100) : 0
  };
}

/**
 * 根据稀有度权重随机抽取卡牌
 */
export function drawRandomCard(creatures: MythicalCreature[]): MythicalCreature {
  // 稀有度权重配置
  const rarityWeights: Map<RarityType, number> = new Map([
    ['common', 60],      // 60% 概率
    ['rare', 25],        // 25% 概率
    ['epic', 10],        // 10% 概率
    ['legendary', 5]     // 5% 概率
  ]);

  // 按稀有度分组
  const creaturesByRarity: Map<RarityType, MythicalCreature[]> = new Map();
  creatures.forEach(creature => {
    const rarity = creature.rarity;
    if (!creaturesByRarity.has(rarity)) {
      creaturesByRarity.set(rarity, []);
    }
    const rarityList = creaturesByRarity.get(rarity);
    if (rarityList) {
      rarityList.push(creature);
    }
  });

  // 随机选择稀有度
  const random = Math.random() * 100;
  let accumulated = 0;
  let selectedRarity: RarityType = 'common';

  const rarityEntries: Array<[RarityType, number]> = [
    ['common', 60],
    ['rare', 25],
    ['epic', 10],
    ['legendary', 5]
  ];

  for (let i = 0; i < rarityEntries.length; i++) {
    const entry = rarityEntries[i];
    const rarity = entry[0];
    const weight = entry[1];
    accumulated += weight;
    if (random <= accumulated) {
      selectedRarity = rarity;
      break;
    }
  }

  // 从该稀有度中随机选择一个神兽
  const availableCreatures = creaturesByRarity.get(selectedRarity) || [];
  if (availableCreatures.length === 0) {
    // 如果该稀有度没有神兽，随机返回一个
    return creatures[Math.floor(Math.random() * creatures.length)];
  }

  return availableCreatures[Math.floor(Math.random() * availableCreatures.length)];
}

/**
 * 升级卡牌
 * @returns 升级后的卡牌，如果已达最大等级则返回null
 */
export function upgradeCard(card: Card): Card | null {
  const maxLevel = 5;
  if (card.level >= maxLevel) {
    return null;
  }

  const upgraded: Card = {
    id: card.id,
    creatureId: card.creatureId,
    rarity: card.rarity,
    obtainedAt: card.obtainedAt,
    level: card.level + 1,
    duplicates: card.duplicates + 1
  };
  return upgraded;
}

/**
 * 检查今天是否已签到
 */
export function hasCheckedInToday(lastCheckIn: string): boolean {
  const today = getTodayString();
  return lastCheckIn === today;
}

/**
 * 获取今天的日期字符串 (YYYY-MM-DD)
 */
export function getTodayString(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * 计算连续签到天数
 */
export function calculateConsecutiveDays(lastCheckIn: string): number {
  if (!lastCheckIn) {
    return 0;
  }

  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const lastDate = new Date(lastCheckIn);
  const todayString = getTodayString();
  const yesterdayString = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`;

  // 如果最后签到是今天或昨天，连续
  if (lastCheckIn === todayString || lastCheckIn === yesterdayString) {
    return 1;
  }

  // 否则中断
  return 0;
}

/**
 * 获取稀有度的中文名称
 */
export function getRarityChineseName(rarity: RarityType): string {
  const names: Map<RarityType, string> = new Map([
    ['common', '普通'],
    ['rare', '稀有'],
    ['epic', '史诗'],
    ['legendary', '传说']
  ]);
  return names.get(rarity) || '普通';
}

/**
 * 获取稀有度颜色
 */
export function getRarityCardColor(rarity: RarityType): string {
  const colors: Map<RarityType, string> = new Map([
    ['common', '#9e9e9e'],
    ['rare', '#2196f3'],
    ['epic', '#9c27b0'],
    ['legendary', '#ff9800']
  ]);
  return colors.get(rarity) || '#9e9e9e';
}
