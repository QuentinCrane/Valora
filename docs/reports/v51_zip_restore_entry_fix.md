# v51 ZIP 恢复入口修复

## 问题
v50 实际已经有 `restoreDataArchiveFromPicker(context)` 和 Android 原生 `importDataArchive`，但“备份与恢复”主面板里仍然只露出了“从系统文件选择 JSON”，导致用户从主入口看起来只能选择 JSON 恢复。

## 修复
在 `BackupManager` 顶部新增：

- 分享完整资料包 ZIP
- 从完整资料包 ZIP 恢复

同时把 JSON 入口改成更明确的“从系统文件选择 JSON（纯数据）”，避免把 JSON 恢复和 ZIP 恢复混淆。

## 相关文件
- `lib/src_parts/features_settings.dart`
- `lib/src_parts/native_services.dart` 已存在恢复实现，本版主要补入口和文案。
