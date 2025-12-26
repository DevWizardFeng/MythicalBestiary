/**
 * 神话志 - 图鉴Tab组件
 * 顶部Tab切换（神祇/神兽两个子页面）
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor, getAttributeName, getAttributeColor, AttributeType, RarityType, getRarityName, getRarityColor } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { CreatureCard } from './CreatureCard';

interface FilterOption {
  id: string;
  name: string;
}

@Component
export struct GuideTab {
  @State currentTabIndex: number = 0;
  @State isLoading: boolean = true;
  // 神祇数据
  @State deities: Deity[] = [];
  @State filteredDeities: Deity[] = [];
  @State deityFilter: string = 'all';
  // 神兽数据
  @State creatures: MythicalCreature[] = [];
  @State filteredCreatures: MythicalCreature[] = [];
  @State creatureFilterType: string = 'culture';
  @State creatureFilter: string = 'all';

  private cultureFilters: FilterOption[] = [
    { id: 'all', name: '全部' },
    { id: 'chinese', name: '中国' },
    { id: 'greek', name: '希腊' },
    { id: 'norse', name: '北欧' },
    { id: 'japanese', name: '日本' },
    { id: 'indian', name: '印度' },
    { id: 'egyptian', name: '埃及' },
    { id: 'celtic', name: '凯尔特' }
  ];

  private attributeFilters: FilterOption[] = [
    { id: 'all', name: '全部' },
    { id: 'fire', name: '火' },
    { id: 'water', name: '水' },
    { id: 'wind', name: '风' },
    { id: 'thunder', name: '雷' },
    { id: 'light', name: '光' },
    { id: 'dark', name: '暗' },
    { id: 'nature', name: '自然' }
  ];

  private rarityFilters: FilterOption[] = [
    { id: 'all', name: '全部' },
    { id: 'legendary', name: '传说' },
    { id: 'epic', name: '史诗' },
    { id: 'rare', name: '稀有' },
    { id: 'common', name: '普通' }
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.deities = dataLoader.getAllDeities();
      this.creatures = dataLoader.getAllCreatures();
      this.filteredDeities = this.deities;
      this.filteredCreatures = this.creatures;
      this.isLoading = false;
    } catch (error) {
      console.error('GuideTab: Failed to load data', error);
      this.isLoading = false;
    }
  }

  applyDeityFilter() {
    if (this.deityFilter === 'all') {
      this.filteredDeities = this.deities;
    } else {
      this.filteredDeities = this.deities.filter(d => d.culture === this.deityFilter);
    }
  }

  applyCreatureFilter() {
    let result = this.creatures;
    if (this.creatureFilter !== 'all') {
      switch (this.creatureFilterType) {
        case 'culture':
          result = result.filter(c => c.culture === this.creatureFilter);
          break;
        case 'attribute':
          result = result.filter(c => c.attributes.primary === this.creatureFilter);
          break;
        case 'rarity':
          result = result.filter(c => c.rarity === this.creatureFilter);
          break;
      }
    }
    this.filteredCreatures = result;
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('神话图鉴')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Text(this.currentTabIndex === 0 ? `${this.filteredDeities.length}位` : `${this.filteredCreatures.length}只`)
          .fontSize(14)
          .fontColor(DarkTheme.textSecondary)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 子Tab切换
      Row({ space: 0 }) {
        this.SubTabItem('神祇', 0)
        this.SubTabItem('神兽', 1)
      }
      .width('100%')
      .height(44)
      .backgroundColor(DarkTheme.backgroundCard)

      if (this.isLoading) {
        this.LoadingView()
      } else {
        if (this.currentTabIndex === 0) {
          this.DeityContent()
        } else {
          this.CreatureContent()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  SubTabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIndex === index ? DarkTheme.accent : DarkTheme.textSecondary)

      if (this.currentTabIndex === index) {
        Column()
          .width(24)
          .height(3)
          .backgroundColor(DarkTheme.accent)
          .borderRadius(2)
          .margin({ top: 6 })
      }
    }
    .width('50%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTabIndex = index;
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
  DeityContent() {
    Column() {
      // 文化筛选
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.cultureFilters, (filter: FilterOption) => {
            Text(filter.name)
              .fontSize(12)
              .fontColor(this.deityFilter === filter.id ? '#ffffff' : DarkTheme.textSecondary)
              .backgroundColor(this.deityFilter === filter.id ? DarkTheme.accent : DarkTheme.backgroundSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.deityFilter = filter.id;
                this.applyDeityFilter();
              })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(44)

      // 神祇列表
      if (this.filteredDeities.length === 0) {
        this.EmptyView('暂无神祇数据')
      } else {
        Grid() {
          ForEach(this.filteredDeities, (deity: Deity) => {
            GridItem() {
              this.DeityCard(deity)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  DeityCard(deity: Deity) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r(`app.media.${deity.image}`))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 渐变遮罩（底部变暗）
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['rgba(0,0,0,0.4)', 0], ['rgba(0,0,0,0)', 0.5]]
          })
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 文化标签
        Text(getCultureName(deity.culture as CultureType).cn)
          .fontSize(10)
          .fontColor('#ffffff')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(getCultureColor(deity.culture as CultureType))
          .borderRadius(8)
          .margin({ left: 8, top: 8 })
      }
      .width('100%')
      .height(140)

      Column({ space: 4 }) {
        Text(deity.name.cn)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: 4 }) {
          ForEach(deity.domain.slice(0, 2), (domain: string, index: number) => {
            Text(domain)
              .fontSize(10)
              .fontColor(DarkTheme.accent)
              .backgroundColor(DarkTheme.accent + '22')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }, (domain: string, index: number) => `${deity.id}_${index}`)

          if (deity.domain.length > 2) {
            Text(`+${deity.domain.length - 2}`)
              .fontSize(10)
              .fontColor(DarkTheme.textSecondary)
          }
        }
      }
      .padding(8)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .backgroundColor(DarkTheme.backgroundCard)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DeityDetail',
        params: { deityId: deity.id }
      });
    })
  }

  @Builder
  CreatureContent() {
    Column() {
      // 筛选类型切换
      Row({ space: 0 }) {
        ForEach(['文化', '属性', '稀有度'], (type: string, index: number) => {
          Text(type)
            .fontSize(14)
            .fontColor(this.getCreatureFilterTypeIndex() === index ? DarkTheme.accent : DarkTheme.textSecondary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              const types = ['culture', 'attribute', 'rarity'];
              this.creatureFilterType = types[index];
              this.creatureFilter = 'all';
              this.applyCreatureFilter();
            })
        })
      }
      .width('100%')
      .backgroundColor(DarkTheme.backgroundCard)

      // 具体筛选选项
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getCurrentFilters(), (filter: FilterOption) => {
            Text(filter.name)
              .fontSize(12)
              .fontColor(this.creatureFilter === filter.id ? '#ffffff' : DarkTheme.textSecondary)
              .backgroundColor(this.creatureFilter === filter.id ? DarkTheme.accent : DarkTheme.backgroundSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.creatureFilter = filter.id;
                this.applyCreatureFilter();
              })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(44)

      // 神兽列表
      if (this.filteredCreatures.length === 0) {
        this.EmptyView('暂无神兽数据')
      } else {
        Grid() {
          ForEach(this.filteredCreatures, (creature: MythicalCreature) => {
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
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  getCreatureFilterTypeIndex(): number {
    switch (this.creatureFilterType) {
      case 'culture': return 0;
      case 'attribute': return 1;
      case 'rarity': return 2;
      default: return 0;
    }
  }

  getCurrentFilters(): FilterOption[] {
    switch (this.creatureFilterType) {
      case 'culture': return this.cultureFilters;
      case 'attribute': return this.attributeFilters;
      case 'rarity': return this.rarityFilters;
      default: return this.cultureFilters;
    }
  }

  @Builder
  EmptyView(message: string) {
    Column() {
      Text(message)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
