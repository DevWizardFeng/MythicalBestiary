/**
 * 神话志 - 搜索页面
 * 实时搜索、热门词、搜索历史
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { SearchUtil } from '../utils/Search';
import { SearchBar } from '../components/SearchBar';
import { CreatureCard } from '../components/CreatureCard';

@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State searchResults: MythicalCreature[] = [];
  @State deityResults: Deity[] = [];
  @State searchHistory: string[] = [];
  @State isSearching: boolean = false;
  @State hasSearched: boolean = false;

  private hotKeywords: string[] = [
    '龙', '凤凰', '麒麟', '九尾狐',
    '宙斯', '奥丁', '天照', '女娲'
  ];

  aboutToAppear() {
    this.loadSearchHistory();
  }

  async loadSearchHistory() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      this.searchHistory = await storage.getSearchHistory();
    } catch (error) {
      console.error('Failed to load search history:', error);
    }
  }

  async performSearch(keyword: string) {
    if (keyword.trim().length === 0) {
      this.searchResults = [];
      this.deityResults = [];
      this.hasSearched = false;
      return;
    }

    this.isSearching = true;
    this.hasSearched = true;

    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();

      // 执行神兽搜索
      this.searchResults = SearchUtil.search(allCreatures, keyword);

      // 执行神祇搜索
      this.deityResults = dataLoader.searchDeities(keyword);

      // 保存搜索历史
      const storage = StorageUtil.getInstance();
      await storage.addSearchHistory(keyword);
      this.searchHistory = await storage.getSearchHistory();
    } catch (error) {
      console.error('Search failed:', error);
    } finally {
      this.isSearching = false;
    }
  }

  async clearHistory() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.clearSearchHistory();
      this.searchHistory = [];
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row({ space: 12 }) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        TextInput({ text: this.keyword, placeholder: '搜索神兽、属性、文化...' })
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .placeholderColor(DarkTheme.textTertiary)
          .placeholderFont({ size: 14 })
          .backgroundColor(DarkTheme.backgroundSecondary)
          .height(40)
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.keyword = value;
            this.performSearch(value);
          })
          .onSubmit(() => {
            this.performSearch(this.keyword);
          })

        if (this.keyword.length > 0) {
          Text('取消')
            .fontSize(14)
            .fontColor(DarkTheme.accent)
            .onClick(() => {
              this.keyword = '';
              this.searchResults = [];
              this.deityResults = [];
              this.hasSearched = false;
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.isSearching) {
        this.LoadingView()
      } else if (this.hasSearched) {
        // 搜索结果
        this.SearchResults()
      } else {
        // 搜索建议
        this.SearchSuggestions()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }

  @Builder
  SearchSuggestions() {
    Scroll() {
      Column({ space: 24 }) {
        // 热门搜索
        Column({ space: 12 }) {
          Text('热门搜索')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotKeywords, (keyword: string) => {
              Text(keyword)
                .fontSize(13)
                .fontColor(DarkTheme.textSecondary)
                .backgroundColor(DarkTheme.backgroundCard)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.keyword = keyword;
                  this.performSearch(keyword);
                })
            })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })

        // 搜索历史
        if (this.searchHistory.length > 0) {
          Column({ space: 12 }) {
            Row() {
              Text('搜索历史')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(DarkTheme.textPrimary)

              Blank()

              Text('清空')
                .fontSize(14)
                .fontColor(DarkTheme.textSecondary)
                .onClick(() => {
                  this.clearHistory();
                })
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.searchHistory, (keyword: string) => {
                Text(keyword)
                  .fontSize(13)
                  .fontColor(DarkTheme.textSecondary)
                  .backgroundColor(DarkTheme.backgroundCard)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.keyword = keyword;
                    this.performSearch(keyword);
                  })
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16 })
        }
      }
      .padding({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  SearchResults() {
    if (this.searchResults.length === 0 && this.deityResults.length === 0) {
      this.EmptyView()
    } else {
      Scroll() {
        Column({ space: 16 }) {
          // 神祇搜索结果
          if (this.deityResults.length > 0) {
            Column({ space: 12 }) {
              Text(`神祇 (${this.deityResults.length})`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(DarkTheme.textPrimary)
                .padding({ left: 16 })
                .width('100%')

              ForEach(this.deityResults, (deity: Deity) => {
                this.DeityResultItem(deity)
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 神兽搜索结果
          if (this.searchResults.length > 0) {
            Column({ space: 12 }) {
              Text(`神兽 (${this.searchResults.length})`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(DarkTheme.textPrimary)
                .padding({ left: 16 })
                .width('100%')

              ForEach(this.searchResults, (creature: MythicalCreature) => {
                CreatureCard({
                  creature: creature,
                  mode: 'list',
                  onItemClick: (c: MythicalCreature) => {
                    router.pushUrl({
                      url: 'pages/CreatureDetail',
                      params: { creatureId: c.id }
                    });
                  }
                })
                  .padding({ left: 16, right: 16 })
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          // 底部占位
          Column()
            .height(20)
        }
        .padding({ top: 12 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  DeityResultItem(deity: Deity) {
    Row({ space: 12 }) {
      Image($r(`app.media.${deity.image}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(deity.name.cn)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(DarkTheme.textPrimary)

          Text(getCultureName(deity.culture as CultureType).cn)
            .fontSize(10)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(getCultureColor(deity.culture as CultureType))
            .borderRadius(6)
        }

        Text(deity.name.en)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)

        Text(deity.domain.slice(0, 3).join(' / '))
          .fontSize(11)
          .fontColor(DarkTheme.textTertiary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.ic_back'))
        .width(16)
        .height(16)
        .rotate({ angle: 180 })
    }
    .width('100%')
    .padding(12)
    .margin({ left: 16, right: 16 })
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

      Text('搜索中...')
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

      Text('未找到相关结果')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Text('换个关键词试试')
        .fontSize(14)
        .fontColor(DarkTheme.textTertiary)
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
