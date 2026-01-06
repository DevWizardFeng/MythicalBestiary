/**
 * 神话志 - 数据加载工具
 */

import util from '@ohos.util';
import { MythicalCreature } from '../model/MythicalCreature';
import { Ability } from '../model/Ability';
import { Attribute } from '../model/Attribute';
import { CultureSystem } from '../model/CultureSystem';
import { Deity } from '../model/Deity';
import { QuizQuestion, QuestionCategory, DifficultyLevel, pickRandom, shuffleArray } from '../model/Quiz';
import { MythStory } from '../model/MythStory';

/**
 * 题库数据文件接口
 */
interface QuizDataFile {
  questions: QuizQuestion[];
}

/**
 * 题目分类统计接口
 */
export interface CategoryQuestionCount {
  creature: number;
  deity: number;
  culture: number;
  attribute: number;
  ability: number;
  mixed: number;
}

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
  private stories: MythStory[] = [];
  private quizQuestions: QuizQuestion[] = [];
  private isLoaded: boolean = false;
  private isQuizLoaded: boolean = false;
  private isStoriesLoaded: boolean = false;
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
        this.loadRawFile('data/deities.json'),
        this.loadRawFile('data/stories.json')
      ]);

      const creaturesData = results[0];
      const abilitiesData = results[1];
      const attributesData = results[2];
      const culturesData = results[3];
      const deitiesData = results[4];
      const storiesData = results[5];

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

      if (storiesData) {
        this.stories = JSON.parse(storiesData) as MythStory[];
        this.isStoriesLoaded = true;
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

  // ==================== 题库相关 ====================

  /**
   * 加载题库数据
   */
  async loadQuizData(): Promise<void> {
    if (this.isQuizLoaded) {
      return;
    }

    if (!this.context) {
      try {
        this.context = getContext();
      } catch (e) {
        console.warn('DataLoader: 无法获取context');
        return;
      }
    }

    try {
      const quizData = await this.loadRawFile('data/quiz.json');
      if (quizData) {
        const parsed: QuizDataFile = JSON.parse(quizData) as QuizDataFile;
        this.quizQuestions = parsed.questions as QuizQuestion[];
        this.isQuizLoaded = true;
        console.info(`DataLoader: 题库加载完成，共${this.quizQuestions.length}道题`);
      }
    } catch (error) {
      console.error('DataLoader: 题库加载失败', error);
    }
  }

  /**
   * 获取所有题目
   */
  getAllQuestions(): QuizQuestion[] {
    return this.quizQuestions;
  }

  /**
   * 根据分类获取题目
   */
  getQuestionsByCategory(category: QuestionCategory): QuizQuestion[] {
    return this.quizQuestions.filter(q => q.category === category);
  }

  /**
   * 根据难度获取题目
   */
  getQuestionsByDifficulty(difficulty: DifficultyLevel): QuizQuestion[] {
    return this.quizQuestions.filter(q => q.difficulty === difficulty);
  }

  /**
   * 获取随机题目列表
   */
  getRandomQuestions(count: number, category?: QuestionCategory, difficulty?: DifficultyLevel): QuizQuestion[] {
    let filtered = this.quizQuestions;

    if (category && category !== 'mixed') {
      filtered = filtered.filter(q => q.category === category);
    }

    if (difficulty) {
      filtered = filtered.filter(q => q.difficulty === difficulty);
    }

    return pickRandom(filtered, count);
  }

  /**
   * 获取混合难度的题目列表（按比例分配难度）
   */
  getMixedDifficultyQuestions(count: number, category?: QuestionCategory): QuizQuestion[] {
    // 难度分配比例：简单30%、中等50%、困难20%
    const easyCount = Math.floor(count * 0.3);
    const mediumCount = Math.floor(count * 0.5);
    const hardCount = count - easyCount - mediumCount;

    let filtered = this.quizQuestions;
    if (category && category !== 'mixed') {
      filtered = filtered.filter(q => q.category === category);
    }

    const easyQuestions = pickRandom(filtered.filter(q => q.difficulty === 'easy'), easyCount);
    const mediumQuestions = pickRandom(filtered.filter(q => q.difficulty === 'medium'), mediumCount);
    const hardQuestions = pickRandom(filtered.filter(q => q.difficulty === 'hard'), hardCount);

    // 合并并打乱顺序
    const combined: QuizQuestion[] = [];
    for (const q of easyQuestions) combined.push(q);
    for (const q of mediumQuestions) combined.push(q);
    for (const q of hardQuestions) combined.push(q);

    return shuffleArray(combined);
  }

  /**
   * 题库是否已加载
   */
  isQuizDataLoaded(): boolean {
    return this.isQuizLoaded;
  }

  /**
   * 获取题目总数
   */
  getQuestionCount(): number {
    return this.quizQuestions.length;
  }

  /**
   * 获取各分类题目数量
   */
  getQuestionCountByCategory(): CategoryQuestionCount {
    const counts: CategoryQuestionCount = {
      creature: 0,
      deity: 0,
      culture: 0,
      attribute: 0,
      ability: 0,
      mixed: 0
    } as CategoryQuestionCount;

    for (const q of this.quizQuestions) {
      if (q.category === 'creature') counts.creature++;
      else if (q.category === 'deity') counts.deity++;
      else if (q.category === 'culture') counts.culture++;
      else if (q.category === 'attribute') counts.attribute++;
      else if (q.category === 'ability') counts.ability++;
      else counts.mixed++;
    }

    return counts;
  }

  // ==================== 神话故事相关 ====================

  /**
   * 获取所有神话故事
   */
  getAllStories(): MythStory[] {
    return this.stories;
  }

  /**
   * 根据ID获取神话故事
   */
  getStoryById(id: string): MythStory | undefined {
    return this.stories.find((s: MythStory) => s.id === id);
  }

  /**
   * 根据文化获取神话故事
   */
  getStoriesByCulture(cultureId: string): MythStory[] {
    return this.stories.filter((s: MythStory) => s.cultureId === cultureId);
  }

  /**
   * 获取故事总数
   */
  getStoryCount(): number {
    return this.stories.length;
  }

  /**
   * 故事是否已加载
   */
  isStoriesDataLoaded(): boolean {
    return this.isStoriesLoaded;
  }

  /**
   * 搜索神话故事
   */
  searchStories(keyword: string): MythStory[] {
    const lowerKeyword = keyword.toLowerCase();
    return this.stories.filter((s: MythStory) =>
      s.title.toLowerCase().includes(lowerKeyword) ||
      s.subtitle.toLowerCase().includes(lowerKeyword) ||
      s.tags.some(tag => tag.toLowerCase().includes(lowerKeyword))
    );
  }
}

/**
 * 全局数据加载器实例
 */
export const dataLoader = DataLoader.getInstance();
