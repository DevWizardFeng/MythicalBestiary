/**
 * 神话志 - 属性测试页面
 * 通过问答发现用户的神兽属性
 */

import router from '@ohos.router';
import { DarkTheme } from '../common/Theme';
import { AttributeType, AttributeNames, AttributeColors } from '../common/Constants';
import { MythicalCreature } from '../model/MythicalCreature';
import { DataLoader } from '../utils/DataLoader';

interface Question {
  question: string;
  options: QuestionOption[];
}

interface QuestionOption {
  text: string;
  attribute: AttributeType;
}

@Entry
@Component
struct AttributeTest {
  @State currentQuestion: number = 0;
  @State scores: Map<string, number> = new Map();
  @State isComplete: boolean = false;
  @State resultAttribute: AttributeType | null = null;
  @State resultCreatures: MythicalCreature[] = [];

  private questions: Question[] = [
    {
      question: '面对困难时，你通常会？',
      options: [
        { text: '直面挑战，勇往直前', attribute: 'fire' },
        { text: '冷静分析，寻找解决方案', attribute: 'water' },
        { text: '灵活应变，寻找捷径', attribute: 'wind' },
        { text: '雷厉风行，快速决断', attribute: 'thunder' }
      ]
    },
    {
      question: '你更喜欢什么样的环境？',
      options: [
        { text: '充满活力的热闹场所', attribute: 'fire' },
        { text: '宁静的水边或山林', attribute: 'nature' },
        { text: '明亮开阔的空间', attribute: 'light' },
        { text: '神秘幽静的地方', attribute: 'dark' }
      ]
    },
    {
      question: '你认为最重要的品质是？',
      options: [
        { text: '勇气和热情', attribute: 'fire' },
        { text: '智慧和冷静', attribute: 'water' },
        { text: '自由和灵活', attribute: 'wind' },
        { text: '正义和光明', attribute: 'light' }
      ]
    },
    {
      question: '你最喜欢的天气是？',
      options: [
        { text: '阳光明媚的晴天', attribute: 'light' },
        { text: '电闪雷鸣的暴风雨', attribute: 'thunder' },
        { text: '清爽舒适的微风天', attribute: 'wind' },
        { text: '细雨绵绵的阴天', attribute: 'water' }
      ]
    },
    {
      question: '你的朋友会怎么形容你？',
      options: [
        { text: '热情洋溢，感染力强', attribute: 'fire' },
        { text: '沉稳可靠，值得信赖', attribute: 'nature' },
        { text: '神秘莫测，难以捉摸', attribute: 'dark' },
        { text: '果断干练，雷厉风行', attribute: 'thunder' }
      ]
    }
  ];

  aboutToAppear() {
    // 初始化分数
    const attributes: AttributeType[] = ['fire', 'water', 'wind', 'thunder', 'light', 'dark', 'nature'];
    attributes.forEach(attr => {
      this.scores.set(attr, 0);
    });
  }

  selectOption(option: QuestionOption) {
    // 更新分数
    const currentScore = this.scores.get(option.attribute) || 0;
    this.scores.set(option.attribute, currentScore + 1);

    if (this.currentQuestion < this.questions.length - 1) {
      this.currentQuestion++;
    } else {
      this.calculateResult();
    }
  }

  async calculateResult() {
    // 找出得分最高的属性
    let maxScore = 0;
    let maxAttribute: AttributeType = 'fire';

    this.scores.forEach((score, attr) => {
      if (score > maxScore) {
        maxScore = score;
        maxAttribute = attr as AttributeType;
      }
    });

    this.resultAttribute = maxAttribute;

    // 加载该属性的神兽
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.initialize();
      const allCreatures = dataLoader.getAllCreatures();
      this.resultCreatures = allCreatures
        .filter(c => c.attributes.primary === maxAttribute)
        .slice(0, 3);
    } catch (error) {
      console.error('Failed to load creatures:', error);
    }

