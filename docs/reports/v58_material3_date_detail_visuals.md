# v58 修复说明

## 1. 日期选择改为 Material 3 / Material Components 日期选择器

v56/v57 中仍使用 `DatePickerDialog`，体验偏旧。v58 改为 Android 原生侧 `MaterialDatePicker`：

- `MainActivity` 从 `FlutterActivity` 切换为 `FlutterFragmentActivity`，以便使用 `supportFragmentManager`。
- 新增依赖：
  - `com.google.android.material:material:1.12.0`
  - `androidx.appcompat:appcompat:1.7.0`
- `NormalTheme` 调整为 `Theme.Material3.DayNight.NoActionBar`。
- 新增 `ThemeOverlay.Valora.DatePicker`，使用 `ThemeOverlay.Material3.MaterialCalendar`。
- `showNativeDatePicker` 使用 `MaterialDatePicker.Builder.datePicker()`。

保留 Flutter 侧无格式输入解析能力，但点击日历按钮时不再使用旧的 `DatePickerDialog`。

## 2. 首页指标卡片恢复原样

用户指出“日均成本等卡片”希望修改的是资产详情页，而不是首页。v58 将首页 `MetricTile` 恢复为 v55 风格，避免影响首页布局。

## 3. 资产详情页指标视觉优化

仅在资产详情页增强：

- `DetailMini` 改为更直观的彩色指标条 + 图标 + 进度条。
- `DetailCell` 改为图标化信息条。
- 日均成本、服役时长、日期、价格等信息更容易区分。

## 4. 返回动画保留

保留 v56/v57 的 detail 路由中心缩小返回逻辑。
