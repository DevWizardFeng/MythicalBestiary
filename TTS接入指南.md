# HarmonyOS TTS 文字转语音接入指南

## 概述

本文档介绍如何在 HarmonyOS 应用中集成文字转语音（TTS）功能，包括工具类封装、UI 组件和使用示例。

---

## 1. TTSManager 工具类

### 文件路径
`entry/src/main/ets/utils/TTSManager.ets`

### 完整代码

```typescript
/**
 * 文本转语音管理器
 * 封装 TextToSpeechEngine 用于语音播报
 */

import { BusinessError } from '@kit.BasicServicesKit'
import { textToSpeech } from '@kit.CoreSpeechKit'

/**
 * TTS 播放状态
 */
export enum TTSState {
  IDLE = 0,        // 空闲
  PLAYING = 1,     // 播放中
  PAUSED = 2,      // 已暂停
  ERROR = 3        // 错误
}

/**
 * TTS 管理器
 */
export class TTSManager {
  private engine: textToSpeech.TextToSpeechEngine | null = null
  private state: TTSState = TTSState.IDLE
  private currentText: string = ''
  private currentRequestId: string = ''
  private onStateChange?: (state: TTSState) => void

  /**
   * 初始化 TTS 引擎
   */
  async init(): Promise<void> {
    try {
      if (this.engine) {
        console.info('[TTSManager] 引擎已初始化')
        return
      }

      const extraParam: Record<string, Object> = {
        "style": 'interaction-broadcast',
        "locate": 'CN',
        "name": 'AppTTS'
      }

      const initParams: textToSpeech.CreateEngineParams = {
        language: 'zh-CN',
        person: 0,      // 发音人（0 表示默认）
        online: 1,      // 在线模式
        extraParams: extraParam
      }

      return new Promise((resolve, reject) => {
        textToSpeech.createEngine(initParams, (err: BusinessError, engine: textToSpeech.TextToSpeechEngine) => {
          if (err) {
            console.error(`[TTSManager] 创建引擎失败: ${err.code} - ${err.message}`)
            this.updateState(TTSState.ERROR)
            reject(new Error(`TTS 引擎创建失败: ${err.message}`))
            return
          }

          console.info('[TTSManager] 引擎创建成功')
          this.engine = engine
          this.setupCallbacks()
          this.updateState(TTSState.IDLE)
          resolve()
        })
      })
    } catch (error) {
      console.error('[TTSManager] 初始化失败:', error)
      this.updateState(TTSState.ERROR)
      throw new Error(`TTS 初始化失败: ${error}`)
    }
  }

  /**
   * 设置回调监听
   */
  private setupCallbacks(): void {
    if (!this.engine) return

    const speakListener: textToSpeech.SpeakListener = {
      onStart: (requestId: string, response: textToSpeech.StartResponse) => {
        console.info(`[TTSManager] 播放开始: ${requestId}`)
        if (this.state !== TTSState.PLAYING) {
          this.updateState(TTSState.PLAYING)
        }
      },

      onComplete: (requestId: string, response: textToSpeech.CompleteResponse) => {
        console.info(`[TTSManager] 播放完成: ${requestId}`)
        if (requestId === this.currentRequestId) {
          this.updateState(TTSState.IDLE)
          this.currentText = ''
          this.currentRequestId = ''
        }
      },

      onStop: (requestId: string, response: textToSpeech.StopResponse) => {
        console.info(`[TTSManager] 播放停止: ${requestId}`)
        this.updateState(TTSState.IDLE)
        this.currentText = ''
        this.currentRequestId = ''
      },

      onData: (requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) => {
        // 可选：处理音频流数据
        console.debug(`[TTSManager] 音频数据: ${requestId}, 序号: ${response.sequence}`)
      },

      onError: (requestId: string, errorCode: number, errorMessage: string) => {
        console.error(`[TTSManager] 播放错误: ${requestId}, code: ${errorCode}, msg: ${errorMessage}`)
        this.updateState(TTSState.ERROR)
        this.currentText = ''
        this.currentRequestId = ''
      }
    }

    this.engine.setListener(speakListener)
  }

  /**
   * 播放文本
   */
  async speak(text: string): Promise<void> {
    try {
      let needInit = false
      if (!this.engine) {
        console.warn('[TTSManager] 引擎未初始化，尝试初始化...')
        needInit = true
        await this.init()
      }

      if (!this.engine) {
        throw new Error('TTS 引擎初始化失败')
      }

      // 如果刚初始化完成，等待引擎完全就绪
      if (needInit) {
        console.info('[TTSManager] 引擎刚初始化，等待就绪...')
        await new Promise<void>(resolve => setTimeout(resolve, 300))
      }

      // 如果正在播放，先停止
      if (this.state === TTSState.PLAYING) {
        await this.stop()
        await new Promise<void>(resolve => setTimeout(resolve, 100))
      }

      this.currentText = text
      this.currentRequestId = Date.now().toString()

      const extraParam: Record<string, Object> = {
        "queueMode": 0,      // 队列模式：0-清空队列后播放，1-追加到队列
        "speed": 1.0,        // 语速（0.5-2.0）
        "volume": 1.0,       // 音量（0.0-2.0）
        "pitch": 1.0,        // 音调（0.5-2.0）
        "playType": 1        // 播放类型：1-边合成边播放（流式），0-合成完成后播放
      }

      const speakParams: textToSpeech.SpeakParams = {
        requestId: this.currentRequestId,
        extraParams: extraParam
      }

      // 先更新状态为播放中
      this.updateState(TTSState.PLAYING)

      console.info(`[TTSManager] 开始播放: ${text.substring(0, 50)}...`)
      this.engine.speak(text, speakParams)
    } catch (error) {
      console.error('[TTSManager] 播放失败:', error)
      this.updateState(TTSState.ERROR)
      throw new Error(`TTS 播放失败: ${error}`)
    }
  }

  /**
   * 停止播放
   */
  async stop(): Promise<void> {
    try {
      if (!this.engine || this.state !== TTSState.PLAYING) {
        return
      }

      console.info('[TTSManager] 停止播放')
      this.engine.stop()
      this.updateState(TTSState.IDLE)
      this.currentText = ''
      this.currentRequestId = ''
    } catch (error) {
      console.error('[TTSManager] 停止播放失败:', error)
      throw new Error(`TTS 停止失败: ${error}`)
    }
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    try {
      if (!this.engine) {
        return
      }

      if (this.state === TTSState.PLAYING) {
        await this.stop()
      }

      console.info('[TTSManager] 释放引擎')
      this.engine.shutdown()
      this.engine = null
      this.updateState(TTSState.IDLE)
      this.currentText = ''
      this.currentRequestId = ''
    } catch (error) {
      console.error('[TTSManager] 释放资源失败:', error)
      throw new Error(`TTS 资源释放失败: ${error}`)
    }
  }

  /**
   * 更新状态
   */
  private updateState(newState: TTSState): void {
    this.state = newState
    if (this.onStateChange) {
      this.onStateChange(newState)
    }
  }

  /**
   * 获取当前状态
   */
  getState(): TTSState {
    return this.state
  }

  /**
   * 是否正在播放
   */
  isPlaying(): boolean {
    return this.state === TTSState.PLAYING
  }

  /**
   * 设置状态变化监听器
   */
  setOnStateChange(callback: (state: TTSState) => void): void {
    this.onStateChange = callback
  }
}
```

