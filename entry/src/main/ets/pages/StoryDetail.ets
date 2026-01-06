/**
 * 神话志 - 故事详情页面
 * 神话故事阅读，支持章节翻页
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { MythStory, StoryChapter } from '../model/MythStory';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { Storage } from '../utils/Storage';

interface RouterParams {
  storyId: string;
}

@Entry
@Component
struct StoryDetail {
  @State story: MythStory | null = null;
  @State currentChapter: number = 0;
  @State isLoading: boolean = true;
  @State isFavorite: boolean = false;
  @State relatedCreatures: MythicalCreature[] = [];
  @State relatedDeities: Deity[] = [];
  private storyId: string = '';
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.storyId) {
      this.storyId = params.storyId;
      this.loadStory();
    }
  }

  async loadStory() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      // 获取故事数据
      this.story = dataLoader.getStoryById(this.storyId) || null;

      if (this.story) {
        // 加载相关神兽
        if (this.story.relatedCreatures && this.story.relatedCreatures.length > 0) {
          for (const id of this.story.relatedCreatures) {
            const creature = dataLoader.getCreatureById(id);
            if (creature) {
              this.relatedCreatures.push(creature);
            }
          }
        }

        // 加载相关主神
        if (this.story.relatedDeities && this.story.relatedDeities.length > 0) {
          for (const id of this.story.relatedDeities) {
            const deity = dataLoader.getDeityById(id);
            if (deity) {
              this.relatedDeities.push(deity);
            }
          }
        }

        // 检查收藏状态
        this.checkFavoriteStatus();

        // 读取阅读进度
        this.loadReadingProgress();

        // 记录浏览历史
        this.saveToHistory();
      }
    } catch (error) {
      console.error('Failed to load story:', error);
    }

    this.isLoading = false;
  }

  async checkFavoriteStatus() {
    try {
      const storage = Storage.getInstance();
      this.isFavorite = await storage.isStoryFavorite(this.storyId);
    } catch (error) {
      console.error('Failed to check favorite status:', error);
    }
  }

  async toggleFavorite() {
    if (!this.story) return;

    try {
      const storage = Storage.getInstance();
      if (this.isFavorite) {
        await storage.removeStoryFavorite(this.storyId);
      } else {
        await storage.addStoryFavorite(this.storyId);
      }
      this.isFavorite = !this.isFavorite;
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  }

  async loadReadingProgress() {
    try {
      const storage = Storage.getInstance();
      const progress = await storage.getStoryProgress(this.storyId);
      if (progress > 0 && this.story && progress < this.story.chapters.length) {
        this.currentChapter = progress;
        this.swiperController.showNext();
      }
    } catch (error) {
      console.error('Failed to load reading progress:', error);
    }
  }

  async saveReadingProgress() {
    try {
      const storage = Storage.getInstance();
      await storage.saveStoryProgress(this.storyId, this.currentChapter);
    } catch (error) {
      console.error('Failed to save reading progress:', error);
    }
  }

  async saveToHistory() {
    if (!this.story) return;

    try {
      const storage = Storage.getInstance();
      await storage.addBrowsingHistoryWithType(this.storyId, 'story');
    } catch (error) {
      console.error('Failed to save to history:', error);
    }
  }

  getTotalPages(): number {
    if (!this.story) return 0;
    // 章节数 + 1（关联内容页）
    return this.story.chapters.length + 1;
  }

  build() {
    Stack() {
      // 背景图片（封面模糊处理）
      if (this.story) {
        Image($r(`app.media.${this.story.cover}`))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .blur(30)
          .opacity(0.3)
      }

      // 背景渐变遮罩
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['rgba(18,18,18,0.7)', 0], ['rgba(18,18,18,0.95)', 1]]
        })

      Column() {
        if (this.isLoading) {
          this.LoadingView()
        } else if (this.story) {
          // 顶部导航栏
          this.NavigationBar()

          // 章节翻页区域
          Swiper(this.swiperController) {
            // 渲染每个章节
            ForEach(this.story.chapters, (chapter: StoryChapter, index: number) => {
              this.ChapterPage(chapter, index)
            }, (chapter: StoryChapter, index: number) => `chapter_${index}`)

            // 最后一页：关联内容
            this.RelatedContentPage()
          }
          .width('100%')
          .layoutWeight(1)
          .indicator(false)
          .loop(false)
          .index(this.currentChapter)
          .onChange((index: number) => {
            this.currentChapter = index;
            this.saveReadingProgress();
          })

          // 底部进度指示
          this.ProgressIndicator()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  NavigationBar() {
    Row() {
      // 返回按钮
      Stack() {
        Circle()
          .width(40)
          .height(40)
          .fill('rgba(255,255,255,0.1)')

        Image($r('app.media.ic_arrow_left'))
          .width(20)
          .height(20)
          .fillColor(DarkTheme.textPrimary)
      }
      .onClick(() => {
        router.back();
      })

      // 标题
      Column() {
        Text(this.story?.title || '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .padding({ left: 12, right: 12 })

      // 收藏按钮
      Stack() {
        Circle()
          .width(40)
          .height(40)
          .fill('rgba(255,255,255,0.1)')

        Image(this.isFavorite ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite'))
          .width(20)
          .height(20)
          .fillColor(this.isFavorite ? '#FF6B6B' : DarkTheme.textPrimary)
      }
      .onClick(() => {
        this.toggleFavorite();
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16, top: 8 })
    .margin({ top: 40 })
  }

  @Builder
  ChapterPage(chapter: StoryChapter, index: number) {
    Scroll() {
      Column({ space: 20 }) {
        // 章节标题
        Row({ space: 8 }) {
          Text(`第${this.chapterNumberToChinese(index + 1)}章`)
            .fontSize(12)
            .fontColor(DarkTheme.accent)
            .backgroundColor(DarkTheme.accent + '22')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(12)

          Text(chapter.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        // 分隔线
        Row()
          .width(60)
          .height(2)
          .backgroundColor(DarkTheme.accent)
          .borderRadius(1)

        // 章节内容
        Text(chapter.content)
          .fontSize(16)
          .fontColor(DarkTheme.textSecondary)
          .lineHeight(28)
          .letterSpacing(0.5)

        // 底部留白
        Column()
          .height(80)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 20 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  RelatedContentPage() {
    Scroll() {
      Column({ space: 24 }) {
        // 完结标识
        Column({ space: 12 }) {
          Image($r('app.media.ic_story'))
            .width(48)
            .height(48)
            .fillColor(DarkTheme.accent)

          Text('故事完结')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Text(this.story?.subtitle || '')
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 40, bottom: 20 })

        // 故事标签
        if (this.story && this.story.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
            ForEach(this.story.tags, (tag: string) => {
              Text(`#${tag}`)
                .fontSize(12)
                .fontColor(DarkTheme.accent)
                .backgroundColor(DarkTheme.accent + '22')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(16)
                .margin(4)
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }

        // 相关神兽
        if (this.relatedCreatures.length > 0) {
          Column({ space: 12 }) {
            Text('相关神兽')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)
              .width('100%')
              .padding({ left: 16 })

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.relatedCreatures, (creature: MythicalCreature) => {
                  Column() {
                    Image($r(`app.media.${creature.image}`))
                      .width(80)
                      .height(80)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(12)

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
          .alignItems(HorizontalAlign.Start)
        }

        // 相关主神
        if (this.relatedDeities.length > 0) {
          Column({ space: 12 }) {
            Text('相关主神')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)
              .width('100%')
              .padding({ left: 16 })

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.relatedDeities, (deity: Deity) => {
                  Column() {
                    Image($r(`app.media.${deity.image}`))
                      .width(80)
                      .height(80)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(12)

                    Text(deity.name.cn)
                      .fontSize(12)
                      .fontColor(DarkTheme.textPrimary)
                      .margin({ top: 6 })
                  }
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/DeityDetail',
                      params: { deityId: deity.id }
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
          .alignItems(HorizontalAlign.Start)
        }

        // 返回按钮
        Button('返回文化详情')
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .backgroundColor(DarkTheme.accent)
          .borderRadius(24)
          .width('60%')
          .height(44)
          .margin({ top: 20 })
          .onClick(() => {
            router.back();
          })

        // 底部留白
        Column()
          .height(60)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  ProgressIndicator() {
    Row({ space: 16 }) {
      // 左箭头
      Image($r('app.media.ic_arrow_left'))
        .width(20)
        .height(20)
        .fillColor(this.currentChapter > 0 ? DarkTheme.textSecondary : DarkTheme.textTertiary)
        .onClick(() => {
          if (this.currentChapter > 0) {
            this.swiperController.showPrevious();
          }
        })

      // 进度点
      Row({ space: 6 }) {
        ForEach(Array.from({ length: this.getTotalPages() }), (item: undefined, index: number) => {
          Circle()
            .width(index === this.currentChapter ? 16 : 6)
            .height(6)
            .fill(index === this.currentChapter ? DarkTheme.accent : DarkTheme.textTertiary)
            .borderRadius(3)
        }, (item: undefined, index: number) => `dot_${index}`)
      }

      // 右箭头
      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(this.currentChapter < this.getTotalPages() - 1 ? DarkTheme.textSecondary : DarkTheme.textTertiary)
        .onClick(() => {
          if (this.currentChapter < this.getTotalPages() - 1) {
            this.swiperController.showNext();
          }
        })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(18,18,18,0.8)')
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

  // 将数字转换为中文数字
  chapterNumberToChinese(num: number): string {
    const chineseNumbers = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (num <= 10) {
      return chineseNumbers[num];
    } else if (num < 20) {
      return '十' + chineseNumbers[num - 10];
    } else if (num < 100) {
      const tens = Math.floor(num / 10);
      const ones = num % 10;
      return chineseNumbers[tens] + '十' + (ones > 0 ? chineseNumbers[ones] : '');
    }
    return num.toString();
  }
}
