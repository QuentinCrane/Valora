# Valora B04 凭据安全与导出脱敏验证

> 对应规划块：B04 — 凭据安全存储和导出脱敏
> 建议提交：`fix(security): isolate and redact WebDAV credentials`

## 已实现行为

- `CloudSyncSettings.toMap()` 只保存 `credentialsStored`，不再写入 `username` 或 `password`
- Android 使用 Keystore 生成 AES-GCM 密钥，并将凭据密文与随机 IV 保存到独立的 SharedPreferences
- v1/v2 本地 JSON 中的旧明文凭据会在首次读取时迁移到安全存储，再重写本地 JSON 和已验证快照
- 旧版 `valora_assets_store.xml` 中的明文 JSON 迁移到 SQLite 后会被清除
- ZIP 中的 JSON、SQLite 均从递归脱敏后的 payload 生成，不包含旧数据库的 WAL/SHM 文件
- Android 自动备份与设备迁移规则排除安全凭据、旧明文偏好和 SQLite WAL/SHM；新设备需要重新输入凭据
- 设置页不回显密码，留空保存会保留现有凭据，也提供独立的清除入口

## 验证命令

```powershell
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
dart run tooling/format_check.dart
git diff --check
```

## 验收边界

本块已通过 Dart 层凭据迁移、JSON 脱敏和清除凭据测试，并通过 Android 原生编译验证。尚未连接实体设备执行真实 ZIP 分享、备份提供方扫描、换机恢复和 WebDAV 连接测试；这些属于后续设备验收，不将 APK 构建结果当作设备验证。
