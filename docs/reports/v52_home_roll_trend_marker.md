# v52 更新说明

## 1. 首页资产数字滚动与震动恢复

真实修改文件：
- `lib/src_parts/features_asset_home.dart`
- `lib/src_parts/app_bootstrap.dart`

修复点：
- `RollingMoney` 以前初始值直接等于最终值，进入首页时不会触发滚动。
- v52 改为进入页面时从 0 滚动到当前金额。
- 滚动过程中恢复分段触感反馈。
- App 启动加载设置后会调用 `configureRuntimeSettings(store.settings)`，确保震动开关状态和运行时一致。

## 2. 日均成本趋势增加当前位置标记

真实修改文件：
- `lib/src_parts/features_asset_detail.dart`

修复点：
- `DailyCostTrendChart` 现在把当前点传给 `LineChartPainter`。
- 趋势图上增加：
  - 当前点圆点
  - 当前所在位置的竖向虚线
  - “当前”标签
- 这样可以直接看出当前日均成本处于曲线上的哪个位置。

## 说明

本版本基于 v51 源码继续修改，版本号更新为 `0.52.0+52`。
