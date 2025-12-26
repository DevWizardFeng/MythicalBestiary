/**
 * 神话志 - 主神列表页
 * 按文化分类浏览主神
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor } from '../common/Constants';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';

interface FilterOption {
  id: string;
  name: string;
}

interface RouterParams {
  culture?: string;
}

@Entry
@Component
struct DeityList {
  @State deities: Deity[] = [];
  @State filteredDeities: Deity[] = [];
  @State isLoading: boolean = true;
  @State currentFilter: string = 'all';

  private cultureFilters: FilterOption[] = [
    { id: 'all', name: '全部' },
    { id: 'chinese', name: '中国' },
    { id: 'greek', name: '希腊' },
    { id: 'norse', name: '北欧' },
    { id: 'japanese', name: '日本' },
    { id: 'indian', name: '印度' }
  ];

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params?.culture) {
      this.currentFilter = params.culture;
    }
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.deities = dataLoader.getAllDeities();
      this.applyFilter();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load deities:', error);
      this.isLoading = false;
    }
  }

  applyFilter() {
    if (this.currentFilter === 'all') {
      this.filteredDeities = this.deities;
    } else {
      this.filteredDeities = this.deities.filter(d => d.culture === this.currentFilter);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.TopBar()

      // 文化筛选
      this.FilterBar()

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.filteredDeities.length === 0) {
        this.EmptyView()
      } else {
        // 主神网格列表
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
          .fill(DarkTheme.backgroundSecondary)

        Image($r('app.media.ic_arrow_left'))
          .width(20)
          .height(20)
      }
      .onClick(() => {
        router.back();
      })

      Text('神祇图鉴')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .margin({ left: 12 })

      Blank()

      Text(`${this.filteredDeities.length}位`)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 12 })
  }

  @Builder
  FilterBar() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.cultureFilters, (filter: FilterOption) => {
          Text(filter.name)
            .fontSize(13)
            .fontColor(this.currentFilter === filter.id ? '#ffffff' : DarkTheme.textSecondary)
            .backgroundColor(this.currentFilter === filter.id ? DarkTheme.accent : DarkTheme.backgroundSecondary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(18)
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
    .height(50)
  }

  @Builder
  DeityCard(deity: Deity) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 主神图片
        Image($r(`app.media.${deity.image}`))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 渐变遮罩
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Top,
            colors: [['rgba(0,0,0,0.5)', 0], ['rgba(0,0,0,0)', 0.5]]
          })

        // 文化标签
        Text(getCultureName(deity.culture as CultureType).cn)
          .fontSize(10)
          .fontColor('#ffffff')
          .padding({ left: 6, right: 6, top: 3, bottom: 3 })
          .backgroundColor(getCultureColor(deity.culture as CultureType))
          .borderRadius(8)
          .margin({ left: 8, top: 8 })
      }
      .width('100%')
      .height(140)

      // 主神信息
      Column({ space: 4 }) {
        Text(deity.name.cn)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 神职领域
        Row({ space: 4 }) {
          ForEach(deity.domain.slice(0, 2), (domain: string) => {
            Text(domain)
              .fontSize(10)
              .fontColor(DarkTheme.accent)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(DarkTheme.accent + '22')
              .borderRadius(8)
          })
          if (deity.domain.length > 2) {
            Text(`+${deity.domain.length - 2}`)
              .fontSize(10)
              .fontColor(DarkTheme.textTertiary)
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(10)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
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

      Text('暂无神祇')
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
