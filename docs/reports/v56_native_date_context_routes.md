# v56 原生日期选择、场景化返回与视觉指标优化

## 1. 日期选择改为 Android 原生组件

v55 中点击日期按钮会打开 Flutter 自定义日历网格。v56 已改为调用 Android 原生 `DatePickerDialog`：

- Flutter：`NativeBridge.pickNativeDate(...)`
- Android：`showNativeDatePicker(...)`
- 日期字段仍保留无格式输入能力，例如 `今天`、`0524`、`20260524`、`5.24`

已经移除 `showValoraDateEditor` 自定义日历网格的调用。

## 2. 详情页返回动画改成中心缩小

资产详情 / 心愿详情这类卡片详情页，现在的路由进入/返回动画改为：

- 进入：中心轻微缩放淡入
- 返回：向中心缩小并淡出
- 手势返回时也按 detail 类型做中心缩放，而不是固定侧滑

涉及：
- `PredictiveBackBoundary`
- `softRoute`
- `ValoraRouteStyle.detail`

## 3. 卡片式指标换成更直观的视觉表达

对“总资产 / 日均成本 / 服役时长”等指标做了视觉化处理：

- 加图标
- 加色彩区分
- 加小进度条
- 减少纯文字卡片感

涉及：
- `_OverviewMoneyBlock`
- `DetailMini`
- `MetricTile`
