# v69 日期选择器蓝色一致性修复

基于 v68 继续修复 MaterialDatePicker 颜色与显示问题。

## 问题
- 日期选择器虽然已经调用 `MaterialDatePicker.Builder.datePicker()`，但部分文字仍继承系统默认紫红色。
- 日期数字在部分设备/ROM 上出现轻微不居中/错位。
- 整体视觉仍不够贴近Valora的蓝色体系。

## 改动

### 1. 继续保留 Material 3 / Material Components 日期选择器
仍然使用：

```java
MaterialDatePicker.Builder.datePicker()
```

未退回旧 `DatePickerDialog`。

### 2. 补全主题色
在 `NormalTheme` 与 `ThemeOverlay.Valora.DatePicker` 中继续补充：
- `colorPrimary`
- `colorPrimaryContainer`
- `colorSecondary`
- `colorSecondaryContainer`
- `colorTertiary`
- `colorControlActivated`
- `colorControlHighlight`
- `buttonBarPositiveButtonStyle`
- `buttonBarNegativeButtonStyle`
- `materialButtonStyle`

### 3. 运行时二次统一颜色
`MainActivity.forceBlueMaterialDatePicker(...)` 会在弹窗显示后多次递归处理 DatePicker 视图树：
- MaterialButton / Button 文本统一成深蓝
- TextView 文本统一成深蓝或 muted 色
- 日期数字 / 年份数字居中
- 关闭系统紫红色残留

### 4. 视觉基调调整
- 弹窗背景改为白色圆角
- header 改为白色到浅蓝渐变
- dim 更轻
- ripple 保持Valora蓝

## 主要修改文件
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/java/com/valora/assets/MainActivity.java`
