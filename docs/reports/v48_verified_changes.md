# v48 真实改动记录

本版基于 v47 源码继续修改，重点修复：

1. 设置子页面预测式返回覆盖不完整
2. 分享数据只发 JSON，无法包含封面/贴纸图片

## 1. appSheet 改为预测返回页面

原来的 `appSheet(...)` 基于 `showModalBottomSheet`，很多设置里的详细页面（分类管理、标签管理、备份恢复、云端同步、原生功能面板等）并不经过 `softRoute`，所以预测返回效果不统一。

v48 将 `appSheet(...)` 改为：

```dart
Navigator.of(context).push(softRoute(_AppSheetRoutePage(...)))
```

这样所有通过 `appSheet` 打开的“详细子页面”都会进入 `PredictiveBackBoundary`，和普通二级页面使用同一套返回动画。

涉及文件：

- `lib/src_parts/features_asset_home.dart`

## 2. 新增完整资料包分享

原来的系统分享主要是 JSON 或 Markdown 文本，JSON 只能恢复结构化文字数据，无法携带本地封面、贴纸、手动勾勒生成图等媒体文件。

v48 新增：

- `NativeBridge.shareDataArchive(...)`
- `shareCompleteDataArchive(context)`
- Android 原生侧 `shareDataArchive(...)`

完整资料包 ZIP 包含：

- `backup/valora_backup.json`
- `backup/valora_assets.csv`
- `backup/valora_report.md`
- `sqlite/valora_assets_local.db`
- `sqlite/valora_assets_local.db-wal`（存在时）
- `sqlite/valora_assets_local.db-shm`（存在时）
- `media/` 下的本地封面、AI 贴纸、手动勾勒图等文件

涉及文件：

- `lib/src_parts/native_services.dart`
- `lib/src_parts/features_settings.dart`
- `android/app/src/main/java/com/valora/assets/MainActivity.java`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/xml/file_paths.xml`
- `android/app/build.gradle`

## 3. 备份入口文案调整

备份页现在优先显示“分享完整资料包 ZIP”，同时保留 JSON 的复制、保存、分享入口。

说明：JSON 仍然适合快速恢复纯文字数据；完整资料包更适合跨设备迁移和把图片一起带走。
