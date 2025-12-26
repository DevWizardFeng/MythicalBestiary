/**
 * 神话志 - 神兽数据模型
 */

import { AttributeType, CultureType, CreatureType, AlignmentType, RarityType } from '../common/Constants';

/**
 * 神兽名称接口
 */
export interface CreatureName {
  original: string;  // 原文名称
  cn: string;        // 中文名称
  en: string;        // 英文名称
}

/**
 * 神兽属性接口
 */
export interface CreatureAttributes {
  primary: AttributeType;      // 主属性
  secondary?: AttributeType;   // 副属性（可选）
}

/**
 * 神兽外观接口
 */
export interface CreatureAppearance {
  bodyParts: string[];    // 身体部位描述
  colors: string[];       // 主要颜色
  features: string[];     // 关键特征
}

/**
 * 著名故事接口
 */
export interface FamousStory {
  title: string;          // 故事标题
  description: string;    // 故事描述
}

/**
 * 神兽数据模型
 */
export interface MythicalCreature {
  // 基本标识
  id: string;

  // 名称（三语）
  name: CreatureName;

  // 分类信息
  culture: CultureType;
  type: CreatureType;

  // 属性和阵营
  attributes: CreatureAttributes;
  alignment: AlignmentType;
  rarity: RarityType;

  // 内容信息
  description: string;          // 简短描述
  mythology: string;            // 完整神话传说
  abilities: string[];          // 能力ID数组
  symbolism: string;            // 象征意义

  // 著名传说
  famousStories: FamousStory[];

  // 外观信息
  appearance: CreatureAppearance;

  // 资源和关联
  image: string;                // 图片文件名
  related: string[];            // 相关神兽ID
  tags: string[];               // 搜索标签
}

/**
 * 神兽简要信息（用于列表展示）
 */
export interface CreatureBrief {
  id: string;
  name: CreatureName;
  culture: CultureType;
  type: CreatureType;
  primaryAttribute: AttributeType;
  rarity: RarityType;
  image: string;
}

/**
 * 从完整神兽数据提取简要信息
 */
export function toCreatureBrief(creature: MythicalCreature): CreatureBrief {
  return {
    id: creature.id,
    name: creature.name,
    culture: creature.culture,
    type: creature.type,
    primaryAttribute: creature.attributes.primary,
    rarity: creature.rarity,
    image: creature.image
  };
}

/**
 * 神兽筛选条件
 */
export interface CreatureFilter {
  culture?: CultureType;
  type?: CreatureType;
  attribute?: AttributeType;
  alignment?: AlignmentType;
  rarity?: RarityType;
  keyword?: string;
}

/**
 * 筛选神兽列表
 */
export function filterCreatures(creatures: MythicalCreature[], filter: CreatureFilter): MythicalCreature[] {
  return creatures.filter(creature => {
    // 文化筛选
    if (filter.culture && creature.culture !== filter.culture) {
      return false;
    }
    // 类型筛选
    if (filter.type && creature.type !== filter.type) {
      return false;
    }
    // 属性筛选
    if (filter.attribute) {
      if (creature.attributes.primary !== filter.attribute &&
        creature.attributes.secondary !== filter.attribute) {
        return false;
      }
    }
    // 阵营筛选
    if (filter.alignment && creature.alignment !== filter.alignment) {
      return false;
    }
    // 稀有度筛选
    if (filter.rarity && creature.rarity !== filter.rarity) {
      return false;
    }
    // 关键词搜索
    if (filter.keyword) {
      const keyword = filter.keyword.toLowerCase();
      const matchName = creature.name.cn.toLowerCase().includes(keyword) ||
        creature.name.en.toLowerCase().includes(keyword) ||
        creature.name.original.toLowerCase().includes(keyword);
      const matchTags = creature.tags.some(tag => tag.toLowerCase().includes(keyword));
      const matchDesc = creature.description.toLowerCase().includes(keyword);
      if (!matchName && !matchTags && !matchDesc) {
        return false;
      }
    }
    return true;
  });
}

/**
 * 按稀有度排序权重
 */
const rarityWeightMap: Map<string, number> = new Map([
  ['legendary', 4],
  ['epic', 3],
  ['rare', 2],
  ['common', 1]
]);

function getRarityWeight(rarity: RarityType): number {
  return rarityWeightMap.get(rarity) || 1;
}

/**
 * 排序类型
 */
export type SortType = 'name' | 'rarity' | 'culture';

/**
 * 排序神兽列表
 */
export function sortCreatures(creatures: MythicalCreature[], sortBy: SortType, ascending: boolean = true): MythicalCreature[] {
  const sorted = [...creatures].sort((a, b) => {
    let compare = 0;
    switch (sortBy) {
      case 'name':
        compare = a.name.cn.localeCompare(b.name.cn, 'zh-CN');
        break;
      case 'rarity':
        compare = getRarityWeight(b.rarity) - getRarityWeight(a.rarity);
        break;
      case 'culture':
        compare = a.culture.localeCompare(b.culture);
        break;
    }
    return ascending ? compare : -compare;
  });
  return sorted;
}
