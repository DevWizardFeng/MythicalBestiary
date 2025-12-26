/**
 * 神话志 - 守护神祇测试页面
 * 基于神职领域匹配的问答测试
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { Deity } from '../model/Deity';
import { DataLoader } from '../utils/DataLoader';
import { getCultureName, getCultureColor, CultureType } from '../common/Constants';

interface DeityQuestion {
  id: number;
  question: string;
  options: DeityOption[];
}

interface DeityOption {
  text: string;
  domains: string[];
}

@Entry
@Component
struct DeityTest {
  @State currentQuestionIndex: number = 0;
  @State isLoading: boolean = true;
  @State isComplete: boolean = false;
  @State selectedDeity: Deity | null = null;
  @State domainScores: Map<string, number> = new Map();
  @State allDeities: Deity[] = [];
  @State matchDescription: string = '';

  private questions: DeityQuestion[] = [
    {
      id: 1,
      question: '当遇到困难时，你更倾向于？',
      options: [
        { text: '冷静分析，寻找解决方案', domains: ['智慧', '知识', '策略'] },
        { text: '勇敢面对，直接迎战', domains: ['战争', '力量', '勇气'] },
        { text: '寻求帮助，团结他人', domains: ['爱情', '家庭', '和谐'] },
        { text: '顺其自然，等待时机', domains: ['命运', '时间', '自然'] }
      ]
    },
    {
      id: 2,
      question: '你最向往的生活状态是？',
      options: [
        { text: '探索未知，追求真理', domains: ['智慧', '知识', '月亮'] },
        { text: '荣耀辉煌，成就非凡', domains: ['太阳', '光明', '王权'] },
        { text: '平静安宁，与世无争', domains: ['海洋', '自然', '和平'] },
        { text: '神秘莫测，掌控一切', domains: ['冥界', '魔法', '命运'] }
      ]
    },
    {
      id: 3,
      question: '如果拥有神力，你最想做的是？',
      options: [
        { text: '保护弱者，维护正义', domains: ['正义', '战争', '守护'] },
        { text: '创造美好，孕育生命', domains: ['丰收', '生育', '爱情'] },
        { text: '掌控自然，呼风唤雨', domains: ['雷电', '风暴', '海洋'] },
        { text: '洞察人心，预知未来', domains: ['预言', '智慧', '月亮'] }
      ]
    },
    {
      id: 4,
      question: '你认为最重要的品质是？',
      options: [
        { text: '智慧与洞察力', domains: ['智慧', '知识', '艺术'] },
        { text: '勇气与力量', domains: ['战争', '力量', '雷电'] },
        { text: '爱与包容', domains: ['爱情', '美丽', '家庭'] },
        { text: '公正与秩序', domains: ['正义', '法律', '冥界'] }
      ]
    },
    {
      id: 5,
      question: '你更喜欢哪种自然元素？',
      options: [
        { text: '光芒万丈的太阳', domains: ['太阳', '光明', '火焰'] },
        { text: '波涛汹涌的大海', domains: ['海洋', '风暴', '航海'] },
        { text: '皎洁宁静的月光', domains: ['月亮', '狩猎', '自然'] },
        { text: '大地深处的神秘', domains: ['冥界', '大地', '丰收'] }
      ]
    }
  ];

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      this.allDeities = dataLoader.getAllDeities();
      this.isLoading = false;
    } catch (error) {
      console.error('Failed to load deities:', error);
      this.isLoading = false;
    }
  }

  selectOption(option: DeityOption) {
    // 累加该选项对应的神职领域得分
    for (const domain of option.domains) {
      const currentScore = this.domainScores.get(domain) || 0;
      this.domainScores.set(domain, currentScore + 1);
    }

    // 进入下一题或完成测试
    if (this.currentQuestionIndex < this.questions.length - 1) {
      this.currentQuestionIndex++;
    } else {
      this.calculateResult();
    }
  }

  calculateResult() {
    // 找到得分最高的神职领域
    let topDomains: string[] = [];
    let maxScore = 0;

    this.domainScores.forEach((score, domain) => {
      if (score > maxScore) {
        maxScore = score;
        topDomains = [domain];
      } else if (score === maxScore) {
        topDomains.push(domain);
      }
    });

    // 根据高分领域匹配神祇
    let bestMatch: Deity | null = null;
    let bestMatchCount = 0;

    for (const deity of this.allDeities) {
      let matchCount = 0;
      for (const domain of deity.domain) {
        if (topDomains.includes(domain)) {
          matchCount++;
        }
      }
      if (matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestMatch = deity;
      }
    }

    // 如果没有匹配的，随机选一个
    if (!bestMatch && this.allDeities.length > 0) {
      const randomIndex = Math.floor(Math.random() * this.allDeities.length);
      bestMatch = this.allDeities[randomIndex];
    }

    this.selectedDeity = bestMatch;
    this.matchDescription = this.generateMatchDescription(topDomains);
    this.isComplete = true;
  }

  generateMatchDescription(domains: string[]): string {
    const descriptions: Map<string, string> = new Map([
      ['智慧', '你拥有敏锐的洞察力和深邃的思考能力'],
      ['战争', '你具备勇往直前的勇气和不屈的意志'],
      ['爱情', '你内心充满爱与温暖，善于维系情感'],
      ['太阳', '你如阳光般温暖，给人带来希望和力量'],
      ['海洋', '你像大海一样包容，内心深邃而宁静'],
      ['月亮', '你神秘而优雅，拥有独特的魅力'],
      ['冥界', '你能洞察生死，理解生命的意义'],
      ['雷电', '你充满能量，决断果敢'],
      ['自然', '你与自然和谐共处，追求平衡'],
      ['丰收', '你勤劳善良，懂得付出与收获'],
      ['正义', '你追求公平正义，是非分明'],
      ['知识', '你渴望学习，追求真理']
    ]);

    let desc = '';
    for (const domain of domains.slice(0, 2)) {
      const domainDesc = descriptions.get(domain);
      if (domainDesc) {
        desc += domainDesc + '。';
      }
    }
    return desc || '你拥有独特的神性特质，与这位神祇心灵相通。';
  }

  resetTest() {
    this.currentQuestionIndex = 0;
    this.isComplete = false;
    this.selectedDeity = null;
    this.domainScores = new Map();
    this.matchDescription = '';
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.LeftTop,
          colors: [['#1a1a2e', 0], ['#16213e', 0.5], ['#0f3460', 1]]
        })

      Column() {
        // 顶部导航
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .width(24)
            .height(24)
            .onClick(() => {
              router.back();
            })

          Blank()

          Text('守护神祇测试')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ffffff')

          Blank()

          Column()
            .width(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 48, bottom: 16 })

        if (this.isLoading) {
          this.LoadingView()
        } else if (this.isComplete) {
          this.ResultView()
        } else {
          this.QuestionView()
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#ffd700')
      Text('加载中...')
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.6)')
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  QuestionView() {
    Column() {
      // 进度指示
      Row({ space: 8 }) {
        ForEach([0, 1, 2, 3, 4], (index: number) => {
          Column()
            .width(index <= this.currentQuestionIndex ? 40 : 24)
            .height(4)
            .backgroundColor(index <= this.currentQuestionIndex ? '#ffd700' : 'rgba(255,255,255,0.2)')
            .borderRadius(2)
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 16, bottom: 24 })

      // 问题序号
      Text(`问题 ${this.currentQuestionIndex + 1}/${this.questions.length}`)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.5)')

      // 问题内容
      Text(this.questions[this.currentQuestionIndex].question)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 32 })
        .padding({ left: 16, right: 16 })

      // 选项
      Column({ space: 12 }) {
        ForEach(this.questions[this.currentQuestionIndex].options, (option: DeityOption, index: number) => {
          Row() {
            Text(option.text)
              .fontSize(16)
              .fontColor('#ffffff')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(255,255,255,0.1)')
          .borderRadius(12)
          .border({
            width: 1,
            color: 'rgba(255,215,0,0.3)'
          })
          .onClick(() => {
            this.selectOption(option);
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  ResultView() {
    Scroll() {
      Column({ space: 24 }) {
        // 结果标题
        Text('你的守护神祇')
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ top: 16 })

        // 神祇图片
        if (this.selectedDeity) {
          Stack({ alignContent: Alignment.Bottom }) {
            Image($r(`app.media.${this.selectedDeity.image}`))
              .width('100%')
              .height(280)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)

            // 渐变遮罩
            Column()
              .width('100%')
              .height('60%')
              .linearGradient({
                direction: GradientDirection.Top,
                colors: [['rgba(0,0,0,0.8)', 0], ['rgba(0,0,0,0)', 1]]
              })
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })

            // 名称
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(this.selectedDeity.name.cn)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffffff')

                Text(getCultureName(this.selectedDeity.culture as CultureType).cn)
                  .fontSize(12)
                  .fontColor('#ffffff')
                  .backgroundColor(getCultureColor(this.selectedDeity.culture as CultureType))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(8)
              }

              Text(this.selectedDeity.name.en)
                .fontSize(14)
                .fontColor('rgba(255,255,255,0.7)')
            }
            .padding(16)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(280)
          .margin({ left: 16, right: 16 })

          // 匹配描述
          Column({ space: 8 }) {
            Text('命运解读')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.5)')

            Text(this.matchDescription)
              .fontSize(16)
              .fontColor('#ffd700')
              .lineHeight(24)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(255,215,0,0.1)')
          .borderRadius(12)
          .margin({ left: 16, right: 16 })

          // 神职领域
          Column({ space: 12 }) {
            Text('神职领域')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.6)')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.selectedDeity.domain.slice(0, 4), (domain: string, index: number) => {
                Text(domain)
                  .fontSize(14)
                  .fontColor('#ffffff')
                  .backgroundColor(DarkTheme.accent + '44')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
              }, (domain: string, index: number) => `result_domain_${index}`)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(12)
          .margin({ left: 16, right: 16 })
          .alignItems(HorizontalAlign.Start)

          // 操作按钮
          Row({ space: 16 }) {
            Button('重新测试')
              .fontSize(14)
              .fontColor('#ffd700')
              .backgroundColor('transparent')
              .border({
                width: 1,
                color: '#ffd700'
              })
              .width('45%')
              .height(44)
              .borderRadius(22)
              .onClick(() => {
                this.resetTest();
              })

            Button('查看详情')
              .fontSize(14)
              .fontColor('#1a1a2e')
              .backgroundColor('#ffd700')
              .width('45%')
              .height(44)
              .borderRadius(22)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DeityDetail',
                  params: { deityId: this.selectedDeity?.id }
                });
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .margin({ top: 8 })
        }

        Column()
          .height(32)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
