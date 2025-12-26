/**
 * 神话志 - 主神数据模型
 */

import { CultureType } from '../common/Constants';

/**
 * 主神名称接口
 */
export interface DeityName {
  original: string;  // 原文名称
  cn: string;        // 中文名称
  en: string;        // 英文名称
}

/**
 * 著名事迹接口
 */
export interface DeityStory {
  title: string;          // 事迹标题
  description: string;    // 事迹描述
}

/**
 * 神祇关系接口
 */
export interface DeityRelationship {
  type: 'parent' | 'child' | 'sibling' | 'spouse' | 'rival';
  deityId: string;        // 关联神祇ID
  description: string;    // 关系描述
}

/**
 * 主神数据模型
 */
export interface Deity {
  // 基本标识
  id: string;

  // 名称（三语）
  name: DeityName;

  // 分类信息
  culture: CultureType;

  // 神职领域
  domain: string[];

  // 象征物品
  symbols: string[];

  // 内容信息
  description: string;          // 简短描述
  mythology: string;            // 完整神话传说

  // 著名事迹
  famousStories: DeityStory[];

  // 关联神祇
  relationships: DeityRelationship[];

  // 掌管神兽ID列表
  relatedCreatures: string[];

  // 图片文件名
  image: string;

  // 搜索标签
  tags: string[];
}

/**
 * 主神简要信息（用于列表展示）
 */
export interface DeityBrief {
  id: string;
  name: DeityName;
  culture: CultureType;
  domain: string[];
  image: string;
}

/**
 * 从完整主神数据提取简要信息
 */
export function toDeityBrief(deity: Deity): DeityBrief {
  return {
    id: deity.id,
    name: deity.name,
    culture: deity.culture,
    domain: deity.domain,
    image: deity.image
  };
}

/**
 * 主神筛选条件
 */
export interface DeityFilter {
  culture?: CultureType;
  keyword?: string;
}

/**
 * 筛选主神列表
 */
export function filterDeities(deities: Deity[], filter: DeityFilter): Deity[] {
  return deities.filter(deity => {
    // 文化筛选
    if (filter.culture && deity.culture !== filter.culture) {
      return false;
    }
    // 关键词搜索
    if (filter.keyword) {
      const keyword = filter.keyword.toLowerCase();
      const matchName = deity.name.cn.toLowerCase().includes(keyword) ||
        deity.name.en.toLowerCase().includes(keyword) ||
        deity.name.original.toLowerCase().includes(keyword);
      const matchDomain = deity.domain.some(d => d.toLowerCase().includes(keyword));
      const matchTags = deity.tags.some(tag => tag.toLowerCase().includes(keyword));
      const matchDesc = deity.description.toLowerCase().includes(keyword);
      if (!matchName && !matchDomain && !matchTags && !matchDesc) {
        return false;
      }
    }
    return true;
  });
}

/**
 * 获取关系类型中文名
 */
export function getRelationshipTypeName(type: string): string {
  const names: Record<string, string> = {
    'parent': '父母',
    'child': '子女',
    'sibling': '兄弟姐妹',
    'spouse': '配偶',
    'rival': '对立'
  };
  return names[type] || '关联';
}
