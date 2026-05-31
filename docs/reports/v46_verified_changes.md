# v46 verified changes

基于 `v45_trace_sticker_category_home` 源码继续修改，重点修复：

1. 分析页可点击性
2. 日均成本排行无法进入详情
3. 快照只能创建，不能管理/删除
4. 分类预设过细，手机/电脑不适合作为长期分类体系

## 1. 价值象限增加详情入口

文件：`lib/src_parts/features_review.dart`

- `ValueQuadrantCard` 增加 `onTap`
- 新增 `showValueQuadrantDetail`
- 按四象限分组：
  - 长期低耗
  - 长期高耗
  - 短期低耗
  - 短期高耗
- 每个资产条目可点击进入 `AssetDetailPage`

## 2. 日均成本排行变为可查看详情

文件：`lib/src_parts/features_analytics.dart`

- 日均成本排行卡片整体可点击
- 新增 `showDailyCostRankingDetail`
- 榜单内每个资产也可直接进入详情页

## 3. 快照管理补齐

文件：
- `lib/src_parts/store.dart`
- `lib/src_parts/features_settings.dart`
- `lib/src_parts/features_asset_home.dart`

新增 store 方法：
- `deleteSnapshot`
- `renameSnapshot`

设置页备份管理中：
- 可恢复快照
- 可重命名快照
- 可删除快照

首页“资产时光机”：
- 不再点击后只创建快照
- 改为进入备份/快照管理界面

## 4. 推荐分类体系重做

文件：
- `lib/src_parts/features_settings.dart`
- `lib/src_parts/store.dart`

推荐分类从“手机、电脑”等具体物品，改成更适合资产管理的大类：

- 电子数码
- 影音娱乐
- 影像创作
- 游戏兴趣
- 学习办公
- 穿搭配饰
- 家居生活
- 出行交通
- 健康运动
- 工具维修
- 收藏纪念
- 软件服务

新增：
- `AppStore.applyRecommendedCategorySystem()`
- 分类管理页新增“应用推荐分类体系”按钮
- 尝试把旧的手机/电脑/摄影/游戏等小类迁移到对应大类

## 说明

这次改动没有涉及 AI 抠图模型，也没有声称替换模型；只针对用户本轮指出的分析点击、快照管理和分类体系问题修改。
