# Valora B05 保存串行化与持久化状态验证

> 对应规划块：B05 — 保存串行化与 UI 持久化状态
> 建议提交：`fix(storage): serialize and surface persistence operations`

## 已实现行为

- `SaveCoordinator` 在保存入口先分配单调递增 revision 和不可变 JSON 快照，再按队列顺序写入
- CRUD 请求不合并；设置类请求只合并尚未开始写入的连续排队项
- 每次写入仍执行保存、重新读取比对和校验快照，较旧的 coalesced waiter 不会覆盖最新持久化状态
- `persistenceState` 提供 `idle`、`saving`、`saved`、`failed` 状态以及当前/已持久化 revision
- 主 Shell 在保存中显示状态，在失败时提供“重试保存”；重试会以当前完整领域快照重新排队
- 搜索、筛选、排序、愿望归档筛选等展示态不写入 `exportMap()`
- 自动上传只由最终成功持久化的最新 revision 触发，避免设置请求合并后重复上传

## 验证命令

```powershell
C:\Flutter\bin\flutter.bat test --no-pub test/repository/persistence_coordinator_test.dart
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
dart run tooling/format_check.dart
git diff --check
```

## 验证结果

- 协调器专项测试：4/4 通过
- 全套 Flutter 测试：23/23 通过
- 静态分析：0 warning、0 error；已有 info 保持在基线范围
- 格式检查：15 个 Dart 文件检查，5 个既有基线文件排除，无文件被重新格式化
- 本块不宣称实体设备验证；APK 构建只证明当前 Android 工程可编译
