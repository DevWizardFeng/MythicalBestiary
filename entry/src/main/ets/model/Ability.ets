/**
 * 神话志 - 能力数据模型
 */

import { AttributeType } from '../common/Constants';

/**
 * 能力分类
 */
export type AbilityCategory = 'elemental' | 'physical' | 'mental' | 'special';

/**
 * 能力使用示例
 */
export interface AbilityUsage {
  creatureId: string;      // 使用该能力的神兽ID
  description: string;     // 使用说明
}

/**
 * 能力数据模型
 */
export interface Ability {
  id: string;
  nameCn: string;
  nameEn: string;
  category: AbilityCategory;
  description: string;
  attribute?: AttributeType;        // 关联属性（可选）
  famousUsage: AbilityUsage[];      // 著名使用者
}

/**
 * 能力分类名称接口
 */
export interface AbilityCategoryNameInfo {
  cn: string;
  en: string;
}

/**
 * 能力分类名称Map
 */
const AbilityCategoryNamesMap: Map<string, AbilityCategoryNameInfo> = new Map([
  ['elemental', { cn: '元素操控', en: 'Elemental' } as AbilityCategoryNameInfo],
  ['physical', { cn: '物理能力', en: 'Physical' } as AbilityCategoryNameInfo],
  ['mental', { cn: '精神能力', en: 'Mental' } as AbilityCategoryNameInfo],
  ['special', { cn: '特殊天赋', en: 'Special' } as AbilityCategoryNameInfo]
]);

/**
 * 获取能力分类名称
 */
export function getAbilityCategoryName(category: AbilityCategory): AbilityCategoryNameInfo {
  return AbilityCategoryNamesMap.get(category) || { cn: '未知', en: 'Unknown' };
}

/**
 * 能力分类颜色Map
 */
const AbilityCategoryColorsMap: Map<string, string> = new Map([
  ['elemental', '#ff6b6b'],
  ['physical', '#4ecdc4'],
  ['mental', '#a66cff'],
  ['special', '#ffd93d']
]);

/**
 * 获取能力分类颜色
 */
export function getAbilityCategoryColor(category: AbilityCategory): string {
  return AbilityCategoryColorsMap.get(category) || '#9e9e9e';
}

/**
 * 按分类获取能力
 */
export function getAbilitiesByCategory(abilities: Ability[], category: AbilityCategory): Ability[] {
  return abilities.filter(ability => ability.category === category);
}

/**
 * 按属性获取能力
 */
export function getAbilitiesByAttribute(abilities: Ability[], attribute: AttributeType): Ability[] {
  return abilities.filter(ability => ability.attribute === attribute);
}

/**
 * 搜索能力
 */
export function searchAbilities(abilities: Ability[], keyword: string): Ability[] {
  const lowerKeyword = keyword.toLowerCase();
  return abilities.filter(ability =>
    ability.nameCn.toLowerCase().includes(lowerKeyword) ||
    ability.nameEn.toLowerCase().includes(lowerKeyword) ||
    ability.description.toLowerCase().includes(lowerKeyword)
  );
}

/**
 * 预定义的常见能力列表
 */
export const CommonAbilities: Ability[] = [
  {
    id: 'ability_fire_breath',
    nameCn: '火焰吐息',
    nameEn: 'Fire Breath',
    category: 'elemental',
    description: '喷射高温火焰的能力，可造成大范围伤害',
    attribute: 'fire',
    famousUsage: []
  },
  {
    id: 'ability_flight',
    nameCn: '飞行',
    nameEn: 'Flight',
    category: 'physical',
    description: '在空中自由飞翔的能力',
    famousUsage: []
  },
  {
    id: 'ability_immortality',
    nameCn: '不死',
    nameEn: 'Immortality',
    category: 'special',
    description: '永生不死或浴火重生的能力',
    famousUsage: []
  },
  {
    id: 'ability_shapeshifting',
    nameCn: '变形',
    nameEn: 'Shapeshifting',
    category: 'special',
    description: '改变自身外形的能力',
    famousUsage: []
  },
  {
    id: 'ability_telepathy',
    nameCn: '心灵感应',
    nameEn: 'Telepathy',
    category: 'mental',
    description: '感知和传递思想的能力',
    famousUsage: []
  },
  {
    id: 'ability_lightning',
    nameCn: '闪电',
    nameEn: 'Lightning',
    category: 'elemental',
    description: '召唤和操控雷电的能力',
    attribute: 'thunder',
    famousUsage: []
  },
  {
    id: 'ability_ice_control',
    nameCn: '冰霜操控',
    nameEn: 'Ice Control',
    category: 'elemental',
    description: '操控寒冰和霜冻的能力',
    attribute: 'water',
    famousUsage: []
  },
  {
    id: 'ability_regeneration',
    nameCn: '再生',
    nameEn: 'Regeneration',
    category: 'physical',
    description: '快速恢复伤口和断肢的能力',
    famousUsage: []
  },
  {
    id: 'ability_petrification',
    nameCn: '石化',
    nameEn: 'Petrification',
    category: 'special',
    description: '将目标化为石像的能力',
    famousUsage: []
  },
  {
    id: 'ability_prophecy',
    nameCn: '预言',
    nameEn: 'Prophecy',
    category: 'mental',
    description: '预知未来的能力',
    famousUsage: []
  },
  {
    id: 'ability_invisibility',
    nameCn: '隐身',
    nameEn: 'Invisibility',
    category: 'special',
    description: '使自身完全隐形的能力',
    famousUsage: []
  },
  {
    id: 'ability_super_strength',
    nameCn: '超级力量',
    nameEn: 'Super Strength',
    category: 'physical',
    description: '拥有远超常人的力量',
    famousUsage: []
  },
  {
    id: 'ability_light_manipulation',
    nameCn: '光明操控',
    nameEn: 'Light Manipulation',
    category: 'elemental',
    description: '操控光明和圣光的能力',
    attribute: 'light',
    famousUsage: []
  },
  {
    id: 'ability_darkness_control',
    nameCn: '黑暗操控',
    nameEn: 'Darkness Control',
    category: 'elemental',
    description: '操控黑暗和阴影的能力',
    attribute: 'dark',
    famousUsage: []
  },
  {
    id: 'ability_nature_control',
    nameCn: '自然操控',
    nameEn: 'Nature Control',
    category: 'elemental',
    description: '操控植物和自然力量的能力',
    attribute: 'nature',
    famousUsage: []
  }
];
