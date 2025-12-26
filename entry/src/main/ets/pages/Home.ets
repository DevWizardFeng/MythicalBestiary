/**
 * 神话志 - 首页（发现页）
 * 混合轮播推荐 + 快速入口 + 传说神兽推荐
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, AttributeType, CultureNames, AttributeNames, AttributeColors, getCultureName, getCultureColor } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { Banner } from '../components/Banner';
import { SearchBar } from '../components/SearchBar';
import { CreatureCard } from '../components/CreatureCard';

interface QuickEntry {
  id: string;
  name: string;
  icon: Resource;
  color: string;
  type: 'culture' | 'attribute';
}

@Component
export struct Home {
  @State featuredDeities: Deity[] = [];
  @State featuredCreatures: MythicalCreature[] = [];
  @State legendaryCreatures: MythicalCreature[] = [];
  @State isLoading: boolean = true;
  @State deityCarouselIndex: number = 0;
  // 混合轮播数据
  @State mixedCarouselItems: Array<MythicalCreature | Deity> = [];

  private cultureEntries: QuickEntry[] = [
    { id: 'chinese', name: '中国', icon: $r('app.media.ic_culture_chinese'), color: '#dc143c', type: 'culture' },
    { id: 'greek', name: '希腊', icon: $r('app.media.ic_culture_greek'), color: '#4169e1', type: 'culture' },
    { id: 'norse', name: '北欧', icon: $r('app.media.ic_culture_norse'), color: '#1e90ff', type: 'culture' },
    { id: 'japanese', name: '日本', icon: $r('app.media.ic_culture_japanese'), color: '#ff69b4', type: 'culture' },
    { id: 'indian', name: '印度', icon: $r('app.media.ic_culture_indian'), color: '#ff8c00', type: 'culture' },
    { id: 'egyptian', name: '埃及', icon: $r('app.media.ic_culture_egyptian'), color: '#ffd700', type: 'culture' },
    { id: 'celtic', name: '凯尔特', icon: $r('app.media.ic_culture_celtic'), color: '#228b22', type: 'culture' }
  ];

  private attributeEntries: QuickEntry[] = [
    { id: 'fire', name: '火', icon: $r('app.media.ic_attr_fire'), color: '#ff4500', type: 'attribute' },
    { id: 'water', name: '水', icon: $r('app.media.ic_attr_water'), color: '#1e90ff', type: 'attribute' },
    { id: 'wind', name: '风', icon: $r('app.media.ic_attr_wind'), color: '#7fffd4', type: 'attribute' },
    { id: 'thunder', name: '雷', icon: $r('app.media.ic_attr_thunder'), color: '#9370db', type: 'attribute' },
    { id: 'light', name: '光', icon: $r('app.media.ic_attr_light'), color: '#ffd700', type: 'attribute' },
    { id: 'dark', name: '暗', icon: $r('app.media.ic_attr_dark'), color: '#2f4f4f', type: 'attribute' },
    { id: 'nature', name: '自然', icon: $r('app.media.ic_attr_nature'), color: '#228b22', type: 'attribute' }
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();
      const allDeities = dataLoader.getAllDeities();

      console.info(`Home: 加载了 ${allCreatures.length} 个神兽, ${allDeities.length} 个神祇`);

      // 获取精选主神（每种文化取1个）
      const cultures = ['chinese', 'greek', 'norse', 'japanese', 'indian'];
      const deityResults: Deity[] = [];
      for (const culture of cultures) {
        const deity = allDeities.find(d => d.culture === culture);
        if (deity !== undefined) {
          deityResults.push(deity);
          console.info(`Home: 找到${culture}神祇: ${deity.name.cn}, image=${deity.image}`);
        } else {
          console.warn(`Home: 未找到${culture}文化的神祇`);
        }
      }
      this.featuredDeities = deityResults;
      console.info(`Home: 精选神祇数量 ${this.featuredDeities.length}, IDs: ${deityResults.map(d => d.id).join(', ')}`);

      // 获取精选神兽（传说级）用于轮播
      this.featuredCreatures = allCreatures
        .filter(c => c.rarity === 'legendary')
        .slice(0, 5);

      // 获取传说神兽推荐
      this.legendaryCreatures = allCreatures
        .filter(c => c.rarity === 'legendary')
        .slice(0, 6);

      // 构建混合轮播数据（神祇和神兽交替）
      const mixedItems: Array<MythicalCreature | Deity> = [];
      const maxItems = Math.max(deityResults.length, this.featuredCreatures.length);
      for (let i = 0; i < maxItems && mixedItems.length < 6; i++) {
        if (i < deityResults.length) {
          mixedItems.push(deityResults[i]);
        }
        if (i < this.featuredCreatures.length && mixedItems.length < 6) {
          mixedItems.push(this.featuredCreatures[i]);
        }
      }
      this.mixedCarouselItems = mixedItems;
      console.info(`Home: 混合轮播项数量 ${this.mixedCarouselItems.length}`);

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load data:', error);
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        this.LoadingView()
      } else {
        Scroll() {
          Column({ space: 24 }) {
            // 神话精选轮播（混合神祇和神兽）
            Column({ space: 12 }) {
              Row() {
                this.SectionHeader('神话精选', '神祇与神兽的传说')
                Blank()
              }
              .width('100%').margin({
                top: 16
              })

              if (this.mixedCarouselItems.length > 0) {
                Swiper() {
                  ForEach(this.mixedCarouselItems, (item: MythicalCreature | Deity) => {
                    // 判断是神祇还是神兽 - 通过检查domain属性是否为数组来判断
                    if ((item as Deity).domain !== undefined && Array.isArray((item as Deity).domain)) {
                      this.DeityCarouselItem(item as Deity)
                    } else {
                      this.CreatureCarouselItem(item as MythicalCreature)
                    }
                  }, (item: MythicalCreature | Deity) => {
                    if ((item as Deity).domain !== undefined && Array.isArray((item as Deity).domain)) {
                      return `deity_${(item as Deity).id}`;
                    } else {
                      return `creature_${(item as MythicalCreature).id}`;
                    }
                  })
                }
                .autoPlay(true)
                .interval(4000)
                .indicator(
                  new DotIndicator()
                    .selectedColor(DarkTheme.accent)
                    .color('rgba(255,255,255,0.3)')
                )
                .loop(true)
                .height(200)
                .padding({ left: 16, right: 16 })
              } else {
                Text('暂无数据')
                  .fontSize(14)
                  .fontColor(DarkTheme.textSecondary)
                  .height(200)
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
            }

            // 文化体系快速入口
            Column({ space: 12 }) {
              this.SectionHeader('文化体系', '')

              Scroll() {
                Row({ space: 12 }) {
                  ForEach(this.cultureEntries, (entry: QuickEntry) => {
                    this.QuickEntryItem(entry)
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }

            // 传说神兽推荐
            if (this.legendaryCreatures.length > 0) {
              Column({ space: 12 }) {
                this.SectionHeader('传说神兽', '最强大的神话生物')

                Grid() {
                  ForEach(this.legendaryCreatures, (creature: MythicalCreature) => {
                    GridItem() {
                      CreatureCard({
                        creature: creature,
                        mode: 'grid',
                        onItemClick: (c: MythicalCreature) => {
                          router.pushUrl({
                            url: 'pages/CreatureDetail',
                            params: { creatureId: c.id }
                          });
                        }
                      })
                    }
                  })
                }
                .columnsTemplate('1fr 1fr')
                .rowsGap(12)
                .columnsGap(12)
                .width('100%')
                .padding({ left: 16, right: 16 })
              }
            }

            // 元素属性快速入口 - 放在传说神兽下方
            Column({ space: 12 }) {
              this.SectionHeader('元素属性', '')

              Scroll() {
                Row({ space: 12 }) {
                  ForEach(this.attributeEntries, (entry: QuickEntry) => {
                    this.QuickEntryItem(entry)
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }

            // 底部占位
            Column()
              .height(20)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  SectionHeader(title: string, subtitle: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      if (subtitle.length > 0) {
        Text(subtitle)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16 })
  }

  @Builder
  QuickEntryItem(entry: QuickEntry) {
    Column({ space: 8 }) {
      Image(entry.icon)
        .width(44)
        .height(44)
        .objectFit(ImageFit.Contain)
        .clip(true)
        .borderRadius(22)

      Text(entry.name)
        .fontSize(12)
        .fontColor(DarkTheme.textPrimary)
    }
    .width(68)
    .height(76)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      if (entry.type === 'culture') {
        router.pushUrl({
          url: 'pages/CultureDetail',
          params: { cultureId: entry.id }
        });
      } else {
        router.pushUrl({
          url: 'pages/AttributeDetail',
          params: { attributeId: entry.id }
        });
      }
    })
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
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  DeityCarouselItem(deity: Deity) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主神图片
      Image($r(`app.media.${deity.image}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      // 渐变遮罩
      Column()
        .width('100%')
        .height('60%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })

      // 主神信息
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(deity.name.cn)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Text(getCultureName(deity.culture as CultureType).cn)
            .fontSize(10)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor(getCultureColor(deity.culture as CultureType))
            .borderRadius(8)
        }

        Row({ space: 6 }) {
          ForEach(deity.domain.slice(0, 3), (domain: string, index: number) => {
            Text(domain)
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.8)')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor('rgba(255,255,255,0.2)')
              .borderRadius(10)
          }, (domain: string, index: number) => `${deity.id}_domain_${index}`)
        }
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .clip(true)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DeityDetail',
        params: { deityId: deity.id }
      });
    })
  }

  @Builder
  CreatureCarouselItem(creature: MythicalCreature) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 神兽图片
      Image($r(`app.media.${creature.image}`))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(16)

      // 渐变遮罩
      Column()
        .width('100%')
        .height('60%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })

      // 神兽信息
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(creature.name.cn)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Text(getCultureName(creature.culture as CultureType).cn)
            .fontSize(10)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .backgroundColor(getCultureColor(creature.culture as CultureType))
            .borderRadius(8)
        }

        Text(creature.description)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.8)')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .clip(true)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/CreatureDetail',
        params: { creatureId: creature.id }
      });
    })
  }
}
