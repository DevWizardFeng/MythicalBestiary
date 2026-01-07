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
 * TTS 管理器（全局单例）
 */
export class TTSManager {
  private static instance: TTSManager | null = null
  private engine: textToSpeech.TextToSpeechEngine | null = null
  private state: TTSState = TTSState.IDLE
  private currentText: string = ''
  private currentRequestId: string = ''
  private stateChangeCallbacks: Set<(state: TTSState) => void> = new Set()

  private constructor() {}

  /**
   * 获取全局单例
   */
  static getInstance(): TTSManager {
    if (!TTSManager.instance) {
      TTSManager.instance = new TTSManager()
    }
    return TTSManager.instance
  }

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
    // 通知所有监听器
    this.stateChangeCallbacks.forEach(callback => {
      try {
        callback(newState)
      } catch (error) {
        console.error('[TTSManager] 状态回调执行失败:', error)
      }
    })
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
   * 添加状态变化监听器
   */
  addStateChangeListener(callback: (state: TTSState) => void): void {
    this.stateChangeCallbacks.add(callback)
  }

  /**
   * 移除状态变化监听器
   */
  removeStateChangeListener(callback: (state: TTSState) => void): void {
    this.stateChangeCallbacks.delete(callback)
  }

  /**
   * 清空所有监听器
   */
  clearStateChangeListeners(): void {
    this.stateChangeCallbacks.clear()
  }
}
