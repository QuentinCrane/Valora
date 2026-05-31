# v54 场景化返回动画与设置聚合

## 1. 返回动画不再固定

本版在真实源码上改动：

- `lib/src_parts/common_widgets.dart`
  - 新增 `ValoraRouteStyle`
  - `PredictiveBackBoundary` 支持按页面类型改变拖拽返回反馈
  - 详情页、编辑页、设置页、弹层页、分析页的返回手势位移、缩放、圆角和触发边缘宽度不再完全一致

- `lib/src_parts/app_bootstrap.dart`
  - `softRoute` 从 `MaterialPageRoute` 改为 `PageRouteBuilder`
  - 自动根据页面类型选择不同的入场动画
  - 详情页偏轻量滑入；编辑/新增页偏底部浮起；设置页偏侧向滑入；弹层页偏底部上浮；分析页偏淡入缩放

- `lib/src_parts/features_asset_home.dart`
  - `appSheet` 显式使用 `ValoraRouteStyle.sheet`

## 2. 设置页重新聚合

原先设置分散为：总览 / 数据 / 外观 / 云端 / 原生 / 高级。

现在聚合为 4 个页签：

- 总览
- 数据
- 外观交互
- 系统

对应改动：

- `lib/src_parts/features_settings.dart`
  - `_SettingsTab` 缩减为 4 个
  - 分类、标签、备份、云端统一归入“数据”
  - 主题、首页风格、金额格式、触感、提示条、贴纸引擎统一归入“外观交互”
  - 原生功能、小组件、权限、预测返回、提醒、云端快捷操作统一归入“系统”
  - 总览页改成常用入口聚合

## 3. 说明

系统级预测式返回仍然依赖 Android 版本、系统手势导航和 Flutter 引擎支持。本版主要解决 App 内部页面过渡和边缘返回反馈过于固定的问题。
