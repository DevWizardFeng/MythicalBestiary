/**
 * 神话志 - 专题详情页面
 * 神话专题文章详情
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';

interface RouterParams {
  topicId: string;
}

interface TopicContent {
  id: string;
  title: string;
  subtitle: string;
  cover: string;
  category: string;
  author: string;
  publishDate: string;
  content: string[];
  relatedCreatures: string[];
}

@Entry
@Component
struct TopicDetail {
  @State topic: TopicContent | null = null;
  @State relatedCreatures: MythicalCreature[] = [];
  @State isLoading: boolean = true;
  private topicId: string = '';

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.topicId) {
      this.topicId = params.topicId;
      this.loadTopic();
    }
  }

  async loadTopic() {
    // 模拟专题内容数据
    const topicData: Record<string, TopicContent> = {
      'topic_1': {
        id: 'topic_1',
        title: '四大神兽的起源与演变',
        subtitle: '探索青龙、白虎、朱雀、玄武的神话渊源',
        cover: 'creature_chinese_qinglong',
        category: '中国神话',
        author: '神话志编辑部',
        publishDate: '2024-01-15',
        content: [
          '四大神兽，又称四象，是中国传统文化中代表四方和四季的四种神兽，分别是青龙、白虎、朱雀、玄武。它们的起源可以追溯到先秦时期，是中国古人对天文星象观察的产物。',
          '青龙，代表东方和春季，五行属木。在古代天文学中，青龙七宿分别是角、亢、氐、房、心、尾、箕，形成一条巨龙的形象。青龙在道教中被尊为护法神将，象征着生机与希望。',
          '白虎，代表西方和秋季，五行属金。白虎七宿包括奎、娄、胃、昴、毕、觜、参。在中国文化中，白虎既是凶兽也是瑞兽，代表着威猛与正义。',
          '朱雀，代表南方和夏季，五行属火。朱雀七宿为井、鬼、柳、星、张、翼、轸。朱雀形象华美，羽毛五彩，是吉祥和高贵的象征。',
          '玄武，代表北方和冬季，五行属水。玄武七宿是斗、牛、女、虚、危、室、壁。玄武形象为龟蛇合体，象征长寿和智慧。'
        ],
        relatedCreatures: ['creature_chinese_qinglong', 'creature_chinese_baihu', 'creature_chinese_zhuque', 'creature_chinese_xuanwu']
      },
      'topic_2': {
        id: 'topic_2',
        title: '希腊神话中的怪物图鉴',
        subtitle: '从九头蛇到美杜莎，揭秘希腊怪物的秘密',
        cover: 'creature_greek_hydra',
        category: '希腊神话',
        author: '神话志编辑部',
        publishDate: '2024-01-20',
        content: [
          '希腊神话是西方文明的重要源头之一，其中的神话生物更是丰富多彩。这些怪物往往是英雄们的对手，也是神话故事中不可或缺的角色。',
          '九头蛇海德拉是希腊神话中最著名的怪物之一。它生活在勒拿湖中，拥有九个头颅，其中一个是不死之身。英雄赫拉克勒斯在完成十二功绩时，曾与海德拉进行了一场惊心动魄的战斗。',
          '美杜莎是蛇发女妖戈尔贡三姐妹中唯一的凡人。任何直视她眼睛的人都会化为石头。英雄珀尔修斯借助雅典娜的盾牌和赫尔墨斯的飞鞋，成功斩杀了美杜莎。',
          '奇美拉是一种复合型怪物，拥有狮子的头部和身体、山羊的头部从背部长出、蛇形的尾巴。它能喷出火焰，最终被英雄柏勒洛丰骑着飞马佩加索斯所杀。'
        ],
        relatedCreatures: ['creature_greek_hydra', 'creature_greek_medusa', 'creature_greek_chimera']
      }
    };

    // 默认专题内容
    const defaultTopic: TopicContent = {
      id: this.topicId,
      title: '神话专题',
      subtitle: '探索神话世界的奥秘',
      cover: 'creature_chinese_dragon',
      category: '神话探索',
      author: '神话志编辑部',
      publishDate: '2024-01-01',
      content: [
        '欢迎来到神话志的专题文章。',
        '这里将为您带来关于神话生物的深度解读和文化探索。',
        '敬请期待更多精彩内容...'
      ],
      relatedCreatures: []
    };

    this.topic = topicData[this.topicId] || defaultTopic;

    // 加载相关神兽
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();

      if (this.topic.relatedCreatures.length > 0) {
        this.relatedCreatures = allCreatures
          .filter(c => this.topic?.relatedCreatures.includes(c.id));
      }
    } catch (error) {
      console.error('Failed to load related creatures:', error);
    }

    this.isLoading = false;
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.topic) {
        Scroll() {
          Column() {
            // 封面图
            Stack({ alignContent: Alignment.TopStart }) {
              Image($r(`app.media.${this.topic.cover}`))
                .width('100%')
                .height(240)
                .objectFit(ImageFit.Cover)

              // 渐变遮罩
              Column()
                .width('100%')
                .height('100%')
                .linearGradient({
                  direction: GradientDirection.Top,
                  colors: [[DarkTheme.background, 0], ['rgba(18,18,18,0.3)', 0.5], ['rgba(18,18,18,0)', 1]]
                })

              // 返回按钮
              Stack() {
                Circle()
                  .width(36)
                  .height(36)
                  .fill('rgba(0,0,0,0.3)')

                Image($r('app.media.ic_arrow_left'))
                  .width(20)
                  .height(20)
              }
              .margin({ left: 16, top: 48 })
              .onClick(() => {
                router.back();
              })
            }
            .width('100%')
            .height(240)

            // 标题区域
            Column({ space: 12 }) {
              Text(this.topic.category)
                .fontSize(12)
                .fontColor(DarkTheme.accent)
                .backgroundColor(DarkTheme.accent + '22')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(8)

              Text(this.topic.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(DarkTheme.textPrimary)

              Text(this.topic.subtitle)
                .fontSize(14)
                .fontColor(DarkTheme.textSecondary)

              Row({ space: 16 }) {
                Text(this.topic.author)
                  .fontSize(12)
                  .fontColor(DarkTheme.textTertiary)

                Text(this.topic.publishDate)
                  .fontSize(12)
                  .fontColor(DarkTheme.textTertiary)
              }
            }
            .width('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Start)

            // 正文内容
            Column({ space: 16 }) {
              ForEach(this.topic.content, (paragraph: string) => {
                Text(paragraph)
                  .fontSize(15)
                  .fontColor(DarkTheme.textSecondary)
                  .lineHeight(26)
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .alignItems(HorizontalAlign.Start)

            // 相关神兽
            if (this.relatedCreatures.length > 0) {
              Column({ space: 12 }) {
                Text('相关神兽')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(DarkTheme.textPrimary)
                  .padding({ left: 16 })

                Scroll() {
                  Row({ space: 12 }) {
                    ForEach(this.relatedCreatures, (creature: MythicalCreature) => {
                      Column() {
                        Image($r(`app.media.${creature.image}`))
                          .width(100)
                          .height(100)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(8)

                        Text(creature.name.cn)
                          .fontSize(12)
                          .fontColor(DarkTheme.textPrimary)
                          .margin({ top: 6 })
                      }
                      .onClick(() => {
                        router.pushUrl({
                          url: 'pages/CreatureDetail',
                          params: { creatureId: creature.id }
                        });
                      })
                    })
                  }
                  .padding({ left: 16, right: 16 })
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
              }
              .width('100%')
              .margin({ top: 24 })
              .alignItems(HorizontalAlign.Start)
            }

            Column()
              .height(32)
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DarkTheme.accent)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
