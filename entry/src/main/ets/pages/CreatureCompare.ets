/**
 * 神话志 - 神兽对比页面
 * 支持两个神兽的多维度对比分析
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { AttributeType, RarityType, CultureType, AlignmentType,
  getAttributeColor, getRarityColor, getRarityName, getCultureName,
  getAlignmentName, getCreatureTypeName, AttributeNames } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';
import { StorageUtil } from '../utils/Storage';
import { AttributeTag } from '../components/AttributeTag';
import { RarityBadge } from '../components/RarityBadge';

interface RouterParams {
  creatureId1?: string;
  creatureId2?: string;
}

@Entry
@Component
struct CreatureCompare {
  @State creature1: MythicalCreature | null = null;
  @State creature2: MythicalCreature | null = null;
  @State isLoading: boolean = true;
  @State similarity: number = 0; // 相似度百分比

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const params = router.getParams() as RouterParams;
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();

      if (params?.creatureId1) {
        this.creature1 = dataLoader.getCreatureById(params.creatureId1) || null;
      }
      if (params?.creatureId2) {
        this.creature2 = dataLoader.getCreatureById(params.creatureId2) || null;
      }

      // 计算相似度
      if (this.creature1 && this.creature2) {
        this.similarity = this.calculateSimilarity(this.creature1, this.creature2);
      }

      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load creatures for comparison:', error);
      this.isLoading = false;
    }
  }

  /**
   * 计算两个神兽的相似度 (0-100)
   */
  calculateSimilarity(c1: MythicalCreature, c2: MythicalCreature): number {
    let score = 0;
    let totalWeight = 0;

    // 文化相同 (权重30)
    totalWeight += 30;
    if (c1.culture === c2.culture) {
      score += 30;
    }

    // 主属性相同 (权重25)
    totalWeight += 25;
    if (c1.attributes.primary === c2.attributes.primary) {
      score += 25;
    }

    // 类型相同 (权重20)
    totalWeight += 20;
    if (c1.type === c2.type) {
      score += 20;
    }

    // 阵营相同 (权重15)
    totalWeight += 15;
    if (c1.alignment === c2.alignment) {
      score += 15;
    }

    // 稀有度相同 (权重10)
    totalWeight += 10;
    if (c1.rarity === c2.rarity) {
      score += 10;
    }

    return Math.round((score / totalWeight) * 100);
  }

  /**
   * 返回上一页
   */
  goBack() {
    router.back();
  }

  /**
   * 选择神兽进行对比
   */
  selectCreature(position: 1 | 2) {
    router.pushUrl({
      url: 'pages/CreatureList',
      params: {
        selectMode: true,
        position: position
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景图片
      Image($r('app.media.bg_compare'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .fillColor(DarkTheme.textPrimary)
            .onClick(() => this.goBack())

          Text('神兽对比')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .margin({ left: 12 })

          Blank()
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })

        if (this.isLoading) {
          // 加载中
          Column() {
            LoadingProgress()
              .color(DarkTheme.accent)
              .width(50)
              .height(50)
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (!this.creature1 || !this.creature2) {
          // 未选择神兽
          this.EmptyView()
        } else {
          // 对比视图
          Scroll() {
            Column({ space: 16 }) {
              // 相似度指示器
              this.SimilarityIndicator()

              // 基本信息对比
              this.BasicInfoCompare()

              // 属性对比
              this.AttributesCompare()

              // 能力对比
              this.AbilitiesCompare()

              // 神话故事长度对比
              this.MythologyCompare()
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 24 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 空状态视图
   */
  @Builder
  EmptyView() {
    Column({ space: 24 }) {
      Image($r('app.media.ic_compare'))
        .width(120)
        .height(120)
        .fillColor(DarkTheme.textTertiary)

      Text('请选择两个神兽进行对比')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)

      Row({ space: 12 }) {
        Button(this.creature1 ? '已选择' : '选择神兽1')
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .backgroundColor(this.creature1 ? DarkTheme.accent : 'rgba(255,215,0,0.2)')
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => this.selectCreature(1))

        Button(this.creature2 ? '已选择' : '选择神兽2')
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .backgroundColor(this.creature2 ? DarkTheme.accent : 'rgba(255,215,0,0.2)')
          .borderRadius(20)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .onClick(() => this.selectCreature(2))
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 相似度指示器
   */
  @Builder
  SimilarityIndicator() {
    Column({ space: 8 }) {
      Text('相似度分析')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      Row() {
        Text(`${this.similarity}%`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)
      }

      Stack() {
        // 背景条
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(4)

        // 进度条
        Row()
          .width(`${this.similarity}%`)
          .height(8)
          .backgroundColor(
            this.similarity >= 70 ? '#4caf50' :
            this.similarity >= 40 ? '#ff9800' : '#f44336'
          )
          .borderRadius(4)
      }
      .width('100%')

      Text(
        this.similarity >= 70 ? '非常相似' :
        this.similarity >= 40 ? '部分相似' : '差异较大'
      )
        .fontSize(12)
        .fontColor(DarkTheme.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
  }

  /**
   * 基本信息对比
   */
  @Builder
  BasicInfoCompare() {
    Column({ space: 12 }) {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      // 名称对比
      this.CompareRow(
        '名称',
        this.creature1?.name.cn || '',
        this.creature2?.name.cn || '',
        this.creature1?.name.cn === this.creature2?.name.cn
      )

      // 文化对比
      this.CompareRow(
        '文化',
        getCultureName(this.creature1?.culture as CultureType).cn,
        getCultureName(this.creature2?.culture as CultureType).cn,
        this.creature1?.culture === this.creature2?.culture
      )

      // 类型对比
      this.CompareRow(
        '类型',
        getCreatureTypeName(this.creature1?.type).cn,
        getCreatureTypeName(this.creature2?.type).cn,
        this.creature1?.type === this.creature2?.type
      )

      // 阵营对比
      this.CompareRow(
        '阵营',
        getAlignmentName(this.creature1?.alignment).cn,
        getAlignmentName(this.creature2?.alignment).cn,
        this.creature1?.alignment === this.creature2?.alignment
      )

      // 稀有度对比
      this.CompareRow(
        '稀有度',
        getRarityName(this.creature1?.rarity as RarityType).cn,
        getRarityName(this.creature2?.rarity as RarityType).cn,
        this.creature1?.rarity === this.creature2?.rarity
      )
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
  }

  /**
   * 属性对比
   */
  @Builder
  AttributesCompare() {
    Column({ space: 12 }) {
      Text('属性对比')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Row() {
        Column({ space: 8 }) {
          Text('神兽1')
            .fontSize(12)
            .fontColor(DarkTheme.textSecondary)

          if (this.creature1) {
            AttributeTag({ attribute: this.creature1.attributes.primary })
          }

          if (this.creature1?.attributes.secondary) {
            AttributeTag({ attribute: this.creature1.attributes.secondary })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Image($r('app.media.ic_compare'))
            .width(32)
            .height(32)
            .fillColor(DarkTheme.textTertiary)
        }
        .width(60)
        .justifyContent(FlexAlign.Center)

        Column({ space: 8 }) {
          Text('神兽2')
            .fontSize(12)
            .fontColor(DarkTheme.textSecondary)

          if (this.creature2) {
            AttributeTag({ attribute: this.creature2.attributes.primary })
          }

          if (this.creature2?.attributes.secondary) {
            AttributeTag({ attribute: this.creature2.attributes.secondary })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
  }

  /**
   * 能力对比
   */
  @Builder
  AbilitiesCompare() {
    Column({ space: 12 }) {
      Text('能力数量对比')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      this.CompareRow(
        '能力数',
        `${this.creature1?.abilities.length || 0} 项`,
        `${this.creature2?.abilities.length || 0} 项`,
        this.creature1?.abilities.length === this.creature2?.abilities.length
      )
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
  }

  /**
   * 神话故事对比
   */
  @Builder
  MythologyCompare() {
    Column({ space: 12 }) {
      Text('神话传说对比')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      this.CompareRow(
        '传说长度',
        `${this.creature1?.mythology.length || 0} 字`,
        `${this.creature2?.mythology.length || 0} 字`,
        false
      )
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(30,30,60,0.7)')
    .borderRadius(12)
  }

  /**
   * 对比行组件
   */
  @Builder
  CompareRow(label: string, value1: string, value2: string, isSame: boolean) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
        .width(60)

      Text(value1)
        .fontSize(14)
        .fontColor(isSame ? DarkTheme.accent : DarkTheme.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (isSame) {
        Image($r('app.media.ic_check'))
          .width(16)
          .height(16)
          .fillColor('#4caf50')
      } else {
        Image($r('app.media.ic_close'))
          .width(16)
          .height(16)
          .fillColor('#f44336')
      }

      Text(value2)
        .fontSize(14)
        .fontColor(isSame ? DarkTheme.accent : DarkTheme.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
  }
}
