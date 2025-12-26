/**
 * 神话志 - 搜索工具
 */

import { MythicalCreature } from '../model/MythicalCreature';

/**
 * 搜索结果类型
 */
export interface SearchResult {
  creatures: MythicalCreature[];
  totalCount: number;
  keyword: string;
}

/**
 * 搜索建议
 */
export interface SearchSuggestion {
  text: string;
  type: 'creature' | 'culture' | 'attribute' | 'type';
}

/**
 * 热门搜索词
 */
export const HotSearchKeywords: string[] = [
  '龙',
  '凤凰',
  '九尾狐',
  '独角兽',
  '麒麟',
  '美杜莎',
  '芬里尔',
  '天狗',
  '阿努比斯',
  '火属性'
];

/**
 * 搜索管理器类
 */
export class SearchManager {
  private static instance: SearchManager;
  private searchHistory: string[] = [];
  private readonly maxHistorySize: number = 20;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): SearchManager {
    if (!SearchManager.instance) {
      SearchManager.instance = new SearchManager();
    }
    return SearchManager.instance;
  }

  /**
   * 搜索神兽
   */
  search(creatures: MythicalCreature[], keyword: string): SearchResult {
    if (!keyword || keyword.trim().length === 0) {
      return {
        creatures: [],
        totalCount: 0,
        keyword: ''
      };
    }

    const lowerKeyword = keyword.toLowerCase().trim();

    // 多维度搜索
    const results = creatures.filter(creature => {
      // 名称匹配
      if (this.matchName(creature, lowerKeyword)) {
        return true;
      }

      // 文化匹配
      if (this.matchCulture(creature, lowerKeyword)) {
        return true;
      }

      // 属性匹配
      if (this.matchAttribute(creature, lowerKeyword)) {
        return true;
      }

      // 类型匹配
      if (this.matchType(creature, lowerKeyword)) {
        return true;
      }

      // 标签匹配
      if (this.matchTags(creature, lowerKeyword)) {
        return true;
      }

      // 描述匹配
      if (this.matchDescription(creature, lowerKeyword)) {
        return true;
      }

      return false;
    });

    // 按匹配度排序（精确匹配优先）
    results.sort((a, b) => {
      const aExact = a.name.cn === keyword || a.name.en.toLowerCase() === lowerKeyword;
      const bExact = b.name.cn === keyword || b.name.en.toLowerCase() === lowerKeyword;

      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      // 按稀有度排序
      const rarityOrderMap: Map<string, number> = new Map([
        ['legendary', 4],
        ['epic', 3],
        ['rare', 2],
        ['common', 1]
      ]);
      return (rarityOrderMap.get(b.rarity) || 0) - (rarityOrderMap.get(a.rarity) || 0);
    });

    return {
      creatures: results,
      totalCount: results.length,
      keyword
    };
  }

  /**
   * 名称匹配
   */
  private matchName(creature: MythicalCreature, keyword: string): boolean {
    return creature.name.cn.toLowerCase().includes(keyword) ||
      creature.name.en.toLowerCase().includes(keyword) ||
      creature.name.original.toLowerCase().includes(keyword);
  }

  /**
   * 文化匹配
   */
  private matchCulture(creature: MythicalCreature, keyword: string): boolean {
    const cultureKeywordsMap: Map<string, string[]> = new Map([
      ['chinese', ['中国', '中华', 'chinese', '华夏']],
      ['greek', ['希腊', 'greek', '古希腊']],
      ['norse', ['北欧', 'norse', '维京']],
      ['japanese', ['日本', 'japanese', '和风']],
      ['indian', ['印度', 'indian', '婆罗门']],
      ['egyptian', ['埃及', 'egyptian', '法老']],
      ['celtic', ['凯尔特', 'celtic', '德鲁伊']]
    ]);

    const keywords = cultureKeywordsMap.get(creature.culture) || [];
    return keywords.some(k => k.includes(keyword) || keyword.includes(k));
  }

  /**
   * 属性匹配
   */
  private matchAttribute(creature: MythicalCreature, keyword: string): boolean {
    const attributeKeywordsMap: Map<string, string[]> = new Map([
      ['fire', ['火', 'fire', '烈焰', '炎']],
      ['water', ['水', 'water', '冰', '海']],
      ['wind', ['风', 'wind', '气', '飞']],
      ['thunder', ['雷', 'thunder', '电', '闪电']],
      ['light', ['光', 'light', '圣', '神圣']],
      ['dark', ['暗', 'dark', '黑暗', '阴影']],
      ['nature', ['自然', 'nature', '木', '森林']]
    ]);

    const primaryKeywords = attributeKeywordsMap.get(creature.attributes.primary) || [];
    const secondaryKeywords = creature.attributes.secondary ?
      (attributeKeywordsMap.get(creature.attributes.secondary) || []) : [];

    const allKeywords: string[] = [];
    for (const k of primaryKeywords) {
      allKeywords.push(k);
    }
    for (const k of secondaryKeywords) {
      allKeywords.push(k);
    }
    return allKeywords.some(k => k.includes(keyword) || keyword.includes(k));
  }

  /**
   * 类型匹配
   */
  private matchType(creature: MythicalCreature, keyword: string): boolean {
    const typeKeywordsMap: Map<string, string[]> = new Map([
      ['dragon', ['龙', 'dragon', '龙族']],
      ['phoenix', ['凤', 'phoenix', '神鸟', '火鸟']],
      ['beast', ['兽', 'beast', '魔兽', '怪兽']],
      ['spirit', ['精灵', 'spirit', '灵', '妖精']],
      ['giant', ['巨人', 'giant', '泰坦']],
      ['undead', ['不死', 'undead', '亡灵', '僵尸']]
    ]);

    const keywords = typeKeywordsMap.get(creature.type) || [];
    return keywords.some(k => k.includes(keyword) || keyword.includes(k));
  }

  /**
   * 标签匹配
   */
  private matchTags(creature: MythicalCreature, keyword: string): boolean {
    return creature.tags.some(tag =>
      tag.toLowerCase().includes(keyword) || keyword.includes(tag.toLowerCase())
    );
  }

  /**
   * 描述匹配
   */
  private matchDescription(creature: MythicalCreature, keyword: string): boolean {
    return creature.description.toLowerCase().includes(keyword);
  }

  /**
   * 获取搜索建议
   */
  getSuggestions(creatures: MythicalCreature[], keyword: string, limit: number = 10): SearchSuggestion[] {
    if (!keyword || keyword.trim().length === 0) {
      return [];
    }

    const lowerKeyword = keyword.toLowerCase().trim();
    const suggestions: SearchSuggestion[] = [];

    // 神兽名称建议
    creatures.forEach(creature => {
      if (creature.name.cn.includes(keyword)) {
        suggestions.push({
          text: creature.name.cn,
          type: 'creature'
        });
      }
    });

    // 限制数量
    return suggestions.slice(0, limit);
  }

  /**
   * 添加搜索历史
   */
  addToHistory(keyword: string): void {
    if (!keyword || keyword.trim().length === 0) {
      return;
    }

    // 移除已存在的相同记录
    this.searchHistory = this.searchHistory.filter(h => h !== keyword);

    // 添加到开头
    this.searchHistory.unshift(keyword);

    // 限制数量
    if (this.searchHistory.length > this.maxHistorySize) {
      this.searchHistory = this.searchHistory.slice(0, this.maxHistorySize);
    }
  }

  /**
   * 获取搜索历史
   */
  getHistory(): string[] {
    return [...this.searchHistory];
  }

  /**
   * 清空搜索历史
   */
  clearHistory(): void {
    this.searchHistory = [];
  }

  /**
   * 获取热门搜索
   */
  getHotKeywords(): string[] {
    return HotSearchKeywords;
  }
}

/**
 * 全局搜索管理器实例
 */
export const searchManager = SearchManager.getInstance();

/**
 * 简化的搜索工具类（静态方法）
 */
export class SearchUtil {
  /**
   * 搜索神兽
   */
  static search(creatures: MythicalCreature[], keyword: string): MythicalCreature[] {
    if (!keyword || keyword.trim().length === 0) {
      return [];
    }

    const result = searchManager.search(creatures, keyword);
    return result.creatures;
  }

  /**
   * 获取热门搜索词
   */
  static getHotKeywords(): string[] {
    return HotSearchKeywords;
  }
}