    this.isComplete = true;
  }

  restart() {
    this.currentQuestion = 0;
    this.isComplete = false;
    this.resultAttribute = null;
    this.resultCreatures = [];

    const attributes: AttributeType[] = ['fire', 'water', 'wind', 'thunder', 'light', 'dark', 'nature'];
    attributes.forEach(attr => {
      this.scores.set(attr, 0);
    });
  }

  build() {
    Stack() {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(DarkTheme.background)

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

          Text('属性测试')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)

          Blank()

          Column()
            .width(24)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        if (!this.isComplete) {
          this.QuestionView()
        } else {
          this.ResultView()
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  QuestionView() {
    Column() {
      // 进度条
      Column({ space: 8 }) {
        Row() {
          Text(`问题 ${this.currentQuestion + 1}/${this.questions.length}`)
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)

          Blank()

          Text(`${Math.round((this.currentQuestion + 1) / this.questions.length * 100)}%`)
            .fontSize(14)
            .fontColor(DarkTheme.accent)
        }
        .width('100%')

        Row() {
          Column()
            .width(`${(this.currentQuestion + 1) / this.questions.length * 100}%`)
            .height(4)
            .backgroundColor(DarkTheme.accent)
            .borderRadius(2)
        }
        .width('100%')
        .height(4)
        .backgroundColor(DarkTheme.backgroundSecondary)
        .borderRadius(2)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      Blank()
        .layoutWeight(1)

      // 问题
      Text(this.questions[this.currentQuestion].question)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .textAlign(TextAlign.Center)
        .padding({ left: 24, right: 24 })

      Blank()
        .height(40)

      // 选项
      Column({ space: 12 }) {
        ForEach(this.questions[this.currentQuestion].options, (option: QuestionOption, index: number) => {
          Row() {
            Text(option.text)
              .fontSize(16)
              .fontColor(DarkTheme.textPrimary)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(DarkTheme.backgroundCard)
          .borderRadius(12)
          .border({
            width: 1,
            color: DarkTheme.divider
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
        Column({ space: 8 }) {
          Text('测试完成!')
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)

          Text('你的神兽属性是')
            .fontSize(20)
            .fontColor(DarkTheme.textPrimary)
        }
        .margin({ top: 32 })

        // 属性展示
        Column({ space: 16 }) {
          Image($r(`app.media.ic_attr_${this.resultAttribute}`))
            .width(100)
            .height(100)
            .objectFit(ImageFit.Contain)
            .clip(true)
            .borderRadius(50)

          Text(AttributeNames[this.resultAttribute as AttributeType].cn)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(AttributeColors[this.resultAttribute as AttributeType].primary)

          Text(AttributeNames[this.resultAttribute as AttributeType].en)
            .fontSize(16)
            .fontColor(DarkTheme.textSecondary)
        }

        // 属性描述
        Column({ space: 8 }) {
          Text(this.getAttributeDescription())
            .fontSize(14)
            .fontColor(DarkTheme.textSecondary)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
            .padding({ left: 24, right: 24 })
        }

        // 推荐神兽
        if (this.resultCreatures.length > 0) {
          Column({ space: 12 }) {
            Text('你的守护神兽')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)

            Row({ space: 12 }) {
              ForEach(this.resultCreatures, (creature: MythicalCreature) => {
                Column() {
                  Image($r(`app.media.${creature.image}`))
                    .width(80)
                    .height(80)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)

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
          }
          .margin({ top: 16 })
        }

        // 重新测试按钮
        Button('重新测试')
          .fontSize(16)
          .fontColor(DarkTheme.textPrimary)
          .backgroundColor(DarkTheme.backgroundCard)
          .width('calc(100% - 32vp)')
          .height(48)
          .borderRadius(24)
          .margin({ left: 16, right: 16, top: 24 })
          .onClick(() => {
            this.restart();
          })

        Column()
          .height(32)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  getAttributeDescription(): string {
    const descriptions: Record<string, string> = {
      'fire': '你拥有火属性的特质：热情、勇敢、充满活力。你面对挑战时总是勇往直前，用热情感染周围的人。',
      'water': '你拥有水属性的特质：冷静、智慧、适应力强。你善于分析问题，能够在复杂情况中保持清醒的头脑。',
      'wind': '你拥有风属性的特质：自由、灵活、无拘无束。你追求自由，思维敏捷，善于发现新的可能性。',
      'thunder': '你拥有雷属性的特质：果断、迅速、充满力量。你做事雷厉风行，具有强大的执行力和决断力。',
      'light': '你拥有光属性的特质：正义、温暖、充满希望。你追求光明和正义，总是给予他人温暖和希望。',
      'dark': '你拥有暗属性的特质：神秘、深邃、洞察力强。你善于观察和思考，能够看透事物的本质。',
      'nature': '你拥有自然属性的特质：和谐、稳重、生命力旺盛。你与自然和谐共处，具有强大的生命力和包容心。'
    };
    return descriptions[this.resultAttribute as string] || '';
  }
}
