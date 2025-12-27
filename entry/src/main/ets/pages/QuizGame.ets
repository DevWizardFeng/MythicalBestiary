/**
 * 神话志 - 答题游戏页面
 * 核心答题交互：倒计时、题目、选项、连击、积分
 */

import router from '@ohos.router';
import { DarkTheme, CardStyle } from '../common/Theme';
import { RouterPaths } from '../common/Constants';
import {
  QuizQuestion,
  QuizMode,
  QuizConfig,
  QuizResult,
  QuestionCategory,
  calculateScore,
  generateSessionId,
  getQuizModeConfig,
  getCategoryName,
  getDifficultyName
} from '../model/Quiz';
import { DataLoader } from '../utils/DataLoader';

interface RouterParams {
  mode: QuizMode;
  category?: QuestionCategory;
  showCategorySelect?: boolean;
}

@Entry
@Component
struct QuizGame {
  @State mode: QuizMode = 'classic';
  @State category: QuestionCategory | undefined = undefined;
  @State showCategorySelect: boolean = false;

  // 游戏状态
  @State isLoading: boolean = true;
  @State isPlaying: boolean = false;
  @State isPaused: boolean = false;
  @State isAnswered: boolean = false;
  @State isCorrect: boolean = false;
  @State selectedIndex: number = -1;

  // 题目数据
  @State questions: QuizQuestion[] = [];
  @State currentIndex: number = 0;
  @State currentQuestion: QuizQuestion | null = null;

  // 计时器
  @State timeRemaining: number = 15;
  @State maxTime: number = 15;
  private timerInterval: number = -1;

  // 积分和连击
  @State totalScore: number = 0;
  @State currentCombo: number = 0;
  @State maxCombo: number = 0;
  @State correctCount: number = 0;
  @State wrongCount: number = 0;
  @State lastScoreGain: number = 0;
  @State showScorePopup: boolean = false;

  // 无尽模式
  @State lives: number = 3;

  // 答题时间记录
  private answerTimes: number[] = [];
  private questionStartTime: number = 0;
  private sessionId: string = '';

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as RouterParams;
    if (params) {
      this.mode = params.mode || 'classic';
      this.category = params.category;
      this.showCategorySelect = params.showCategorySelect || false;
    }

