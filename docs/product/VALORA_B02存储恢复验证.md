# Valora B02 存储恢复验证

> 对应规划块：B02
> 建议提交：`fix(storage): prevent load failures from becoming empty data`

## 行为边界

- 本地加载结果明确区分 `empty`、`success`、`recoverableFailure` 和 `fatalFailure`
- SQLite 桥接返回 `status`、当前 JSON 和最近一次校验成功快照，并通过结构化错误码报告读取、写入、快照保存和迁移失败
- 首次安装只创建并校验空数据快照
- JSON 解析失败、SQLite 读取异常、通道不可用时不调用 `initializeEmptyData()`，不自动保存，也不覆盖已有数据
- 存储失败页面明确进入只读恢复模式，只提供重试入口

## 测试结果

```powershell
C:\Flutter\bin\flutter.bat test --no-pub test/repository/storage_recovery_test.dart
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
```

| 检查项 | 结果 |
|---|---|
| 存储恢复焦点测试 | 通过；首次安装、损坏 JSON、SQLite 异常、通道异常 4 项全部通过 |
| 全量 Flutter 测试 | 通过；7 项全部通过 |
| Flutter 分析 | 通过；0 warning、0 error；既有 info 仍可见 |
| Android Debug 构建 | 通过；`assembleDebug` 19.0 秒 |
| 工作区差异检查 | 通过；`git diff --check` 无差异错误 |

Debug APK 元数据：大小 121,521,243 bytes，CreationTime 为 2026-06-18 21:43:45，LastWriteTime 为 2026-08-12 21:49:52，SHA-256 为 `CFFC211683353F8921BB2F50CFE05D09C8CAF62AC2E4683EA87795682B61A6C5`

本块未进行真机安装或真实 SQLite 损坏注入；四类存储故障使用 MethodChannel 测试替身覆盖，APK 构建只证明 Android 工程可编译。