---

## 2. 页面集成示例

### 导入模块

```typescript
import { TTSManager, TTSState } from '../utils/TTSManager'
import { promptAction } from '@kit.ArkUI'
```

### 组件代码

```typescript
@Entry
@Component
struct YourPage {
  @State isTTSPlaying: boolean = false
  @State yourData: YourDataType | null = null
  private ttsManager: TTSManager = new TTSManager()

  aboutToAppear(): void {
    // 加载数据...

    // 初始化 TTS 引擎
    this.initTTS()
  }

  aboutToDisappear(): void {
    // 释放 TTS 资源
    this.releaseTTS()
  }

  /**
   * 初始化 TTS 引擎
   */
  async initTTS(): Promise<void> {
    try {
      await this.ttsManager.init()

      // 设置状态变化监听器
      this.ttsManager.setOnStateChange((state: TTSState) => {
        this.isTTSPlaying = (state === TTSState.PLAYING)
      })

      console.info('TTS 引擎初始化成功')
    } catch (error) {
      console.error('TTS 引擎初始化失败:', error)
    }
  }

  /**
   * 释放 TTS 资源
   */
  async releaseTTS(): Promise<void> {
    try {
      await this.ttsManager.release()
      console.info('TTS 资源已释放')
    } catch (error) {
      console.error('TTS 资源释放失败:', error)
    }
  }

  /**
   * 播放/停止语音
   */
  async toggleTTS(): Promise<void> {
    if (!this.yourData) return

    try {
      if (this.isTTSPlaying) {
        // 停止播放
        this.isTTSPlaying = false
        await this.ttsManager.stop()
      } else {
        // 组合要朗读的文本
        const text = this.buildIntroText()

        // 快速切换状态来"预热"动效（解决首次点击动效不生效问题）
        this.isTTSPlaying = true
        this.isTTSPlaying = false
        setTimeout(() => {
          this.isTTSPlaying = true
        }, 16) // 一帧的时间（约16ms）

        // 开始播放
        try {
          await this.ttsManager.speak(text)
        } catch (speakError) {
          this.isTTSPlaying = false
          throw new Error(`TTS 播放失败: ${speakError}`)
        }
      }
    } catch (error) {
      console.error('TTS 操作失败:', error)
      this.isTTSPlaying = false
      promptAction.showToast({
        message: '语音播放失败，请稍后重试',
        duration: 2000,
        bottom: 100
      })
    }
  }

  /**
   * 构建要朗读的文本
   */
  private buildIntroText(): string {
    if (!this.yourData) return ''

    const parts: string[] = []
    // 根据实际数据构建朗读文本
    parts.push(`${this.yourData.title}`)
    parts.push(`${this.yourData.description}`)
    // ...

    return parts.join(' ')
  }

  build() {
    // ... UI 代码
  }
}
```

