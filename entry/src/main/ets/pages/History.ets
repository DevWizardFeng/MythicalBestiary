/**
 * 神话志 - 浏览历史页面
 * 用户浏览过的神兽和神祇记录
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { CultureType, getCultureName, getCultureColor } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { BrowsingRecord, normalizeHistoryItem } from '../model/UserData';
import { CreatureCard } from '../components/CreatureCard';

@Entry
@Component
struct History {
  @State historyRecords: BrowsingRecord[] = [];
  @State creatures: Map<string, MythicalCreature> = new Map();
  @State deities: Map<string, Deity> = new Map();
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.initialize();
      const rawRecords = await storage.getBrowsingHistory();
      // 规范化历史记录（兼容旧数据格式）
      this.historyRecords = rawRecords.map(r => normalizeHistoryItem(r));

      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      // 加载神兽数据
      const allCreatures = dataLoader.getAllCreatures();
      allCreatures.forEach(c => {
        this.creatures.set(c.id, c);
      });

      // 加载神祇数据
      const allDeities = dataLoader.getAllDeities();
      allDeities.forEach(d => {
        this.deities.set(d.id, d);
      });

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load history:', error);
      this.isLoading = false;
    }
  }

  async clearHistory() {
    try {
      const storage = StorageUtil.getInstance();
      await storage.clearBrowsingHistory();
      this.historyRecords = [];
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - timestamp;

    if (diff < 60000) {
      return '刚刚';
    } else if (diff < 3600000) {
      return `${Math.floor(diff / 60000)}分钟前`;
    } else if (diff < 86400000) {
      return `${Math.floor(diff / 3600000)}小时前`;
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日`;
    }
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

        Text('浏览历史')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.textPrimary)
          .margin({ left: 16 })

        Blank()

        if (this.historyRecords.length > 0) {
          Text('清空')
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
            .onClick(() => {
              this.clearHistory();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      if (this.isLoading) {
        this.LoadingView()
      } else if (this.historyRecords.length === 0) {
        this.EmptyView()
      } else {
        List() {
          ForEach(this.historyRecords, (record: BrowsingRecord) => {
            ListItem() {
              Row() {
                // 根据类型渲染不同卡片
                if (record.type === 'deity' && this.deities.has(record.id)) {
                  this.DeityListCard(this.deities.get(record.id) as Deity)
                } else if (record.type === 'creature' && this.creatures.has(record.id)) {
                  CreatureCard({
                    creature: this.creatures.get(record.id) as MythicalCreature,
                    mode: 'list',
                    onItemClick: (c: MythicalCreature) => {
                      router.pushUrl({
                        url: 'pages/CreatureDetail',
                        params: { creatureId: c.id }
                      });
                    }
                  })
                }
              }
            }
            .padding({ left: 16, right: 16, bottom: 12 })
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
  DeityListCard(deity: Deity) {
    Row() {
      // 神祇图片
      Image($r(`app.media.${deity.image}`))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 神祇信息
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(deity.name.cn)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Text('神祇')
            .fontSize(10)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(DarkTheme.accentSecondary)
            .borderRadius(8)
        }

        Text(deity.name.en)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)

        Row({ space: 4 }) {
          Text(getCultureName(deity.culture as CultureType).cn)
            .fontSize(10)
            .fontColor('#ffffff')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(getCultureColor(deity.culture as CultureType))
            .borderRadius(8)

          ForEach(deity.domain.slice(0, 2), (domain: string, index: number) => {
            Text(domain)
              .fontSize(10)
              .fontColor(DarkTheme.accent)
              .backgroundColor(DarkTheme.accent + '22')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }, (domain: string, index: number) => `${deity.id}_hist_${index}`)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
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
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  EmptyView() {
    Column() {
      Image($r('app.media.ic_browse'))
        .width(64)
        .height(64)

      Text('暂无浏览记录')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .margin({ top: 16 })

      Text('去探索神话世界吧')
        .fontSize(14)
        .fontColor(DarkTheme.textTertiary)
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
