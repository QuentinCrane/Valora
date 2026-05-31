# v63 日耗预测曲线与价值回收收益

本版基于 v62 源码继续修改，重点解决两个需求：

1. 日均成本趋势需要结合日耗目标显示预测曲线。
2. 价值回收不能只依赖卖出价，还要能选择一组资产并记录它们实际赚回来的钱。

## 日均成本趋势

资产详情页的“日均成本趋势”现在分成：

- 蓝色实线：已经发生的成本摊薄过程。
- 蓝色虚线：如果设置了日耗目标/目标天数，会继续预测到目标天数。
- 绿色横向虚线：目标日耗线。
- 当前点：仍然保留当前位置圆点和竖向虚线。

实现位置：

- `lib/src_parts/features_asset_detail.dart`
- `DailyCostTrendChart`
- `LineChartPainter`

## 价值回收收益

新增全局数据模型：

- `ValueRecoveryRecord`

字段包括：

- id
- title
- assetIds
- amount
- date
- note
- createdAt / updatedAt

Store 新增：

- `recoveryRecords`
- `addRecoveryRecord`
- `deleteRecoveryRecord`
- `getRecoveryIncomeTotal`
- `getAssetRecoveryIncome`
- `getAssetTotalRecoveredValue`
- `getAssetNetConsumptionAfterRecovery`

导出/导入 JSON 时会带上 `recoveryRecords`。

## 使用方式

资产详情页的“价值回收”卡片新增“记录收益”。

可以：

1. 输入收益名称。
2. 输入金额。
3. 选择收益日期。
4. 多选参与产生收益的资产。
5. 保存后这笔收益会计入组合价值回收。

多资产收益会在单个资产详情页中按资产数量均摊展示。

## 口径说明

- `getLifecycleRecoveredValue()` = 卖出回收 + 使用收益。
- `getLifecycleNetConsumption()` = 原净消耗 - 使用收益。
- 单个资产详情页中，使用收益按选中资产数量均摊。