---

## 3. UI 组件 - 波动动效播放按钮

### 方案一：SymbolGlyph（推荐）

```typescript
// 语音播放按钮（带波动动效）
Column() {
  SymbolGlyph($r('sys.symbol.speaker_wave_3'))
    .fontSize(20)
    .fontColor(['#D4AF37'])  // 金色
    .symbolEffect(
      new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE),
      this.isTTSPlaying  // 控制动效开关
    )
}
.width(36)
.height(36)
.justifyContent(FlexAlign.Center)
.backgroundColor('#1A2233')
.borderRadius(18)
.border({ width: 1, color: '#333' })
.onClick(() => this.toggleTTS())
```

### 方案二：自定义图标

```typescript
// 使用自定义图标（播放/暂停切换）
Column() {
  Image(this.isTTSPlaying ? $r('app.media.icon_pause') : $r('app.media.icon_play'))
    .width(20)
    .height(20)
    .fillColor('#D4AF37')
}
.width(36)
.height(36)
.justifyContent(FlexAlign.Center)
.backgroundColor('#1A2233')
.borderRadius(18)
.border({ width: 1, color: '#333' })
.onClick(() => this.toggleTTS())
```

### 完整示例（集成到标题栏）

```typescript
@Builder
ContentSection() {
  Column() {
    // 标题行：标题文字 + 语音播放按钮
    Row() {
      Row() {
        Column()
          .width(4)
          .height(20)
          .backgroundColor('#D4AF37')
          .borderRadius(2)

        Text('详情介绍')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E8E6E3')
          .margin({ left: 8 })
      }

      Blank()

      // 语音播放按钮
      Column() {
        SymbolGlyph($r('sys.symbol.speaker_wave_3'))
          .fontSize(20)
          .fontColor(['#D4AF37'])
          .symbolEffect(
            new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE),
            this.isTTSPlaying
          )
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1A2233')
      .borderRadius(18)
      .border({ width: 1, color: '#333' })
      .onClick(() => this.toggleTTS())
    }
    .width('100%')
    .margin({ bottom: 16 })

    // 内容文本
    Text(this.yourData?.content)
      .fontSize(14)
      .fontColor('#C0C0C0')
      .lineHeight(24)
  }
  .width('100%')
  .padding(16)
  .alignItems(HorizontalAlign.Start)
}
```

