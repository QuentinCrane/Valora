# VALORA B10：恢复、删除、撤销交互验证

## 目标

让危险动作在执行前可预知、执行后可恢复，并保证取消、重复点击和辅助功能读取路径稳定：

- 资产、心愿、分类、标签、快照和清空数据统一使用带影响摘要的 destructive action sheet
- 删除动作保存完整数据快照，Undo 一次性恢复资产、心愿、分类、标签和价值回收记录的关系
- 删除和清空操作在 Store 层串行化，重复请求不会重复提交
- 文本 JSON、快照和云端恢复在覆盖前创建本地快照；ZIP 恢复沿用已有预快照流程
- 快照列表点击先展示只读内容预览，损坏快照不可直接恢复
- action sheet 使用 `Semantics` 容器、明确按钮文本和“取消不会改变任何数据”提示

## 实现位置

- `lib/src_parts/store.dart`
  - 增加 `DestructiveImpact`、`SnapshotPreview`、删除影响统计和快照预览解析
  - 增加一次性 Undo payload、重复操作锁、删除包装方法和清空数据恢复入口
  - `restoreFromJson` 支持恢复前自动快照，并保留省略 snapshots 字段的快照历史
  - 云端非静默覆盖恢复前自动创建本地快照
- `lib/src_parts/native_services.dart`
  - 增加统一 destructive action sheet、Undo SnackBar 和影响摘要格式化
  - 系统 JSON 恢复改为走恢复前快照路径
- `lib/src_parts/features_asset_detail.dart`
  - 资产删除改为影响摘要确认、删除后 Undo
- `lib/src_parts/features_wishes.dart`
  - 心愿删除改为影响摘要确认、删除后 Undo
- `lib/src_parts/features_settings.dart`
  - 分类、标签、快照和清空数据接入确认与 Undo
  - 快照条目改为预览后恢复；JSON 覆盖恢复复用系统恢复入口
- `lib/src_parts/l10n.dart`
  - 增加 Undo、影响摘要、预览和不可恢复状态的中英文文案
- `test/repository/destructive_actions_test.dart`
  - 覆盖关系完整 Undo、重复删除只提交一次、恢复前快照和快照预览
- `test/widget/destructive_actions_test.dart`
  - 覆盖 action sheet 的可读标签、影响摘要和取消无副作用

## 验证结果

执行目录：`E:\Github Program\Valora\valora_app`

```text
flutter test --no-pub test/repository/destructive_actions_test.dart test/widget/destructive_actions_test.dart
                                         4/4 通过
flutter test --no-pub                    43/43 通过
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
                                         退出码 0；504 条既有 info，0 warning/error
dart run tooling/format_check.dart       23 个文件通过，0 变更；5 个基线排除
git diff --check                         通过
flutter build apk --debug --no-pub       通过
```

最终 B10 APK：

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 最后写入时间：`2026-08-13 00:42:58`
- 大小：`121649340` bytes
- SHA-256：`0A04322201FC2A8EBAEA3C10A9BC2687524BEDE162E00E6C93B2CFAE4F046B97`

## 边界

本块验证了 Store 数据恢复、Flutter action sheet 和 APK 编译路径，未进行真实 Android 设备上的 TalkBack 朗读、系统返回手势、跨进程恢复或长时间 Snackbar 操作验收。设备与性能验收保留到后续规划块。
