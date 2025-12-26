/**
 * 神话志 - 专题列表页面
 * 神话专题文章列表
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';

interface Topic {
  id: string;
  title: string;
  subtitle: string;
  cover: string;
  category: string;
  readCount: number;
}

@Entry
@Component
struct TopicList {
  @State topics: Topic[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadTopics();
  }

  loadTopics() {
    // 模拟专题数据
    this.topics = [
      {
        id: 'topic_1',
        title: '四大神兽的起源与演变',
        subtitle: '探索青龙、白虎、朱雀、玄武的神话渊源',
        cover: 'creature_chinese_qinglong',
        category: '中国神话',
        readCount: 12580
      },
      {
        id: 'topic_2',
        title: '希腊神话中的怪物图鉴',
        subtitle: '从九头蛇到美杜莎，揭秘希腊怪物的秘密',
        cover: 'creature_greek_hydra',
        category: '希腊神话',
        readCount: 9876
      },
      {
        id: 'topic_3',
        title: '北欧神话中的巨兽',
        subtitle: '世界蛇尤蒙冈德与魔狼芬里尔的传说',
        cover: 'creature_norse_fenrir',
        category: '北欧神话',
        readCount: 8765
      },
      {
        id: 'topic_4',
        title: '日本妖怪文化探秘',
        subtitle: '百鬼夜行中的著名妖怪故事',
        cover: 'creature_japanese_kitsune',
        category: '日本神话',
        readCount: 15432
      },
      {
        id: 'topic_5',
        title: '龙的东西方形象对比',
        subtitle: '为何东方龙与西方龙如此不同',
        cover: 'creature_chinese_yinglong',
        category: '比较神话',
        readCount: 20156
      },
      {
        id: 'topic_6',
        title: '凤凰与不死鸟的传说',
        subtitle: '从中国凤凰到希腊菲尼克斯',
        cover: 'creature_chinese_fenghuang',
        category: '比较神话',
        readCount: 11234
      }
    ];
    this.isLoading = false;
  }

  formatReadCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + '万';
    }
    return count.toString();
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('神话专题')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.isLoading) {
        this.LoadingView()
      } else {
        List() {
          ForEach(this.topics, (topic: Topic) => {
            ListItem() {
              this.TopicItem(topic)
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  TopicItem(topic: Topic) {
    Column() {
      // 封面图
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r(`app.media.${topic.cover}`))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 渐变遮罩
        Column()
          .width('100%')
          .height('50%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['rgba(0,0,0,0.6)', 0], ['rgba(0,0,0,0)', 1]]
          })

        // 分类标签
        Text(topic.category)
          .fontSize(12)
          .fontColor('#ffffff')
          .backgroundColor('rgba(255,255,255,0.2)')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
          .margin(12)
      }
      .width('100%')
      .height(160)

      // 内容
      Column({ space: 8 }) {
        Text(topic.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(topic.subtitle)
          .fontSize(13)
          .fontColor(DarkTheme.textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(20)

        Row() {
          Text(`${this.formatReadCount(topic.readCount)}人阅读`)
            .fontSize(12)
            .fontColor(DarkTheme.textTertiary)
        }
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/TopicDetail',
        params: { topicId: topic.id }
      });
    })
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
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
