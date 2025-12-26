/**
 * 神话志 - 搜索栏组件
 */

import { DarkTheme } from '../common/Theme';

@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索神兽、属性、文化...';
  @Prop value: string = '';
  @Prop readonly: boolean = false;
  onChange?: (value: string) => void;
  onSubmit?: (value: string) => void;
  onTap?: () => void;

  build() {
    Row({ space: 8 }) {
      // 搜索图标
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)

      if (this.readonly) {
        // 只读模式，显示占位文本
        Text(this.placeholder)
          .fontSize(14)
          .fontColor(DarkTheme.textTertiary)
          .layoutWeight(1)
      } else {
        // 输入模式
        TextInput({ text: this.value, placeholder: this.placeholder })
          .fontSize(14)
          .fontColor(DarkTheme.textPrimary)
          .placeholderColor(DarkTheme.textTertiary)
          .placeholderFont({ size: 14 })
          .backgroundColor('transparent')
          .layoutWeight(1)
          .height('100%')
          .onChange((value: string) => {
            if (this.onChange) {
              this.onChange(value);
            }
          })
          .onSubmit((enterKey: EnterKeyType) => {
            if (this.onSubmit) {
              this.onSubmit(this.value);
            }
          })
      }

      // 清除按钮
      if (this.value.length > 0 && !this.readonly) {
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .onClick(() => {
            if (this.onChange) {
              this.onChange('');
            }
          })
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .backgroundColor(DarkTheme.backgroundSecondary)
    .borderRadius(22)
    .onClick(() => {
      if (this.onTap && this.readonly) {
        this.onTap();
      }
    })
  }
}
