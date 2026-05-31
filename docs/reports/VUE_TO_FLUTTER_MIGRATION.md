# Vue → Flutter 重构迁移说明

## 迁移来源

用户上传的 `codes.zip` 中包含 Vue 3 + Vite + Pinia 实现，主要文件：

- `src/App.vue`：全局壳、路由淡入淡出、全局返回、底部 Dock、FAB
- `src/router.ts`：资产、心愿、分析、设置、详情、编辑、新增路由
- `src/pages/AssetHome.vue`：资产首页、状态筛选、分类筛选、三种视图、搜索/筛选/排序 Sheet
- `src/pages/AssetDetail.vue`：资产详情、趋势、目标成本、生命周期
- `src/pages/AssetEditor.vue`：资产编辑表单
- `src/pages/WishHome.vue` / `WishEditor.vue`：心愿清单与编辑
- `src/pages/AnalyticsHome.vue`：统计分析
- `src/pages/SettingsHome.vue`：设置、分类标签、备份快照
- `src/domain/models.ts`：核心数据模型
- `src/domain/formulas.ts` / `src/utils/assetMetrics.ts`：日均成本、服役天数、资产总值等公式
- `src/styles/tokens.css` / `src/styles/base.css`：色彩、圆角、卡片、全局壳视觉

## Flutter 对应关系

| Vue 结构 | Flutter 结构 |
|---|---|
| `App.vue` | `ShellPage` + `GradientScaffold` + `GlassDock` + `GlobalBackButton` |
| `AppNav.vue` | `GlassDock` |
| `FloatingActionButton.vue` | `FloatingActionButton` + `ComposePage` |
| `AssetHome.vue` | `AssetHomePage` |
| `AssetOverviewCard.vue` | `AssetOverviewCard` |
| `AssetCard.vue` | `AssetGridCard` |
| `AssetListRow.vue` | `AssetListTileCard` |
| `AssetStickerItem.vue` | `AssetStickerChip` |
| `BaseSheet.vue` | `appSheet()` |
| `AssetDetail.vue` | `AssetDetailPage` |
| `AssetEditor.vue` | `AssetEditorPage` |
| `ComposePage.vue` | `ComposePage` |
| `WishHome.vue` | `WishHomePage` |
| `WishEditor.vue` | `WishEditorPage` |
| `AnalyticsHome.vue` | `AnalyticsHomePage` |
| `SettingsHome.vue` | `SettingsHomePage` |
| Pinia `ledger` store | `AppStore extends ChangeNotifier` |
| `localStorage` | Android `SharedPreferences` via MethodChannel |
| ECharts | Flutter `CustomPainter` 轻量图表 |

## 保留的关键产品逻辑

- 日均成本 = 净成本 / 服役天数
- 净成本 = 买入价 + 计入日均的附加项 - 卖出价
- 资产总值排除已卖出资产，可配置是否计入退役资产
- 资产支持分类、标签、状态、目标成本、附加项目、到期提醒字段
- 心愿可以转为资产，转化后自动归档
- JSON 导出、粘贴恢复、本机快照恢复

## 还可以继续让 Codex 做的事

1. 把单文件 `lib/main.dart` 拆成 feature-first 结构。
2. 把 SharedPreferences JSON 存储升级为 Isar / SQLite / Realm。
3. 引入真实图标库、图片选择、图片裁剪和本地文件管理。
4. 把当前 CustomPainter 图表替换为 `fl_chart`。
5. 增加本地通知、隐私锁、导入导出文件选择器。
6. 优化平板布局，把首页资产卡片改为双列/三列自适应。
