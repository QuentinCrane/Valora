# v3 继续完善说明

本版是在 `valora_flutter_android_vue_migrated` 的基础上继续完善，目标是把上一次提到的“后续建议”落到工程里，而不是只停留在文档层。

## 1. 已经做的结构优化

原来的迁移版把大部分代码集中在 `lib/main.dart`，适合作为一次性迁移原型，但不适合继续让 Codex 长期维护。本版改成 Dart `part` 结构：

```text
lib/
├─ main.dart
└─ src_parts/
   ├─ app_bootstrap.dart          # App 启动、主题、Scope、基础工具
   ├─ models.dart                 # Asset / Wish / Category / Tag / Settings 等模型
   ├─ store.dart                  # AppStore、持久化、筛选、统计、体检逻辑
   ├─ shell.dart                  # 底部 Dock、页面容器
   ├─ features_asset_home.dart    # 首页、资产卡片、筛选入口
   ├─ features_asset_detail.dart  # 资产详情、趋势图
   ├─ features_asset_editor.dart  # 资产编辑、附加项、目标设置
   ├─ features_wishes.dart        # 心愿页、心愿编辑、转资产
   ├─ features_analytics.dart     # 分析页、饼图、柱状图
   ├─ features_settings.dart      # 设置、分类/标签管理、备份恢复
   └─ common_widgets.dart         # Logo、返回按钮、缺省页面
```

这样做的好处是：

- 不改变运行方式；
- 不引入复杂依赖；
- 先把单文件工程拆开，降低 Codex 后续修改成本；
- 后面可以逐步从 `part` 结构升级为真正的 `import` + feature-first 包结构。

## 2. 已经做的存储抽象

原先 `AppStore` 直接持有 `MethodChannel`。本版新增了 `LocalJsonStorage`：

```dart
class LocalJsonStorage {
  static const MethodChannel _channel = MethodChannel('valora/local_store');
  const LocalJsonStorage();
  Future<String> load();
  Future<void> save(String json);
}
```

现在 `AppStore` 通过 `_storage.load()` 和 `_storage.save()` 读写数据。这样后面替换成 Isar、SQLite、Realm 时，只需要优先改存储层，不必把 UI 全部推倒。

## 3. 已经新增的功能

### 资产体检 Insight

新增 `AssetInsight` 和 `store.assetInsights()`，自动从当前资产、心愿和目标中生成提示：

- 日耗偏高：识别高于平均水平较多的资产；
- 目标接近完成：识别目标日耗 / 使用天数接近达成的资产；
- 即将到期：识别到期日期在提醒范围内的资产；
- 闲置复盘：识别退役或“吃灰”标签资产；
- 心愿预算偏高：识别未完成心愿预算过高的情况。

### 首页 Insight 横滑卡片

首页总览卡下方新增了横滑提示卡，用户一打开 App 就能看到“现在最值得注意的资产问题”。

### 分析页资产体检区块

分析页新增：

- 资产体检列表；
- 生命周期消耗；
- 二手回收金额。

这让分析页不只是看图，而是开始具备“解释资产状态”的能力。

## 4. 还没有做、但建议下一步做的内容

### A. 真正升级数据库

当前依旧是 JSON + Android SharedPreferences，适合学习和轻量 demo。正式版建议升级为：

优先推荐：

```text
Isar / SQLite
```

更贴近参考 App 的路线：

```text
Realm
```

迁移策略：

1. 保留 `Asset/Wish/Category/Tag/AppSettings` 模型字段；
2. 新增 `AssetRepository`、`WishRepository`、`SettingsRepository`；
3. `AppStore` 不再直接持有 List，而是通过 Repository 加载；
4. 保留 JSON 导入导出作为备份格式。

### B. 把 part 结构升级为 import 结构

当前结构是过渡形态。下一步可以让 Codex 按下面目标改：

```text
lib/
├─ app/
├─ core/
│  ├─ theme/
│  ├─ widgets/
│  ├─ utils/
│  └─ storage/
├─ data/
│  ├─ models/
│  ├─ repositories/
│  └─ services/
└─ features/
   ├─ asset/
   ├─ wish/
   ├─ analytics/
   └─ settings/
```

### C. 完善真实移动端能力

建议依次接入：

1. 图片选择与本地图片路径保存；
2. Android 本地通知，用于保修/订阅到期提醒；
3. 文件选择器，实现真正的 JSON 文件导入导出；
4. 本地隐私锁；
5. 首页小组件或分享长图。

## 5. 给 Codex 的下一条建议提示词

```text
请在当前 Flutter 工程基础上继续重构：
1. 保持所有功能不丢失；
2. 将 Dart part 文件逐步升级为 import-based feature-first 架构；
3. 新增 data/repositories 层；
4. 先不要引入复杂数据库，先把 LocalJsonStorage 替换为 Repository 接口；
5. 所有页面仍保持当前 UI 和交互，不要大幅改视觉；
6. 确保 flutter analyze 通过。
```
