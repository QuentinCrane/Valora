# v68 强制蓝色 Material 日期选择器修正

这版针对“日期选择组件颜色仍然不正确”的问题做了更强的处理。

## 真实改动

### 1. Activity 原生主题修正
`MainActivity.onCreate()` 中在 `super.onCreate()` 前调用：

```java
setTheme(R.style.NormalTheme);
```

原因：Flutter 工程的 Activity 在 manifest 中通常使用 `LaunchTheme`，MaterialDatePicker 虽然通过 `setTheme(...)` 指定 overlay，但部分系统/ROM 上仍可能从 Activity 基础主题继承颜色，导致颜色落回系统默认紫色或绿色。

### 2. DatePicker 样式扩展
`styles.xml` 中补充了完整蓝色 Material Calendar 样式：

- NormalTheme 主色
- DatePicker overlay 主色
- 日期普通态
- 日期选中态
- 今日态
- 无效日期态
- 年份普通态
- 年份选中态
- 年份今日态
- 按钮 ripple / 文字颜色

### 3. 原生弹窗运行时补色
在 `MaterialDatePicker` show 后递归给 header、标题、按钮做一次蓝色系 tint，防止某些设备或 Material 版本没有完整吃到 XML overlay。

## 保留内容
仍然使用：

```java
MaterialDatePicker.Builder.datePicker()
```

没有退回旧版 `DatePickerDialog`。
