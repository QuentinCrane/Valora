# v6 来源覆盖映射

## 来自你的 Vue 项目的迁移内容

| Vue 模块 | Flutter v6 对应 |
| --- | --- |
| `App.vue` 全局壳、底部 Dock、FAB、返回逻辑 | `ShellPage`、`GlassDock`、`GlobalBackButton`、`ComposePage` |
| `AssetHome.vue` | `AssetHomePage`、`AssetOverviewCard`、`StatusAndViewRow`、`CategoryStrip`、三视图资产卡片 |
| `AssetDetail.vue` | `AssetDetailPage`、`AssetValueReplayCard`、`AssetLifecycleEventCard`、`DailyCostTrendChart` |
| `AssetEditor.vue` | `AssetEditorPage`，含状态、分类、标签、附加项、目标、到期提醒 |
| `WishHome.vue` / `WishEditor.vue` | `WishHomePage`、`WishEditorPage`、`WishCard`、心愿转资产 |
| `AnalyticsHome.vue` | `AnalyticsHomePage`、价值趋势、分类占比、标签分布、排行、服役时长 |
| `SettingsHome.vue` | `SettingsHomePage`、分类/标签管理、主题/货币/小数位、备份恢复 |
| `assetMetrics.ts` / `formulas.ts` | `Asset` getter、`AppStore` 聚合方法、趋势/分布/排行/目标计算 |
| `tokens.css` / `base.css` | `buildAppTheme`、`GradientScaffold`、`AppCard`、玻璃 Dock、主色 #7CC6F2 |

## 来自 APK 技术栈痕迹的学习方向

| APK 痕迹 | v6 采用方式 |
| --- | --- |
| Flutter 主体 | Flutter 安卓工程 |
| Realm 本地优先 | 当前用轻量 JSON + MethodChannel，文档建议后续替换 Isar/SQLite/Realm |
| fl_chart 统计图 | 当前用原生 CustomPainter 低依赖绘图，后续可替换 fl_chart |
| WebView | 当前暂不内置，因为没有真实协议/客服网页；保留后续扩展位 |
| 本地通知/锁屏 | 当前先做提醒字段和隐私设置开关，后续接插件 |
| 分类、标签、资产、心愿、备份 | 已作为核心数据模型和页面实现 |

## v6 新增原创增强

- 资产健康度；
- 价值象限；
- 快照对比；
- 去重 Hero 防崩；
- 全局卡片轻动效；
- 更清晰的 clean-room 审计文档。
