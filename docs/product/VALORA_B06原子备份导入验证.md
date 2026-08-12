# Valora B06 原子备份导入验证

> 对应规划块：B06 — 原子备份导入
> 建议提交：`fix(backup): make archive restore validated and atomic`

## 已实现行为

- ZIP 先解压到应用私有 staging 目录，用户确认前不写入正式媒体目录
- entry 名称经过 canonical path 校验，拒绝绝对路径、盘符路径和 `..` 路径
- 限制压缩输入 50 MiB、解压总量 250 MiB、单 entry 100 MiB、entry 数 2048，超限会清理 staging
- JSON 在确认前执行 schema、主键、引用、枚举和媒体引用预检；媒体进入 staging 后记录 SHA-256
- 确认后才移动媒体并返回提交后的 JSON；Dart 恢复失败会调用原生 rollback 删除本次移动的媒体
- 成功恢复后清理提交元数据；取消、预检失败、损坏 JSON 和提交失败均不改变当前领域数据
- CSV 对 `= + - @` 公式前缀加单引号；Markdown 表格/行内内容对转义字符和换行做转义
- 旧版 `valora_backup.json`、`zhipu_backup.json` 以及历史 `*_backup.json` 文件名继续兼容

## 验证命令

```powershell
C:\Flutter\bin\flutter.bat test --no-pub test/repository/backup_import_test.dart
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
dart run tooling/format_check.dart
git diff --check
```

## 验收边界

本块已通过 Dart 侧恢复预检、失败不写入、CSV/Markdown 脱敏测试和 Android 原生编译验证。尚未在实体设备或真实文件管理器上执行 ZIP 选择、取消、媒体哈希失败、磁盘满、换机恢复及大压缩包测试；这些仍属于设备验收，不将 APK 构建结果当作端到端验证。