    if (this.showCategorySelect) {
      this.isLoading = false;
    } else {
      this.initGame();
    }
  }

  aboutToDisappear() {
    this.clearTimer();
  }

  async initGame() {
    try {
      const dataLoader = DataLoader.getInstance();
      await dataLoader.loadQuizData();

      const config = getQuizModeConfig(this.mode);
      this.maxTime = config.baseTimePerQuestion;
      this.timeRemaining = this.maxTime;

      // 根据模式获取题目
      const questionCount = this.mode === 'endless' ? 50 : config.questionCount;
      this.questions = dataLoader.getMixedDifficultyQuestions(questionCount, this.category);

      if (this.questions.length === 0) {
        console.error('QuizGame: No questions loaded');
        router.back();
        return;
      }

      this.sessionId = generateSessionId();
      this.currentQuestion = this.questions[0];
      this.isLoading = false;
      this.isPlaying = true;
      this.questionStartTime = Date.now();
      this.startTimer();
    } catch (error) {
      console.error('QuizGame: Failed to init game', error);
      router.back();
    }
  }

  startTimer() {
    this.clearTimer();
    this.timerInterval = setInterval(() => {
      if (this.isPaused || this.isAnswered) {
        return;
      }

      this.timeRemaining -= 0.1;

      if (this.timeRemaining <= 0) {
        this.timeRemaining = 0;
        this.handleTimeout();
      }
    }, 100);
  }

  clearTimer() {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }

  handleTimeout() {
    // 超时视为答错
    this.isAnswered = true;
    this.isCorrect = false;
    this.currentCombo = 0;
    this.wrongCount++;

    if (this.mode === 'endless') {
      this.lives--;
      if (this.lives <= 0) {
        setTimeout((): void => this.endGame(), 1000);
        return;
      }
    }

    setTimeout((): void => this.nextQuestion(), 1500);
  }

  handleAnswer(index: number) {
    if (this.isAnswered || !this.currentQuestion) {
      return;
    }

    this.isAnswered = true;
    this.selectedIndex = index;

    // 记录答题时间
    const answerTime = Date.now() - this.questionStartTime;
    this.answerTimes.push(answerTime);

    // 判断是否正确
    this.isCorrect = index === this.currentQuestion.correctIndex;

    if (this.isCorrect) {
      // 计算得分
      this.currentCombo++;
      if (this.currentCombo > this.maxCombo) {
        this.maxCombo = this.currentCombo;
      }
      this.correctCount++;

      const score = calculateScore(
        true,
        this.currentCombo,
        this.timeRemaining,
        this.maxTime,
        this.currentQuestion.difficulty
      );
      this.lastScoreGain = score;
      this.totalScore += score;
      this.showScorePopup = true;

      setTimeout((): void => {
        this.showScorePopup = false;
      }, 800);
    } else {
      this.currentCombo = 0;
      this.wrongCount++;

      if (this.mode === 'endless') {
        this.lives--;
        if (this.lives <= 0) {
          setTimeout((): void => this.endGame(), 1500);
          return;
        }
      }
    }

    // 延迟进入下一题
    setTimeout((): void => this.nextQuestion(), 1500);
  }

  nextQuestion() {
    this.currentIndex++;

    // 检查是否结束
    if (this.mode !== 'endless' && this.currentIndex >= this.questions.length) {
      this.endGame();
      return;
    }

    if (this.currentIndex >= this.questions.length) {
      this.endGame();
      return;
    }

    // 下一题
    this.currentQuestion = this.questions[this.currentIndex];
    this.isAnswered = false;
    this.selectedIndex = -1;
    this.timeRemaining = this.maxTime;
    this.questionStartTime = Date.now();
    this.startTimer();
  }

  endGame() {
    this.clearTimer();
    this.isPlaying = false;

    // 计算平均答题时间
    const totalAnswerTime = this.answerTimes.reduce((a, b) => a + b, 0);
    const avgTime = this.answerTimes.length > 0 ? totalAnswerTime / this.answerTimes.length : 0;

    // 构建结果
    const result: QuizResult = {
      sessionId: this.sessionId,
      mode: this.mode,
      category: this.category,
      totalQuestions: this.correctCount + this.wrongCount,
      correctAnswers: this.correctCount,
      wrongAnswers: this.wrongCount,
      totalScore: this.totalScore,
      maxCombo: this.maxCombo,
      averageTime: avgTime,
      completedAt: Date.now(),
      isNewRecord: false // 在结果页计算
    };

    // 跳转到结果页
    router.replaceUrl({
      url: RouterPaths.QUIZ_RESULT,
      params: { result: JSON.stringify(result) }
    });
  }

  selectCategory(cat: QuestionCategory) {
    this.category = cat;
    this.showCategorySelect = false;
    this.isLoading = true;
    this.initGame();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图片
      Image($r('app.media.bg_challenge_detail'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      if (this.showCategorySelect) {
        this.CategorySelectView()
      } else if (this.isLoading) {
        this.LoadingView()
      } else {
        this.GameView()
      }

      // 分数弹窗
      if (this.showScorePopup) {
        Text(`+${this.lastScoreGain}`)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(DarkTheme.accent)
          .position({ x: '50%', y: '40%' })
          .translate({ x: '-50%', y: '-50%' })
          .animation({
            duration: 600,
            curve: Curve.EaseOut
          })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CategorySelectView() {
    Column({ space: 20 }) {
      // 标题
      Text('选择专题')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Text('选择你擅长的神话领域')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)

      // 分类选项
      Column({ space: 12 }) {
        ForEach(['creature', 'deity', 'culture', 'attribute', 'ability'] as QuestionCategory[], (cat: QuestionCategory) => {
          this.CategoryItem(cat)
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // 返回按钮
      Text('返回')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)
        .padding({ top: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  CategoryItem(cat: QuestionCategory) {
    Row() {
      Text(getCategoryName(cat).cn)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Blank()

      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 16 })
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(12)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .onClick(() => {
      this.selectCategory(cat);
    })
  }

  @Builder
  LoadingView() {
    Column({ space: 16 }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(DarkTheme.accent)

      Text('加载题目中...')
        .fontSize(14)
        .fontColor(DarkTheme.textSecondary)
    }
  }

  @Builder
  GameView() {
    Column() {
      // 顶部状态栏
      this.TopBar()

      // 进度和连击
      this.ProgressBar()

      // 题目
      if (this.currentQuestion) {
        this.QuestionCard()

        // 选项
        this.OptionsArea()
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 24 })
  }

  @Builder
  TopBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor(DarkTheme.textPrimary)
        .onClick(() => {
          this.clearTimer();
          router.back();
        })

      Blank()

      // 题目计数
      Text(`${this.currentIndex + 1}/${this.mode === 'endless' ? '∞' : this.questions.length}`)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)

      Blank()

      // 分数
      Text(`${this.totalScore}分`)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.accent)
    }
    .width('100%')
    .height(48)
  }

  @Builder
  ProgressBar() {
    Row({ space: 12 }) {
      // 计时器
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.timeRemaining,
          total: this.maxTime,
          type: ProgressType.Ring
        })
          .width(48)
          .height(48)
          .color(this.getTimerColor())
          .backgroundColor(DarkTheme.backgroundSecondary)
          .style({ strokeWidth: 4 })

        Text(`${Math.ceil(this.timeRemaining)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getTimerColor())
      }

      // 连击显示
      if (this.currentCombo > 0) {
        Row({ space: 4 }) {
          Image($r('app.media.ic_combo'))
            .width(20)
            .height(20)
            .fillColor('#FF6B35')

          Text(`${this.currentCombo}连击`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#FF6B3522')
        .borderRadius(16)
      }

      Blank()

      // 无尽模式生命值
      if (this.mode === 'endless') {
        Row({ space: 4 }) {
          ForEach([1, 2, 3], (i: number) => {
            Image($r('app.media.ic_heart'))
              .width(20)
              .height(20)
              .fillColor(i <= this.lives ? '#FF4757' : DarkTheme.backgroundSecondary)
          })
        }
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8 })
  }

  getTimerColor(): string {
    if (this.timeRemaining > this.maxTime * 0.5) {
      return '#4CAF50'; // 绿色
    } else if (this.timeRemaining > this.maxTime * 0.25) {
      return '#FF9800'; // 橙色
    } else {
      return '#F44336'; // 红色
    }
  }

  @Builder
  QuestionCard() {
    Column({ space: 12 }) {
      // 难度标签
      Row({ space: 8 }) {
        Text(getDifficultyName(this.currentQuestion!.difficulty).cn)
          .fontSize(12)
          .fontColor(getDifficultyName(this.currentQuestion!.difficulty).color)
          .backgroundColor(getDifficultyName(this.currentQuestion!.difficulty).color + '22')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)

        Text(getCategoryName(this.currentQuestion!.category).cn)
          .fontSize(12)
          .fontColor(DarkTheme.textSecondary)
          .backgroundColor(DarkTheme.backgroundSecondary)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
      }

      // 题目文本
      Text(this.currentQuestion!.question)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
        .textAlign(TextAlign.Center)
        .lineHeight(30)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(CardStyle.glassBackground)
    .borderRadius(CardStyle.borderRadius)
    .border({
      width: CardStyle.borderWidth,
      color: CardStyle.borderColor
    })
    .margin({ top: 16 })
  }

  @Builder
  OptionsArea() {
    Column({ space: 12 }) {
      ForEach(this.currentQuestion!.options, (option: string, index: number) => {
        this.OptionButton(option, index)
      })

      // 答题后显示解释
      if (this.isAnswered && this.currentQuestion!.explanation) {
        Column({ space: 8 }) {
          Text(this.isCorrect ? '回答正确！' : '回答错误')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.isCorrect ? '#4CAF50' : '#F44336')

          Text(this.currentQuestion!.explanation)
            .fontSize(13)
            .fontColor(DarkTheme.textSecondary)
            .lineHeight(20)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(CardStyle.glassBackground)
        .borderRadius(12)
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: 20 })
  }

  @Builder
  OptionButton(option: string, index: number) {
    Row() {
      // 选项字母
      Text(String.fromCharCode(65 + index))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getOptionLetterColor(index))
        .width(32)
        .height(32)
        .textAlign(TextAlign.Center)
        .backgroundColor(this.getOptionLetterBg(index))
        .borderRadius(16)

      // 选项内容
      Text(option)
        .fontSize(16)
        .fontColor(this.getOptionTextColor(index))
        .margin({ left: 12 })
        .layoutWeight(1)

      // 正确/错误图标
      if (this.isAnswered) {
        if (index === this.currentQuestion!.correctIndex) {
          Image($r('app.media.ic_correct'))
            .width(24)
            .height(24)
            .fillColor('#4CAF50')
        } else if (index === this.selectedIndex && !this.isCorrect) {
          Image($r('app.media.ic_wrong'))
            .width(24)
            .height(24)
            .fillColor('#F44336')
        }
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.getOptionBgColor(index))
    .borderRadius(12)
    .border({
      width: 2,
      color: this.getOptionBorderColor(index)
    })
    .onClick(() => {
      this.handleAnswer(index);
    })
  }

  getOptionBgColor(index: number): string {
    if (!this.isAnswered) {
      return CardStyle.glassBackground;
    }

    if (index === this.currentQuestion!.correctIndex) {
      return '#4CAF5022';
    } else if (index === this.selectedIndex) {
      return '#F4433622';
    }
    return CardStyle.glassBackground;
  }

  getOptionBorderColor(index: number): string {
    if (!this.isAnswered) {
      return CardStyle.borderColor;
    }

    if (index === this.currentQuestion!.correctIndex) {
      return '#4CAF50';
    } else if (index === this.selectedIndex) {
      return '#F44336';
    }
    return CardStyle.borderColor;
  }

  getOptionLetterColor(index: number): string {
    if (!this.isAnswered) {
      return DarkTheme.accent;
    }

    if (index === this.currentQuestion!.correctIndex) {
      return '#ffffff';
    } else if (index === this.selectedIndex) {
      return '#ffffff';
    }
    return DarkTheme.accent;
  }

  getOptionLetterBg(index: number): string {
    if (!this.isAnswered) {
      return DarkTheme.accent + '22';
    }

    if (index === this.currentQuestion!.correctIndex) {
      return '#4CAF50';
    } else if (index === this.selectedIndex) {
      return '#F44336';
    }
    return DarkTheme.accent + '22';
  }

  getOptionTextColor(index: number): string {
    if (!this.isAnswered) {
      return DarkTheme.textPrimary;
    }

    if (index === this.currentQuestion!.correctIndex) {
      return '#4CAF50';
    } else if (index === this.selectedIndex) {
      return '#F44336';
    }
    return DarkTheme.textSecondary;
  }
}
