# v4 参考验证与升级说明

本版本继续以 clean-room 学习实现为边界：不复用第三方 App 的源码、素材、品牌、接口、包名与像素级页面，只参考公开介绍中可观察到的产品方向，并结合 `codes.zip` 中 Vue 版的页面与交互进行 Flutter 化重构。

## 本轮参考来源

- Vue 源码：`AssetHome.vue`、`AssetDetail.vue`、`AnalyticsHome.vue`、`WishHome.vue`、`SettingsHome.vue`、`assetMetrics.ts`、`formulas.ts`、`models.ts`。
- 公开功能介绍：个人资产全生命周期管理、万物资产化、真实日耗、进度可视化、闲置流转复盘、资产总览看板、长期价值地图、钱包漏洞警报、资产时光机等方向。

## v4 新增能力

### 1. 首页资产生命账本

新增 `LifecycleDashboardCard`：

- 累计投入
- 当前净值
- 二手回收
- 生命周期净消耗
- 资产持有 / 回收 / 消耗的横向比例条

目的：让首页不只是资产列表，而是像 Vue 版总览卡 + 有数式资产看板一样，先回答“我到底花了多少、还剩多少、回收多少”。

### 2. 首页资产时光机

新增 `AssetTimeMachineCard`：

- 显示本机快照数量
- 显示最近快照名称
- 点击可快速生成当前资产快照

对应 Vue 版的快照恢复能力，也呼应公开介绍里的“资产时光机”。

### 3. 钱包漏洞警报

新增 `walletLeaks()` 计算与 `WalletLeakCard`：

- 日均成本显著高于均值
- 退役 / 吃灰资产
- 目标进度偏慢
- 即将到期资产

展示为首页中的风险卡片，可点进资产详情。

### 4. 资产详情页流转复盘

新增 `AssetValueReplayCard`：

- 投入合计
- 实际消耗
- 当前估值
- 最终日耗
- 已消费进度
- 已回收进度

目的：把买入价、附加项、卖出价、日耗放在同一个复盘模块里。

### 5. 资产详情页时间线

新增 `AssetLifecycleEventCard`：

- 买入节点
- 到期/保修节点
- 退役节点
- 卖出节点

用于呈现单件资产的生命周期，而不是只看静态字段。

### 6. 分析页长期价值地图

新增 `ValueTrendChart`：

- 根据资产购买时间与卖出时间生成估算净值曲线
- 不依赖第三方图表库，使用 Flutter `CustomPainter`

### 7. 分析页生命周期事件流

新增 `LifecycleTimelineCard`：

- 汇总最近买入、退役、卖出事件
- 用于资产复盘和长期记录感

### 8. 数据层增强

新增数据计算结构：

- `AssetLeakItem`
- `AssetTrendPoint`
- `LifecycleEventItem`

新增 Store 方法：

- `getTotalPurchaseCost()`
- `getActiveAssetValue()`
- `getSoldLossOrGain()`
- `getNetAssetPosition()`
- `walletLeaks()`
- `assetValueTrend()`
- `lifecycleEvents()`

新增 Asset 派生字段：

- `targetDays`
- `remainingTargetDays`
- `estimatedTargetDate`
- `serviceProgressRatio`

## 与 Vue 版的对应关系

| Vue 版 | Flutter v4 |
| --- | --- |
| `AssetOverviewCard.vue` | `AssetOverviewCard` + `LifecycleDashboardCard` |
| `assetMetrics.ts` 统计函数 | `AppStore` 聚合方法 |
| `TargetProgressBar.vue` | `TargetProgressBar` |
| `AnalyticsHome.vue` 趋势/分布/排行 | `AnalyticsHomePage` + `ValueTrendChart` + `PieChartLite` + `BarChartLite` |
| 本机快照 | `AssetTimeMachineCard` + `createSnapshot()` |
| 资产详情生命周期字段 | `AssetLifecycleEventCard` + `AssetValueReplayCard` |

## 仍建议 Codex 继续做的事情

1. 把 `part` 文件彻底改成真正的 import-based feature-first 架构。
2. 将 JSON + MethodChannel 存储升级为 Isar、SQLite 或 Realm。
3. 增加真实图片导入能力：`image_picker` / `photo_manager`。
4. 增加本地通知：资产到期、保修、订阅续费提醒。
5. 增加导出分享图：资产报告卡、年度复盘图。
6. 增加更多图表：分类趋势、日耗趋势、心愿预算趋势。
7. 增加更精细的编辑器：附加项增删、标签多选、图标选择、日期选择器。
