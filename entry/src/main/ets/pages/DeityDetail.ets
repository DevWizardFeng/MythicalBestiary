/**
 * 神话志 - 主神详情页
 * 全屏展示主神详细信息
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor, CultureNameInfo } from '../common/Constants';
import { Deity, DeityStory, DeityRelationship, getRelationshipTypeName } from '../model/Deity';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';

interface RouterParams {
  deityId: string;
}

@Entry
@Component
struct DeityDetail {
  @State deity: Deity | null = null;
  @State relatedCreatures: MythicalCreature[] = [];
  @State relatedDeities: Deity[] = [];
  @State isFavorite: boolean = false;
  @State isLoading: boolean = true;
  @State currentTab: number = 0;
  private deityId: string = '';

  private tabs: string[] = ['神话传说', '著名事迹', '神族关系'];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.deityId) {
      this.deityId = params.deityId;
      this.loadData();
    }
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      this.deity = dataLoader.getDeityById(this.deityId) || null;

      if (this.deity) {
        // 获取掌管神兽
        this.relatedCreatures = dataLoader.getCreaturesByDeity(this.deityId);

        // 获取关联神祇
        if (this.deity.relationships && this.deity.relationships.length > 0) {
          const results: Deity[] = [];
          for (const r of this.deity.relationships) {
            const deity = dataLoader.getDeityById(r.deityId);
            if (deity !== undefined) {
              results.push(deity);
            }
          }
          this.relatedDeities = results;
        }

        // 检查是否已收藏
        const storage = StorageUtil.getInstance();
        await storage.initialize();
        this.isFavorite = await storage.isDeityFavorite(this.deityId);

        // 记录浏览历史
        await storage.addBrowsingHistoryWithType(this.deityId, 'deity');
      }

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load deity detail:', error);
      this.isLoading = false;
    }
  }

  async toggleFavorite() {
    try {
      const storage = StorageUtil.getInstance();
      if (this.isFavorite) {
        await storage.removeDeityFavorite(this.deityId);
      } else {
        await storage.addDeityFavorite(this.deityId);
      }
      this.isFavorite = !this.isFavorite;
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.deity) {
        Scroll() {
          Column() {
            // 顶部大图
            this.HeroImage()

            // 基本信息
            this.BasicInfo()

            // Tab内容
            this.TabContent()

            // 掌管神兽
            if (this.relatedCreatures.length > 0) {
              this.RelatedCreatures()
            }

            // 底部占位
            Column()
              .height(32)
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        // 顶部导航栏
        this.TopBar()
      } else {
        this.ErrorView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  TopBar() {
    Row() {
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
      .onClick(() => {
        router.back();
      })

      Blank()

      // 收藏按钮
      Stack() {
        Circle()
          .width(36)
          .height(36)
          .fill('rgba(0,0,0,0.3)')

        Image(this.isFavorite ? $r('app.media.ic_favorite_filled') : $r('app.media.ic_favorite'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        this.toggleFavorite();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 12 })
  }

  @Builder
  HeroImage() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主神图片
      Image($r(`app.media.${this.deity?.image}`))
        .width('100%')
        .height(400)
        .objectFit(ImageFit.Cover)

      // 渐变遮罩
      Column()
        .width('100%')
        .height('50%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [[DarkTheme.background, 0], ['rgba(18,18,18,0)', 1]]
        })
    }
    .width('100%')
    .height(400)
  }

  @Builder
  BasicInfo() {
    Column({ space: 16 }) {
      // 名称
      Row({ space: 12 }) {
        Text(this.deity?.name.cn)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        // 文化标签
        Text(getCultureName(this.deity?.culture as CultureType).cn)
          .fontSize(12)
          .fontColor('#ffffff')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(getCultureColor(this.deity?.culture as CultureType))
          .borderRadius(12)
      }
      .width('100%')

      // 英文名和原名
      Column({ space: 4 }) {
        Text(this.deity?.name.en)
          .fontSize(16)
          .fontColor(DarkTheme.textSecondary)

        if (this.deity?.name.original && this.deity?.name.original !== this.deity?.name.cn) {
          Text(`原名: ${this.deity?.name.original}`)
            .fontSize(14)
            .fontColor(DarkTheme.textTertiary)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // 神职领域
      if (this.deity?.domain && this.deity.domain.length > 0) {
        Row({ space: 8 }) {
          ForEach(this.deity.domain, (domain: string) => {
            Text(domain)
              .fontSize(12)
              .fontColor(DarkTheme.accent)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(DarkTheme.accent + '22')
              .borderRadius(16)
          })
        }
        .width('100%')
      }

      // 象征物品
      if (this.deity?.symbols && this.deity.symbols.length > 0) {
        Column({ space: 8 }) {
          Text('象征物品')
            .fontSize(12)
            .fontColor(DarkTheme.textTertiary)

          Row({ space: 8 }) {
            ForEach(this.deity.symbols, (symbol: string) => {
              Text(symbol)
                .fontSize(12)
                .fontColor(DarkTheme.textSecondary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(DarkTheme.backgroundSecondary)
                .borderRadius(8)
            })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      // 简介
      Text(this.deity?.description)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TabContent() {
    Column({ space: 16 }) {
      // Tab标签
      Row({ space: 0 }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? DarkTheme.accent : DarkTheme.textSecondary)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)

            if (this.currentTab === index) {
              Column()
                .width(24)
                .height(2)
                .backgroundColor(DarkTheme.accent)
                .borderRadius(1)
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 8 })
          .onClick(() => {
            this.currentTab = index;
          })
        })
      }
      .width('100%')
      .backgroundColor(DarkTheme.backgroundCard)
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 24 })

      // Tab内容
      Column() {
        if (this.currentTab === 0) {
          this.MythologyContent()
        } else if (this.currentTab === 1) {
          this.StoriesContent()
        } else {
          this.RelationshipsContent()
        }
      }
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  MythologyContent() {
    Column({ space: 12 }) {
      Text('神话传说')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text(this.deity?.mythology || '暂无神话传说记载')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .lineHeight(22)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StoriesContent() {
    Column({ space: 12 }) {
      Text('著名事迹')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      if (this.deity?.famousStories && this.deity.famousStories.length > 0) {
        ForEach(this.deity.famousStories, (story: DeityStory, index: number) => {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(`${index + 1}`)
                .fontSize(12)
                .fontColor('#ffffff')
                .width(20)
                .height(20)
                .textAlign(TextAlign.Center)
                .backgroundColor(DarkTheme.accent)
                .borderRadius(10)

              Text(story.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(DarkTheme.textPrimary)
            }

            Text(story.description)
              .fontSize(13)
              .fontColor(DarkTheme.textSecondary)
              .lineHeight(20)
              .margin({ left: 28 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: index > 0 ? 12 : 0 })
        })
      } else {
        Text('暂无著名事迹记载')
          .fontSize(14)
          .fontColor(DarkTheme.textTertiary)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RelationshipsContent() {
    Column({ space: 12 }) {
      Text('神族关系')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      if (this.deity?.relationships && this.deity.relationships.length > 0) {
        ForEach(this.deity.relationships, (rel: DeityRelationship) => {
          Row({ space: 12 }) {
            // 关系类型标签
            Text(getRelationshipTypeName(rel.type))
              .fontSize(11)
              .fontColor(DarkTheme.accent)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(DarkTheme.accent + '22')
              .borderRadius(8)

            Column({ space: 4 }) {
              // 找到关联神祇的名称
              Text(this.getDeityName(rel.deityId))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(DarkTheme.textPrimary)

              Text(rel.description)
                .fontSize(12)
                .fontColor(DarkTheme.textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/DeityDetail',
              params: { deityId: rel.deityId }
            });
          })
        })
      } else {
        Text('暂无神族关系记载')
          .fontSize(14)
          .fontColor(DarkTheme.textTertiary)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  getDeityName(deityId: string): string {
    const deity = this.relatedDeities.find(d => d.id === deityId);
    return deity ? deity.name.cn : deityId;
  }

  @Builder
  RelatedCreatures() {
    Column({ space: 12 }) {
      Text('掌管神兽')
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
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(100)
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

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DarkTheme.accent)

      Text('加载中...')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorView() {
    Column() {
      Image($r('app.media.ic_search'))
        .width(64)
        .height(64)

      Text('神祇未找到')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Button('返回')
        .fontSize(14)
        .fontColor('#ffffff')
        .backgroundColor(DarkTheme.accent)
        .margin({ top: 24 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
