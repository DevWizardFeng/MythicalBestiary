/**
 * 神话志 - 图鉴列表页
 * 多维度筛选浏览神兽
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, AttributeType, RarityType, AlignmentType, CreatureType,
  CultureNames, AttributeNames, RarityNames, AlignmentNames, CreatureTypeNames } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';
import { CreatureCard } from '../components/CreatureCard';
import { SearchBar } from '../components/SearchBar';

interface FilterOption {
  id: string;
  name: string;
}

interface RouterParams {
  filterType?: string;
  filterValue?: string;
}

@Entry
@Component
struct CreatureList {
  @State creatures: MythicalCreature[] = [];
  @State filteredCreatures: MythicalCreature[] = [];
  @State isLoading: boolean = true;
  @State currentFilter: string = 'all';
  @State currentFilterType: string = 'culture';
  @State searchKeyword: string = '';

  private filterTypes: FilterOption[] = [
    { id: 'culture', name: '文化' },
    { id: 'attribute', name: '属性' },
    { id: 'rarity', name: '稀有度' },
    { id: 'alignment', name: '阵营' }
  ];

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

  private alignmentFilters: FilterOption[] = [
    { id: 'all', name: '全部' },
    { id: 'guardian', name: '守护' },
    { id: 'neutral', name: '中立' },
    { id: 'evil', name: '邪恶' }
  ];

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouterParams;
    if (params?.filterType && params?.filterValue) {
      this.currentFilterType = params.filterType;
      this.currentFilter = params.filterValue;
    }
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.creatures = dataLoader.getAllCreatures();
      this.applyFilter();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load creatures:', error);
      this.isLoading = false;
    }
  }

  applyFilter() {
    let result = this.creatures;

    // 应用分类筛选
    if (this.currentFilter !== 'all') {
      switch (this.currentFilterType) {
        case 'culture':
          result = result.filter(c => c.culture === this.currentFilter);
          break;
        case 'attribute':
          result = result.filter(c => c.attributes.primary === this.currentFilter);
          break;
        case 'rarity':
          result = result.filter(c => c.rarity === this.currentFilter);
          break;
        case 'alignment':
          result = result.filter(c => c.alignment === this.currentFilter);
          break;
      }
    }

    // 应用搜索过滤
    if (this.searchKeyword.length > 0) {
      const keyword = this.searchKeyword.toLowerCase();
      result = result.filter(c =>
        c.name.cn.toLowerCase().includes(keyword) ||
        c.name.en.toLowerCase().includes(keyword) ||
        c.description.toLowerCase().includes(keyword)
      );
    }

    this.filteredCreatures = result;
  }

  getCurrentFilters(): FilterOption[] {
    switch (this.currentFilterType) {
      case 'culture': return this.cultureFilters;
      case 'attribute': return this.attributeFilters;
      case 'rarity': return this.rarityFilters;
      case 'alignment': return this.alignmentFilters;
      default: return this.cultureFilters;
    }
  }

  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.bg_main_mystical'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.back();
            })

          Text('神兽图鉴')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 16 })

          Blank()

          Text(`${this.filteredCreatures.length}只`)
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 筛选类型切换
      Row({ space: 0 }) {
        ForEach(this.filterTypes, (type: FilterOption) => {
          Text(type.name)
            .fontSize(14)
            .fontColor(this.currentFilterType === type.id ? DarkTheme.accent : DarkTheme.textSecondary)
            .fontWeight(this.currentFilterType === type.id ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.currentFilterType = type.id;
              this.currentFilter = 'all';
              this.applyFilter();
            })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .backgroundColor(DarkTheme.backgroundCard)

      // 筛选选项
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.getCurrentFilters(), (filter: FilterOption) => {
            Text(filter.name)
              .fontSize(12)
              .fontColor(this.currentFilter === filter.id ? '#ffffff' : DarkTheme.textSecondary)
              .backgroundColor(this.currentFilter === filter.id ? DarkTheme.accent : DarkTheme.backgroundSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.currentFilter = filter.id;
                this.applyFilter();
              })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(44)

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.filteredCreatures.length === 0) {
        this.EmptyView()
      } else {
        // 神兽网格列表
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
      .height('100%')
    }
    .width('100%')
    .height('100%')
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
  EmptyView() {
    Column() {
      Image($r('app.media.ic_search'))
        .width(64)
        .height(64)

      Text('暂无神兽')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Text('换个筛选条件试试')
        .fontSize(14)
        .fontColor(DarkTheme.textTertiary)
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