---

## 4. 关键技术点

### 4.1 API 使用

| API | 说明 |
|-----|------|
| `@kit.CoreSpeechKit` | TTS 核心能力包 |
| `textToSpeech.createEngine()` | 创建 TTS 引擎 |
| `engine.setListener()` | 设置回调监听器（**不是** `on()`） |
| `engine.speak()` | 开始语音播报 |
| `engine.stop()` | 停止播报 |
| `engine.shutdown()` | 关闭引擎 |

### 4.2 回调监听器

```typescript
const speakListener: textToSpeech.SpeakListener = {
  onStart: (requestId, response) => {},      // 开始播报
  onComplete: (requestId, response) => {},   // 播报完成
  onStop: (requestId, response) => {},       // 停止播报
  onData: (requestId, audio, response) => {}, // 音频流（可选）
  onError: (requestId, errorCode, msg) => {} // 播报错误
}
```

### 4.3 播放参数

```typescript
const extraParam: Record<string, Object> = {
  "queueMode": 0,  // 0-清空队列后播放，1-追加到队列
  "speed": 1.0,    // 语速（0.5-2.0）
  "volume": 1.0,   // 音量（0.0-2.0）
  "pitch": 1.0,    // 音调（0.5-2.0）
  "playType": 1    // 1-流式播放，0-合成完成后播放
}
```

### 4.4 动效图标

| 系统图标 | 说明 |
|---------|------|
| `sys.symbol.speaker_wave_3` | 扬声器（3 级音波） |
| `sys.symbol.speaker_wave_2` | 扬声器（2 级音波） |
| `sys.symbol.speaker_wave_1` | 扬声器（1 级音波） |

**动效类型**：
```typescript
new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE)
```

### 4.5 首次点击动效修复

**问题**：第一次点击时波动动效不生效，需要第二次点击才正常。

**解决方案**：快速切换状态模拟"第二次点击"
```typescript
// 快速切换状态：true → false → true
this.isTTSPlaying = true
this.isTTSPlaying = false
setTimeout(() => {
  this.isTTSPlaying = true
}, 16)  // 16ms ≈ 1 帧
```

### 4.6 ArkTS 错误处理限制

**错误写法**：
```typescript
catch (error) {
  throw error  // ❌ arkts-limited-throw
}
```

**正确写法**：
```typescript
catch (error) {
  throw new Error(`描述: ${error}`)  // ✅
}
```

---

## 5. 生命周期管理

### 初始化时机
- `aboutToAppear()` 中调用 `initTTS()`
- 可以异步初始化，不阻塞页面渲染

### 释放时机
- `aboutToDisappear()` 中调用 `releaseTTS()`
- 确保引擎资源正确释放

### 状态同步
- 通过 `setOnStateChange()` 回调同步播放状态
- 使用 `@State` 变量驱动 UI 更新

---

## 6. 实际应用示例

### 神兵详情页 TTS

