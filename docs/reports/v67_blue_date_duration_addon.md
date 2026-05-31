# v67 蓝色 Material 日期 + 附加物品购买时间 + 持有时长年/月

## 1. 日期选择器

当前 Android 侧仍使用官方 Material Components 的 `MaterialDatePicker.Builder.datePicker()`，并保持 `com.google.android.material:material:1.14.0`。

本版继续加强了主题统一：

- `NormalTheme` 写入Valora蓝色主题色。
- `materialCalendarTheme` / `materialCalendarFullscreenTheme` 指向 `ThemeOverlay.Valora.DatePicker`。
- 日期选择器主题继续使用：
  - `#7CC6F2`
  - `#113056`
  - `#D9F2FF`
  - `#E8F7FE`

## 2. 附加物品购买时间

v66 已经加入 `AddonItem.purchaseDate`，v67 保留并确认：

- 资产编辑页添加附加项目时可填写购买时间。
- 心愿 / 快速录入添加附加物品时可填写购买时间。
- 资产详情页、资产编辑页、心愿页均会显示附加物品购买时间。
- 旧数据没有购买时间时显示“未设置购买时间”。

## 3. 持有时间支持年/月显示

新增：

- `DurationMode.years`
- `durationCalendarText`
- `durationWithCalendarText`

现在“时长显示”设置里新增 `年/月`，例如：

- `28 天`
- `2 个月 5 天`
- `1 年 2 个月`

资产详情页的“服役时长”也改为更明确的“持有时间”，并可显示：

- 纯天数
- 周
- 月
- 年/月
- 或“天数 · 年/月”的组合说明

