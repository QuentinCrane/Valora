# Valora Flutter 安卓版 v7 最终加固说明

## 这轮继续精进的目标

v7 的目标不是继续堆概念，而是把项目往“更接近可编译、可运行、可长期维护”的方向推进：

1. 修复明显会影响 Dart 编译的源码问题；
2. 降低 Flutter 版本差异导致的 API 兼容风险；
3. 增强真实 App 使用时的生命周期操作闭环；
4. 增强 Vue 原项目中的图标选择、底部 Dock 动效、快照/到期提醒等体验；
5. 补强 Android 构建脚本，避免 Gradle Wrapper 缺失时直接卡死。

## 来源复核

### Vue 项目

继续保留并强化以下 Vue 项目能力：

- `AssetHome.vue`：总览、筛选、排序、三视图、空状态；
- `AssetDetail.vue`：指标、目标进度、生命周期、趋势；
- `AssetEditor.vue`：资产表单、分类、标签、目标、到期提醒、附加项目；
- `WishHome.vue` / `WishEditor.vue`：心愿清单、归档、转资产；
- `AnalyticsHome.vue`：长期价值、排行、分布、复盘；
- `SettingsHome.vue`：分类、标签、备份、主题、首页风格；
- `tokens.css`：浅蓝主色、玻璃 Dock、圆角卡片、浅/深色模式。

### APK 解包痕迹

继续只学习开发方法与产品结构：

- Flutter 本地优先；
- 本地数据库/本地存储；
- 资产、分类、标签、统计、备份、提醒、锁屏/WebView 等模块化能力；
- 不还原源码、不复制资源、不复用商业接口。

## v7 关键修正

### 1. 修复潜在 Dart 编译错误

v6 的 `models.dart` 中 `Asset.copyWith` 附近存在一个多余闭合符号风险，v7 已移除。

### 2. Flutter API 兼容加固

v6 使用 `CardThemeData`，不同 Flutter 版本可能出现主题 API 不兼容。v7 已移除这部分，项目主要使用自定义 `AppCard`，减少版本冲突。

### 3. 详情页新增快捷流转

新增 `AssetLifecycleQuickActions`：

- 服役中资产可一键标记退役；
- 非卖出资产可记录卖出价和卖出日期；
- 退役/卖出资产可恢复服役；
- 操作后自动刷新日均成本、净消耗、流转复盘和生命周期事件。

### 4. 首页新增到期提醒

新增 `DueSoonCard`：

- 自动识别临期资产；
- 显示到期日期与剩余天数；
- 点击可进入详情页处理。

### 5. 编辑页增加快捷图标选择

新增 `EmojiChoiceBar`：

- 资产编辑页可以横滑选择图标；
- 心愿编辑页也可以快速选择图标；
- 比手动输入 emoji 更接近移动端 App 的操作习惯。

### 6. 底部 Dock 动效增强

底部 Dock 增加：

- `BackdropFilter` 毛玻璃模糊；
- Tab 切换触感反馈；
- FAB 点击触感反馈。

### 7. Android 构建脚本增强

新增 `tooling/android_patch`。当 `android/gradlew` 缺失时，脚本会：

1. 执行 `flutter create --platforms=android --project-name valora_assets --org com.valora .`；
2. 重新覆盖定制 Android 配置；
3. 继续执行 `flutter pub get`、`flutter analyze`、`flutter build apk --debug`。

## 已完成的源码级检查

- Dart 文件括号、方括号、花括号平衡检查通过；
- 未发现合并冲突标记；
- 已移除 `CardThemeData`；
- 已更新 `pubspec.yaml` 到 `0.7.0+7`；
- 已更新 Android `versionCode` / `versionName`；
- zip 完整性检查通过。

## 仍需本机最终验证

当前环境没有 Flutter / Android SDK，所以还不能替你实际执行：

```bash
flutter analyze
flutter build apk --debug
```

本机一旦报错，优先检查：

1. Flutter 版本是否过旧；
2. Android SDK / JDK 17 是否配置；
3. `android/gradlew` 是否由脚本自动补齐；
4. 若 MethodChannel 报错，重新运行构建脚本让 `tooling/android_patch` 覆盖 Android 配置。
