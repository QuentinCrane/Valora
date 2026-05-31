# v59 首页总览 / Material 3 日期 / 返回动画修正

## 1. 首页资产总览按截图重做

`AssetOverviewCard` 恢复成更接近参考图的排布：

- 标题 `资产总览` + 数量胶囊。
- 第一行两个大数字：总资产 / 日均成本。
- 中间虚线分隔。
- 底部三个状态进度条：服役中 / 已退役 / 已卖出。
- 去掉 v58 误加的首页图标指标卡和小进度条。

手机端布局仍是单张总览卡，不影响资产网格的手机排布。

## 2. Android 日期选择器继续修正

- 仍使用官方 Material Components 的 `MaterialDatePicker.Builder.datePicker()`。
- Material 依赖升级到 `1.14.0`，以使用更新的 Material 3 / Expressive 组件样式。
- DatePicker theme overlay 统一使用Valora主色 `#7CC6F2` 与深蓝文字 `#113056`。
- 按钮文字改为“完成 / 取消”。

## 3. 返回动画与帧率优化

- 详情页返回继续使用中心缩小淡出。
- 手势返回过程中不再逐帧触发震动，避免掉帧。
- 降低过重阴影和动画时长。
- 页面内容增加 `RepaintBoundary`，降低拖拽返回过程的重绘压力。
