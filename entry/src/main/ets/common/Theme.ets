/**
 * 神话志 - 主题配置
 */

/**
 * 主题模式
 */
export type ThemeMode = 'dark' | 'light';

/**
 * 主题颜色配置接口
 */
interface ThemeColors {
  // 背景色
  background: string;
  backgroundSecondary: string;
  backgroundCard: string;

  // 文字颜色
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;

  // 强调色
  accent: string;
  accentSecondary: string;

  // 分割线
  divider: string;

  // 状态颜色
  success: string;
  warning: string;
  error: string;

  // 渐变起始色
  gradientStart: string;
  gradientEnd: string;
}

/**
 * 深色主题配色
 */
export const DarkTheme: ThemeColors = {
  background: '#1a1a3e',
  backgroundSecondary: '#2d1b4e',
  backgroundCard: '#252550',

  textPrimary: '#e0e0e0',
  textSecondary: '#9e9e9e',
  textTertiary: '#666666',

  accent: '#ffd700',
  accentSecondary: '#9d4edd',

  divider: '#424242',

  success: '#4caf50',
  warning: '#ff9800',
  error: '#f44336',

  gradientStart: '#1a1a3e',
  gradientEnd: '#2d1b4e'
};

/**
 * 浅色主题配色
 */
export const LightTheme: ThemeColors = {
  background: '#f5f5f5',
  backgroundSecondary: '#ffffff',
  backgroundCard: '#ffffff',

  textPrimary: '#212121',
  textSecondary: '#757575',
  textTertiary: '#9e9e9e',

  accent: '#d4af37',
  accentSecondary: '#7b1fa2',

  divider: '#e0e0e0',

  success: '#4caf50',
  warning: '#ff9800',
  error: '#f44336',

  gradientStart: '#f5f5f5',
  gradientEnd: '#e0e0e0'
};

/**
 * 获取当前主题
 */
export function getTheme(mode: ThemeMode): ThemeColors {
  return mode === 'dark' ? DarkTheme : LightTheme;
}

/**
 * 应用主题管理器
 */
export class ThemeManager {
  private static instance: ThemeManager;
  private currentMode: ThemeMode = 'dark';
  private currentTheme: ThemeColors = DarkTheme;

  private constructor() {}

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 获取当前主题模式
   */
  getMode(): ThemeMode {
    return this.currentMode;
  }

  /**
   * 获取当前主题配色
   */
  getColors(): ThemeColors {
    return this.currentTheme;
  }

  /**
   * 设置主题模式
   */
  setMode(mode: ThemeMode): void {
    this.currentMode = mode;
    this.currentTheme = getTheme(mode);
  }

  /**
   * 切换主题
   */
  toggleTheme(): void {
    this.setMode(this.currentMode === 'dark' ? 'light' : 'dark');
  }

  /**
   * 是否为深色模式
   */
  isDarkMode(): boolean {
    return this.currentMode === 'dark';
  }
}

/**
 * 全局主题实例
 */
export const themeManager = ThemeManager.getInstance();

/**
 * 通用样式常量
 */
export class CommonStyles {
  // 阴影效果
  static readonly SHADOW_LIGHT: string = '0 2px 4px rgba(0, 0, 0, 0.1)';
  static readonly SHADOW_MEDIUM: string = '0 4px 8px rgba(0, 0, 0, 0.2)';
  static readonly SHADOW_HEAVY: string = '0 8px 16px rgba(0, 0, 0, 0.3)';

  // 模糊效果
  static readonly BLUR_LIGHT: number = 10;
  static readonly BLUR_MEDIUM: number = 20;
  static readonly BLUR_HEAVY: number = 30;

  // 动画时长
  static readonly ANIMATION_FAST: number = 150;
  static readonly ANIMATION_NORMAL: number = 300;
  static readonly ANIMATION_SLOW: number = 500;

  // 透明度
  static readonly OPACITY_DISABLED: number = 0.5;
  static readonly OPACITY_OVERLAY: number = 0.7;
  static readonly OPACITY_MASK: number = 0.85;
}

/**
 * 渐变背景接口
 */
export interface GradientConfig {
  angle: number;
  colors: string[];
}

/**
 * 卡片样式接口
 */
export interface CardStyleConfig {
  backgroundColor: string;
  borderRadius: number;
  shadow: string;
}

/**
 * 渐变背景样式
 */
export function getGradientBackground(theme: ThemeColors): GradientConfig {
  const config: GradientConfig = {
    angle: 180,
    colors: [theme.gradientStart, theme.gradientEnd]
  };
  return config;
}

/**
 * 卡片样式
 */
export function getCardStyle(theme: ThemeColors): CardStyleConfig {
  const config: CardStyleConfig = {
    backgroundColor: theme.backgroundCard,
    borderRadius: 12,
    shadow: CommonStyles.SHADOW_MEDIUM
  };
  return config;
}
