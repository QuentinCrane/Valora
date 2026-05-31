# Valora学习版：参考实现映射

> 目标：学习同类“个人资产生命周期管理”App 的产品结构与开发方法，采用 clean-room 方式重新实现。本文档不包含第三方商业 App 的源码、素材、接口、品牌或像素级布局。

## 1. 相似但不复制的边界

可以参考：

- 个人资产生命周期管理这一产品方向
- “买入价 - 当前估值 / 卖出价 / 收益 = 真实消耗”的计算思路
- 资产状态：服役中、闲置中、已卖出、已退役
- 资产总览看板、分类统计、日均成本排行、愿望清单、备份恢复等通用功能
- Flutter 本地优先架构：页面 → 状态层 → 业务层 → 本地数据层

不能复制：

- 对方的 Dart/Flutter 源码、逆向代码、类实现
- 对方的图标、图片、字体、品牌名、文案、包名
- 对方的接口、会员支付、登录服务、用户协议页面
- 截图级 / 像素级复刻页面

## 2. 公开功能到本项目模块的映射

| 参考方向 | Valora实现 | 说明 |
|---|---|---|
| 万物资产化 | AssetItem 模型 | 可记录数码、摄影、会员、黄金、游戏账号等任何有价值物品 |
| 真实日耗 | dailyCost / consumedCost | 买入价、现值、卖出价、收益共同决定真实消耗 |
| 服役进度 | progressToTarget | 用目标日耗衡量“是否回本” |
| 资产总览看板 | DashboardCard | 当前估值、累计投入、已消耗、平均日耗 |
| 闲置复盘 | status + StatisticsPage | 统计闲置中、已卖出、已退役资产 |
| 分类统计 | categoryValues + PieChartLite | 按分类聚合当前估值 |
| 愿望清单 | WishItem + WishesPage | 想买物品进入冷静期，避免冲动消费 |
| 备份恢复 | exportJson / importJson | 复制 JSON 备份与恢复 |
| 隐私与本地优先 | Android SharedPreferences | 当前学习版不联网，数据保存在本地 |

## 3. 当前工程结构

```text
lib/main.dart                         # Flutter 主程序，包含 UI、状态、模型和本地通道调用
android/app/src/main/.../MainActivity # Android MethodChannel，本地读写 JSON
android/app/build.gradle              # Android 编译配置
pubspec.yaml                          # Flutter 项目配置
README.md                             # 运行说明
docs/                                 # 开发说明与 Codex 任务
```

为了降低学习门槛，当前版本故意保持“单文件 Flutter 主体”。当你确认功能可跑通之后，再让 Codex 拆分成 feature-first 架构。

## 4. 推荐后续拆分结构

```text
lib/
  main.dart
  app/
    app.dart
    routes/app_routes.dart
  core/
    theme/
    widgets/
    storage/local_json_store.dart
    utils/money.dart
  features/
    assets/
      models/asset_item.dart
      pages/asset_editor_page.dart
      pages/asset_detail_page.dart
      widgets/asset_card.dart
      services/asset_service.dart
    dashboard/
      pages/home_page.dart
      widgets/dashboard_card.dart
      widgets/insight_banner.dart
    statistics/
      pages/statistics_page.dart
      widgets/pie_chart_lite.dart
    wishes/
      models/wish_item.dart
      pages/wishes_page.dart
    settings/
      pages/settings_page.dart
      services/backup_service.dart
```

## 5. 更像完整 App 的迭代方向

优先级从高到低：

1. 把 SharedPreferences JSON 换成 Isar / SQLite / Realm。
2. 增加图片字段：本地图片路径、相册选择、资产封面。
3. 增加分类管理和标签管理页面。
4. 增加资产排序：购买时间、日均成本、当前估值、持有天数。
5. 增加首页视图模式：列表、卡片、贴纸。
6. 增加资产时间线：买入、估值变化、收益、卖出。
7. 增加导出文件：JSON / CSV。
8. 增加隐私锁：PIN / 生物识别。
9. 增加提醒：保修到期、会员续费、闲置检查。
10. 增加原创图标和启动页。

