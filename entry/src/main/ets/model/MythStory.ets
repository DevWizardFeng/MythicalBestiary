/**
 * 神话志 - 神话故事数据模型
 */

import { CultureType } from '../common/Constants';

/**
 * 故事章节
 */
export interface StoryChapter {
  title: string;        // 章节标题
  content: string;      // 章节内容
}

/**
 * 神话故事数据模型
 */
export interface MythStory {
  id: string;                    // 故事ID: story_{culture}_{序号}
  title: string;                 // 故事标题
  subtitle: string;              // 副标题/简介
  cultureId: CultureType;        // 所属文化ID
  cover: string;                 // 封面图片文件名
  chapters: StoryChapter[];      // 章节数组（支持翻页）
  relatedCreatures: string[];    // 关联神兽ID
  relatedDeities: string[];      // 关联主神ID
  tags: string[];                // 标签
}

/**
 * 故事简要信息（用于列表展示）
 */
export interface StoryBrief {
  id: string;
  title: string;
  subtitle: string;
  cultureId: CultureType;
  cover: string;
  tags: string[];
  chapterCount: number;
}

/**
 * 从完整故事生成简要信息
 */
export function toStoryBrief(story: MythStory): StoryBrief {
  return {
    id: story.id,
    title: story.title,
    subtitle: story.subtitle,
    cultureId: story.cultureId,
    cover: story.cover,
    tags: story.tags,
    chapterCount: story.chapters.length
  };
}
