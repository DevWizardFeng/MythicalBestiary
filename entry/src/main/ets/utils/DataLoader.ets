/**
 * 神话志 - 数据加载工具
 */

import util from '@ohos.util';
import { MythicalCreature } from '../model/MythicalCreature';
import { Ability } from '../model/Ability';
import { Attribute } from '../model/Attribute';
import { CultureSystem } from '../model/CultureSystem';
import { Deity } from '../model/Deity';

/**
 * 数据加载器类
 */
export class DataLoader {
  private static instance: DataLoader;
  private creatures: MythicalCreature[] = [];
  private abilities: Ability[] = [];
  private attributes: Attribute[] = [];
  private cultures: CultureSystem[] = [];
  private deities: Deity[] = [];
  private isLoaded: boolean = false;
  private context: Context | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): DataLoader {
    if (!DataLoader.instance) {
      DataLoader.instance = new DataLoader();
    }
    return DataLoader.instance;
  }

  /**
   * 初始化上下文
   */
  init(context: Context): void {
    this.context = context;
  }

  /**
   * 初始化数据加载器（简化接口）
   */
  async initialize(): Promise<void> {
    if (this.isLoaded) {
      return;
    }
    // 如果没有context，尝试使用全局context
    if (!this.context) {
      try {
        this.context = getContext();
      } catch (e) {
        console.warn('DataLoader: 无法获取context');
      }
    }
    await this.loadAllData();
  }

  /**
   * 加载所有数据
   */
  async loadAllData(): Promise<void> {
    if (this.isLoaded || !this.context) {
      return;
    }

    try {
      // 并行加载所有数据
      const results = await Promise.all([
        this.loadRawFile('data/creatures.json'),
        this.loadRawFile('data/abilities.json'),
        this.loadRawFile('data/attributes.json'),
        this.loadRawFile('data/cultures.json'),
        this.loadRawFile('data/deities.json')
      ]);

      const creaturesData = results[0];
      const abilitiesData = results[1];
      const attributesData = results[2];
      const culturesData = results[3];
      const deitiesData = results[4];

      if (creaturesData) {
        this.creatures = JSON.parse(creaturesData) as MythicalCreature[];
      }

      if (abilitiesData) {
        this.abilities = JSON.parse(abilitiesData) as Ability[];
      }

      if (attributesData) {
        this.attributes = JSON.parse(attributesData) as Attribute[];
      }

      if (culturesData) {
        this.cultures = JSON.parse(culturesData) as CultureSystem[];
      }

      if (deitiesData) {
        this.deities = JSON.parse(deitiesData) as Deity[];
      }

      this.isLoaded = true;
      console.info('DataLoader: 数据加载完成');
    } catch (error) {
      console.error('DataLoader: 数据加载失败', error);
    }
  }

  /**
   * 读取rawfile文件
   */
  private async loadRawFile(path: string): Promise<string | null> {
    if (!this.context) {
      return null;
    }

    try {
      const resourceManager = this.context.resourceManager;
      const content = await resourceManager.getRawFileContent(path);
      const textDecoder = util.TextDecoder.create('utf-8');
      const result = textDecoder.decodeToString(content);
      return result;
    } catch (error) {
      console.warn(`DataLoader: 无法加载文件 ${path}`, error);
      return null;
    }
  }

  /**
   * 获取所有神兽
   */
  getCreatures(): MythicalCreature[] {
    return this.creatures;
  }

  /**
   * 获取所有神兽（别名）
   */
  getAllCreatures(): MythicalCreature[] {
    return this.creatures;
  }

  /**
   * 获取所有属性
   */
  getAttributes(): Attribute[] {
    return this.attributes;
  }

  /**
   * 获取所有文化
   */
  getCultures(): CultureSystem[] {
    return this.cultures;
  }

  /**
   * 根据ID获取神兽
   */
  getCreatureById(id: string): MythicalCreature | undefined {
    return this.creatures.find((c: MythicalCreature) => c.id === id);
  }

  /**
   * 根据文化获取神兽
   */
  getCreaturesByCulture(culture: string): MythicalCreature[] {
    return this.creatures.filter((c: MythicalCreature) => c.culture === culture);
  }

  /**
   * 根据属性获取神兽
   */
  getCreaturesByAttribute(attribute: string): MythicalCreature[] {
    return this.creatures.filter((c: MythicalCreature) =>
      c.attributes.primary === attribute || c.attributes.secondary === attribute
    );
  }

  /**
   * 根据类型获取神兽
   */
  getCreaturesByType(type: string): MythicalCreature[] {
    return this.creatures.filter((c: MythicalCreature) => c.type === type);
  }

  /**
   * 根据稀有度获取神兽
   */
  getCreaturesByRarity(rarity: string): MythicalCreature[] {
    return this.creatures.filter((c: MythicalCreature) => c.rarity === rarity);
  }

  /**
   * 获取相关神兽
   */
  getRelatedCreatures(creatureId: string, limit: number = 5): MythicalCreature[] {
    const creature = this.getCreatureById(creatureId);
    if (!creature) {
      return [];
    }

    // 先从related字段获取
    const relatedIds = creature.related || [];
    const related: MythicalCreature[] = [];
    for (const id of relatedIds) {
      const c = this.getCreatureById(id);
      if (c !== undefined) {
        related.push(c);
      }
    }

    if (related.length >= limit) {
      return related.slice(0, limit);
    }

    // 补充同文化或同属性的神兽
    const additional = this.creatures.filter((c: MythicalCreature) =>
      c.id !== creatureId &&
      !relatedIds.includes(c.id) &&
      (c.culture === creature.culture || c.attributes.primary === creature.attributes.primary)
    );

    const combined: MythicalCreature[] = [];
    for (const c of related) {
      combined.push(c);
    }
    for (const c of additional) {
      combined.push(c);
    }
    return combined.slice(0, limit);
  }

  /**
   * 获取所有能力
   */
  getAbilities(): Ability[] {
    return this.abilities;
  }

  /**
   * 根据ID获取能力
   */
  getAbilityById(id: string): Ability | undefined {
    return this.abilities.find((a: Ability) => a.id === id);
  }

  /**
   * 获取随机神兽
   */
  getRandomCreature(): MythicalCreature | undefined {
    if (this.creatures.length === 0) {
      return undefined;
    }
    const index = Math.floor(Math.random() * this.creatures.length);
    return this.creatures[index];
  }

  /**
   * 根据日期获取每日神兽（固定种子随机）
   */
  getDailyCreature(date: Date = new Date()): MythicalCreature | undefined {
    if (this.creatures.length === 0) {
      return undefined;
    }
    // 使用日期作为种子
    const seed = date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();
    const index = seed % this.creatures.length;
    return this.creatures[index];
  }

  /**
   * 获取传说级神兽
   */
  getLegendaryCreatures(): MythicalCreature[] {
    return this.creatures.filter((c: MythicalCreature) => c.rarity === 'legendary');
  }

  /**
   * 是否已加载
   */
  isDataLoaded(): boolean {
    return this.isLoaded;
  }

  /**
   * 获取所有主神
   */
  getAllDeities(): Deity[] {
    return this.deities;
  }

  /**
   * 根据ID获取主神
   */
  getDeityById(id: string): Deity | undefined {
    return this.deities.find((d: Deity) => d.id === id);
  }

  /**
   * 根据文化获取主神
   */
  getDeitiesByCulture(culture: string): Deity[] {
    return this.deities.filter((d: Deity) => d.culture === culture);
  }

  /**
   * 根据主神获取掌管神兽
   */
  getCreaturesByDeity(deityId: string): MythicalCreature[] {
    const deity = this.getDeityById(deityId);
    if (!deity || !deity.relatedCreatures) {
      return [];
    }
    const result: MythicalCreature[] = [];
    for (const id of deity.relatedCreatures) {
      const creature = this.getCreatureById(id);
      if (creature !== undefined) {
        result.push(creature);
      }
    }
    return result;
  }

  /**
   * 获取随机主神
   */
  getRandomDeity(): Deity | undefined {
    if (this.deities.length === 0) {
      return undefined;
    }
    const index = Math.floor(Math.random() * this.deities.length);
    return this.deities[index];
  }

  /**
   * 根据日期获取每日主神（固定种子随机）
   */
  getDailyDeity(date: Date = new Date()): Deity | undefined {
    if (this.deities.length === 0) {
      return undefined;
    }
    const seed = date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();
    const index = (seed + 7) % this.deities.length;
    return this.deities[index];
  }

  /**
   * 搜索主神
   */
  searchDeities(keyword: string): Deity[] {
    const lowerKeyword = keyword.toLowerCase();
    return this.deities.filter((d: Deity) =>
      d.name.cn.toLowerCase().includes(lowerKeyword) ||
      d.name.en.toLowerCase().includes(lowerKeyword) ||
      d.name.original.toLowerCase().includes(lowerKeyword) ||
      d.domain.some(domain => domain.toLowerCase().includes(lowerKeyword)) ||
      d.tags.some(tag => tag.toLowerCase().includes(lowerKeyword))
    );
  }
}

/**
 * 全局数据加载器实例
 */
export const dataLoader = DataLoader.getInstance();
