# v53 平板首页网格与详情页紧凑化

## 1. 首页资产卡片平板自适应

基于 `lib/src_parts/features_asset_home.dart` 的真实源码修改。

原来的首页网格逻辑只有两档：
- 宽度 > 720：3 列
- 其他：2 列

这会导致一些平板/横屏/折叠屏明明可以显示 3 列，却仍然被压成 2 列。

v53 新增 `ResponsiveAssetGrid`：
- `< 620`：2 列，保持手机端原有排布
- `>= 620`：3 列
- `>= 920`：4 列
- `>= 1180`：5 列

手机竖屏仍然是 2 列，不影响原手机端布局。

## 2. 资产详情页命名与紧凑化

基于 `lib/src_parts/features_asset_detail.dart` 修改：

- `流转复盘` 改为 `价值回收`
- `目标成本` 改为 `日耗目标`
- `生命周期` 改为 `资产记录`

同时这些区域使用更小标题、更小内边距、更紧凑的指标格。

## 3. 相关文案同步

同步替换：
- 目标成本 -> 日耗目标
- 生命周期消耗 -> 净成本合计

涉及文件：
- `features_asset_home.dart`
- `features_asset_detail.dart`
- `features_wishes.dart`
- `features_analytics.dart`
