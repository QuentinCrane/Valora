# VALORA B28 本机数据引用救援验证

## 结论

`0.80.2+82` 是对 `0.80.1+81` 的同签名更新版本，针对本机启动时的 `data_invalid_reference` 增加了兼容救援路径。

## 问题原因

本地 SQLite 中保存的 JSON 仍然存在，但某些资产、心愿或价值回收记录引用了已经不存在的分类、标签或资产 ID。原实现对本机启动和外部导入使用同一套严格校验，因此启动会进入只读恢复页。

## 修复边界

- 仅对本机启动读取的旧 payload 启用救援。
- 保留资产、心愿和价值回收记录本身。
- 仅移除失效的 `categoryId`、`tagIds`、`convertedAssetId` 和 `assetIds` 关系。
- 外部 JSON / ZIP 导入仍保持严格校验，不自动篡改用户选择的备份。
- 救援后不自动覆盖 SQLite 原始 payload，用户可以先进入应用导出完整备份；之后的正常保存会持久化修复结果。
- 救援成功后跳过启动时自动云端拉取，避免云端旧备份覆盖刚恢复的本机内容。

## 验证

- 定向存储/schema 测试：11/11 通过。
- 全量 Flutter 测试：93/93 通过。
- 格式检查：45 个 Dart 文件，0 个变化。
- 供应链检查：7 个直接依赖声明、27 个 hosted packages，通过。
- `flutter analyze --no-pub`：0 error、0 warning、493 info（仓库既有 info）。
- Release APK：arm64-v8a，`versionCode 82`，同一 Release 证书 SHA-256 为 `EE7146F09C201A4F82FB303215785A19D915FDF04B2CDE692BA5704DE13ACB90`。
- APK 路径：`build/app/outputs/flutter-apk/app-release.apk`。
- APK 大小：`32,908,229` bytes；生成时间：`2026-08-13 12:37:19 +08:00`；SHA-256：`43179288577FF2BCB7F2669BBC455C1A74F184048EFC5BBF147AA93029E61CCC`。

## 用户操作

1. 不要卸载当前应用，不要清除应用数据。
2. 安装 `0.80.2+82` 同签名 APK，选择覆盖安装。
3. 首次启动成功后，立即进入设置导出 ZIP 完整资料包。
4. 确认资料完整后，再进行一次正常保存，让修复后的数据写回本机。

本次未连接 Android 真机，APK 安装和实际恢复仍需在用户设备上验证。
