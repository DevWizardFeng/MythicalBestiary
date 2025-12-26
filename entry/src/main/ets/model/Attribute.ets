/**
 * 神话志 - 属性数据模型
 */

import { AttributeType, getAttributeColor, getAttributeName, AttributeStrengths, ColorPair, NamePair } from '../common/Constants';

/**
 * 属性数据模型
 */
export interface Attribute {
  id: AttributeType;
  nameCn: string;
  nameEn: string;
  color: string;
  secondaryColor: string;
  icon: string;
  meaning: string;
  strengths: AttributeType[];        // 克制的属性
  weaknesses: AttributeType[];       // 被克制的属性
  representativeCreatures: string[]; // 代表神兽ID
}

/**
 * 获取属性完整数据
 */
export function getAttributeData(id: AttributeType): Attribute {
  const colors: ColorPair = getAttributeColor(id);
  const names: NamePair = getAttributeName(id);
  const strengths: AttributeType[] = AttributeStrengths.get(id) || [];

  // 计算被克制的属性
  const weaknesses: AttributeType[] = [];
  const allAttrIds: AttributeType[] = ['fire', 'water', 'wind', 'thunder', 'light', 'dark', 'nature'];
  for (const attrId of allAttrIds) {
    const attrStrengths: AttributeType[] = AttributeStrengths.get(attrId) || [];
    if (attrStrengths.includes(id)) {
      weaknesses.push(attrId);
    }
  }

  const result: Attribute = {
    id: id,
    nameCn: names.cn,
    nameEn: names.en,
    color: colors.primary,
    secondaryColor: colors.secondary,
    icon: `ic_attr_${id}`,
    meaning: getAttributeMeaning(id),
    strengths: strengths,
    weaknesses: weaknesses,
    representativeCreatures: []
  };
  return result;
}

/**
 * 获取属性象征含义
 */
function getAttributeMeaning(id: AttributeType): string {
  const meaningsMap: Map<AttributeType, string> = new Map([
    ['fire', '热烈、激情、力量、毁灭。火属性代表着燃烧的意志和不屈的精神，是战斗与破坏的象征。'],
    ['water', '柔和、智慧、流动、适应。水属性代表着包容与变化，能够适应任何环境，以柔克刚。'],
    ['wind', '自由、速度、变化、无形。风属性代表着不可捉摸的力量，来去无踪，迅捷如风。'],
    ['thunder', '威严、力量、正义、惩罚。雷属性代表着天罚与神威，是上天意志的体现。'],
    ['light', '光明、希望、净化、守护。光属性代表着驱散黑暗的力量，是正义与救赎的象征。'],
    ['dark', '神秘、深邃、恐惧、死亡。暗属性代表着未知与恐惧，是夜之力量的化身。'],
    ['nature', '生命、成长、治愈、循环。自然属性代表着万物的生长与轮回，是大地母亲的馈赠。']
  ]);
  return meaningsMap.get(id) || '';
}

/**
 * 获取所有属性列表
 */
export function getAllAttributes(): Attribute[] {
  const attributeIds: AttributeType[] = ['fire', 'water', 'wind', 'thunder', 'light', 'dark', 'nature'];
  const result: Attribute[] = [];
  for (const id of attributeIds) {
    result.push(getAttributeData(id));
  }
  return result;
}

/**
 * 检查属性相克关系
 */
export function checkAttributeAdvantage(attacker: AttributeType, defender: AttributeType): 'advantage' | 'disadvantage' | 'neutral' {
  const attackerStrengths: AttributeType[] = AttributeStrengths.get(attacker) || [];
  const defenderStrengths: AttributeType[] = AttributeStrengths.get(defender) || [];

  if (attackerStrengths.includes(defender)) {
    return 'advantage';
  }
  if (defenderStrengths.includes(attacker)) {
    return 'disadvantage';
  }
  return 'neutral';
}

/**
 * 获取属性相克描述
 */
export function getAdvantageDescription(attacker: AttributeType, defender: AttributeType): string {
  const result = checkAttributeAdvantage(attacker, defender);
  const attackerName: NamePair = getAttributeName(attacker);
  const defenderName: NamePair = getAttributeName(defender);

  if (result === 'advantage') {
    return `${attackerName.cn}属性克制${defenderName.cn}属性`;
  } else if (result === 'disadvantage') {
    return `${attackerName.cn}属性被${defenderName.cn}属性克制`;
  } else {
    return `${attackerName.cn}属性与${defenderName.cn}属性相互独立`;
  }
}
