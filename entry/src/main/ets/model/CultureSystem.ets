/**
 * 神话志 - 文化体系数据模型
 */

import { CultureType, getCultureColor, getCultureName, CultureNameInfo } from '../common/Constants';

/**
 * 文化体系数据模型
 */
export interface CultureSystem {
  id: CultureType;
  nameCn: string;
  nameEn: string;
  region: string;
  color: string;
  icon: string;
  background: string;              // 文化背景介绍
  cosmology: string;               // 宇宙观/世界观
  features: string[];              // 文化特色
  representativeCreatures: string[]; // 代表神兽ID
}

/**
 * 获取文化体系完整数据
 */
export function getCultureData(id: CultureType): CultureSystem {
  const names: CultureNameInfo = getCultureName(id);
  const color: string = getCultureColor(id);

  const result: CultureSystem = {
    id: id,
    nameCn: names.cn,
    nameEn: names.en,
    region: names.region,
    color: color,
    icon: `ic_culture_${id}`,
    background: getCultureBackground(id),
    cosmology: getCultureCosmology(id),
    features: getCultureFeatures(id),
    representativeCreatures: []
  };
  return result;
}

/**
 * 获取文化背景介绍
 */
function getCultureBackground(id: CultureType): string {
  const backgroundsMap: Map<CultureType, string> = new Map([
    ['chinese', '中国神话源远流长，融合了儒、道、佛三家思想，形成了独特的神话体系。从上古时代的创世神话，到《山海经》中的奇珍异兽，再到民间传说中的神仙妖怪，构成了丰富多彩的神话世界。中国神话强调天人合一、阴阳调和的哲学思想。'],
    ['greek', '希腊神话是西方文明的重要源头之一，以奥林匹斯诸神为核心，讲述了众神、英雄和怪物的故事。希腊神话深刻影响了西方艺术、文学和哲学的发展，其中的悲剧英雄和命运主题至今仍具有深远影响。'],
    ['norse', '北欧神话起源于斯堪的纳维亚地区，以阿萨神族和华纳神族为主体。其世界观以世界树尤克特拉希尔为中心，包含九大世界。北欧神话的核心是诸神黄昏的预言，体现了北欧人对命运的独特理解。'],
    ['japanese', '日本神话融合了本土神道教信仰与大陆传入的佛教、道教元素。从《古事记》《日本书纪》中的创世神话，到民间流传的妖怪传说，形成了独特的和风神话体系。日本神话中自然崇拜与祖先崇拜占据重要地位。'],
    ['indian', '印度神话是世界上最古老、最丰富的神话体系之一，以吠陀文献和两大史诗《摩诃婆罗多》《罗摩衍那》为核心。印度神话与印度教、佛教密切相关，充满了关于宇宙轮回和因果报应的思考。'],
    ['egyptian', '埃及神话是古埃及文明的精神支柱，以太阳神拉和冥界之神奥西里斯为核心。埃及神话与死后世界和永生密切相关，金字塔和木乃伊都是这一信仰的体现。埃及诸神多以人兽结合的形象出现。'],
    ['celtic', '凯尔特神话源于古代凯尔特人，主要流传于爱尔兰、威尔士和苏格兰地区。凯尔特神话充满了魔法与奇幻色彩，精灵、妖精和德鲁伊是其中的重要元素。凯尔特人崇拜自然，将树木、河流视为神圣。']
  ]);
  return backgroundsMap.get(id) || '';
}

/**
 * 获取文化宇宙观
 */
function getCultureCosmology(id: CultureType): string {
  const cosmologiesMap: Map<CultureType, string> = new Map([
    ['chinese', '中国神话的宇宙观基于"天圆地方"的概念，分为天界、人间和冥界三界。天界由玉皇大帝统治，人间由凡人居住，冥界由阎王管理。世界由盘古开天辟地而成，万物遵循阴阳五行的法则运转。'],
    ['greek', '希腊宇宙观以奥林匹斯山为神界中心，大地由盖亚化身，天空为乌拉诺斯。世界分为三层：天界（奥林匹斯）、人间大地和冥界塔尔塔罗斯。宙斯统治天界，波塞冬掌管海洋，哈迪斯管辖冥界。'],
    ['norse', '北欧宇宙观以世界树尤克特拉希尔为中心，连接九大世界：阿斯加德（神界）、米德加尔德（人间）、尼夫尔海姆（冰雪世界）、穆斯贝尔海姆（火焰世界）等。彩虹桥连接神界与人间。'],
    ['japanese', '日本宇宙观分为高天原（天界）、苇原中国（人间）和黄泉国（冥界）。天照大神统治高天原，素盏呜尊统治海原。神道教认为万物皆有神灵，自然界充满了八百万神。'],
    ['indian', '印度宇宙观基于宇宙循环的概念，世界经历创造、维持、毁灭和再创造的永恒循环。宇宙分为多层天界、人间和多层地狱。须弥山是宇宙中心，梵天创世、毗湿奴维护、湿婆毁灭。'],
    ['egyptian', '埃及宇宙观以尼罗河为中心，天空是女神努特的身体，大地是男神盖布。太阳神拉每日驾驶太阳船穿越天空，夜间经过冥界杜阿特。宇宙由八位原始神创造而成。'],
    ['celtic', '凯尔特宇宙观将世界分为三界：天界、人间和异界（Otherworld）。异界是神灵和精灵居住的地方，通过圣井、古墓或迷雾可以进入。世界树连接三界，德鲁伊是人间与神界的媒介。']
  ]);
  return cosmologiesMap.get(id) || '';
}

/**
 * 获取文化特色
 */
function getCultureFeatures(id: CultureType): string[] {
  const featuresMap: Map<CultureType, string[]> = new Map([
    ['chinese', ['阴阳五行', '山海经体系', '道教仙学', '四象四灵', '天人合一']],
    ['greek', ['奥林匹斯众神', '英雄史诗', '命运悲剧', '人神关系', '神话怪物']],
    ['norse', ['诸神黄昏', '世界树', '九大世界', '符文魔法', '英灵殿']],
    ['japanese', ['八百万神', '妖怪文化', '神道信仰', '和风美学', '自然崇拜']],
    ['indian', ['宇宙轮回', '因果业报', '三主神', '史诗传统', '瑜伽修行']],
    ['egyptian', ['太阳崇拜', '死后世界', '人兽合一', '法老神权', '木乃伊']],
    ['celtic', ['德鲁伊', '精灵传说', '自然崇拜', '异界入口', '魔法传统']]
  ]);
  return featuresMap.get(id) || [];
}

/**
 * 获取所有文化体系
 */
export function getAllCultures(): CultureSystem[] {
  const cultureIds: CultureType[] = ['chinese', 'greek', 'norse', 'japanese', 'indian', 'egyptian', 'celtic'];
  const result: CultureSystem[] = [];
  for (const id of cultureIds) {
    result.push(getCultureData(id));
  }
  return result;
}

/**
 * 根据ID获取文化体系
 */
export function getCultureById(id: string): CultureSystem | undefined {
  const validIds: CultureType[] = ['chinese', 'greek', 'norse', 'japanese', 'indian', 'egyptian', 'celtic'];
  if (validIds.includes(id as CultureType)) {
    return getCultureData(id as CultureType);
  }
  return undefined;
}