```typescript
private buildWeaponIntroText(): string {
  if (!this.weapon) return ''

  const parts: string[] = []

  // 名称和品质
  parts.push(`${this.weapon.name.cn}，${RarityNames[this.weapon.rarity]}品质神兵。`)

  // 分类
  parts.push(`来自${CultureNames[this.weapon.culture]}文化，属于${WeaponTypeNames[this.weapon.type]}类兵器。`)

  // 描述
  parts.push(this.weapon.description)

  // 铭文
  if (this.weapon.inscription) {
    parts.push(`铭文：${this.weapon.inscription}`)
  }

  // 铸造传说
  parts.push(`铸造传说：${this.weapon.forging_legend}`)

  // 战斗传说
  parts.push(`战斗传说：${this.weapon.battle_legend}`)

  return parts.join(' ')
}
```

### 铸造师详情页 TTS

```typescript
private buildBlacksmithIntroText(): string {
  if (!this.blacksmith) return ''

  const parts: string[] = []

  // 名称和称号
  parts.push(`${this.blacksmith.name.cn}，${this.blacksmith.title}。`)

  // 文化和时代
  parts.push(`来自${CultureNames[this.blacksmith.culture]}，活跃于${this.blacksmith.era}。`)

  // 简介
  parts.push(this.blacksmith.bio || this.blacksmith.description)

  // 铸造技法
  if (this.blacksmith.techniques && this.blacksmith.techniques.length > 0) {
    parts.push(`擅长技法：${this.blacksmith.techniques.join('、')}。`)
  }

  // 传奇事迹
  parts.push(`传奇事迹：${this.blacksmith.legend}`)

  return parts.join(' ')
}
```

---

## 7. 注意事项

1. **无需额外权限**：HarmonyOS TTS 不需要配置 `module.json5` 权限

2. **引擎复用**：同一页面只创建一个 `TTSManager` 实例

3. **状态管理**：确保播放状态与 UI 状态同步

4. **资源释放**：页面销毁时必须调用 `release()`

5. **错误处理**：播放失败时给用户友好提示

6. **文本长度**：过长文本建议分段或截取关键信息

7. **在线模式**：`online: 1` 使用在线语音，音质更好

8. **流式播放**：`playType: 1` 边合成边播放，响应更快

---

## 8. 常见问题

### Q1: 第一次点击动效不生效？
**A**: 使用快速切换状态方案（见 4.5 节）

### Q2: 如何调整语速和音调？
**A**: 修改 `speak()` 方法中的 `extraParam` 参数

### Q3: 如何判断是否正在播放？
**A**: 使用 `ttsManager.isPlaying()` 或检查 `isTTSPlaying` 状态

### Q4: 如何支持多语言？
**A**: 修改 `CreateEngineParams` 中的 `language` 参数

### Q5: 播放时切换页面会怎样？
**A**: `aboutToDisappear()` 会自动停止播放并释放资源

---

## 9. 扩展功能

### 支持暂停/恢复（需要自行实现）
```typescript
// 当前 HarmonyOS TTS 不直接支持暂停
// 可以记录播放位置，停止后重新从该位置播放
```

### 支持播放进度
```typescript
// 使用 onData 回调监听音频流
onData: (requestId, audio, response) => {
  const progress = response.sequence / totalSequences
  this.playbackProgress = progress
}
```

### 支持多音色切换
```typescript
const initParams: textToSpeech.CreateEngineParams = {
  language: 'zh-CN',
  person: 1,  // 切换不同的发音人
  online: 1,
  extraParams: extraParam
}
```

---

## 10. 参考资料

- HarmonyOS 官方文档：[文字转语音（TextToSpeech）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-TextToSpeech)
- SymbolGlyph 动效：[SymbolEffect](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-symboleffect)

---

**文档版本**: v1.0
**更新日期**: 2025-12-28
**适用项目**: 神兵图录 (Legendary Armory)
