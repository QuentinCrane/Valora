# Valora B03 数据格式与时间精度验证

> 对应规划块：B03
> 建议提交：`fix(data): version persisted data and preserve timestamps`

## 数据契约

- `storageSchemaVersion`、`exportSchemaVersion`、`appVersion` 独立记录；旧 `version` 保留为兼容别名
- v1/v2 数据迁移到当前导出 schema v3，迁移函数不修改输入，重复执行结果一致
- 主键重复、引用缺失、未知枚举、非法集合和非法时间会在导入前拒绝
- 审计时间使用带 `Z` 的 ISO-8601 时间戳；购买、出售、目标等业务日期继续使用 `YYYY-MM-DD`
- 未知未来 schema 在 `importMap` 修改 Store 之前失败，不能覆盖已有数据

## 验证结果

```powershell
C:\Flutter\bin\flutter.bat test --no-pub test/repository/persisted_data_schema_test.dart
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
dart run tooling/format_check.dart
git diff --check
```

| 检查项 | 结果 |
|---|---|
| v1/v2 fixture | 通过；两种旧格式均可迁移并读入 |
| 未来 schema | 通过；导入前返回 `data_future_schema`，已有 Store 不变 |
| 幂等迁移 | 通过；同一 fixture 连续迁移两次 JSON 结果一致 |
| 主键/引用/枚举校验 | 通过；重复主键、悬空引用和未知枚举均被拒绝 |
| 同日顺序 | 通过；同一天 08:00 与 18:00 的 `updatedAt` 顺序保留 |
| 全量 Flutter 测试 | 通过；12 项全部通过 |
| Flutter 分析 | 通过；0 warning、0 error；既有 info 仍可见 |
| Android Debug 构建 | 通过；`assembleDebug` 14.8 秒 |
| 格式与差异检查 | 通过 |

Debug APK 元数据：大小 121,537,027 bytes，CreationTime 为 2026-06-18 21:43:45，LastWriteTime 为 2026-08-12 22:04:14，SHA-256 为 `515E150B51B1557B88D1E85F3B4BA1209FBE4DDBD199D03F1F5234767CD0A57C`

本块使用仓库内 JSON fixture 和 Flutter 测试替身验证数据契约，未宣称真机安装、真实数据库损坏注入或跨时区设备验证。
