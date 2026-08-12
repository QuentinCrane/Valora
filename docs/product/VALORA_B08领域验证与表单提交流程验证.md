# VALORA B08：领域验证与表单提交流程验证

## 目标

让资产、心愿、快速创建、价值回收和分类/标签写入使用同一组可测试的领域规则：

- 金额必须是有限值，默认不得为负
- 名称不能为空；购买日不得晚于今天
- 到期日、售出日和退役日不得早于购买日，也不得晚于今天
- 售出/退役状态需要对应生命周期日期
- 附加项沿用金额、名称和日期边界
- 价值回收必须引用现有资产，并落在引用资产的生命周期内
- 三类保存入口使用 busy guard，保存期间重复点击不会创建重复实体
- 新标签与主资产/心愿通过同一内存快照提交，保存失败时回滚两者

## 实现位置

- `lib/domain/validators.dart`
  - 纯 Dart 的 `Asset`、`Wish`、`Recovery`、`Addon`、`label` validator
  - 使用结构化 `DomainIssue` 和 `DomainValidationException`，UI 只翻译错误 key
- `lib/src_parts/store.dart`
  - `upsertAsset`、`upsertWish`、`upsertCategory`、`upsertTag` 和 `addRecoveryRecord` 增加领域校验
  - 增加带标签名称的原子式提交入口；写入失败恢复原有列表快照
- `lib/src_parts/features_asset_editor.dart`
  - 资产编辑页 busy guard、统一错误提示和标签事务入口
- `lib/src_parts/features_wishes.dart`
  - 快速创建与心愿编辑页 busy guard、统一错误提示和标签事务入口
  - 修复心愿编辑页归档开关的 Material 层级告警
- `lib/src_parts/l10n.dart`
  - 增加领域校验错误 key 的简体中文/英文文案
- `test/domain/validators_test.dart`
  - 有效输入、金额/未来日期、生命周期日期和回收边界的表驱动单元测试
- `test/widget/form_submission_test.dart`
  - 资产编辑双击只创建一条资产；快速创建资产和心愿编辑均走共享保存入口

## 验证结果

执行目录：`E:\Github Program\Valora\valora_app`

```text
flutter test --no-pub test/domain/validators_test.dart
                                         5/5 通过
flutter test --no-pub test/widget/form_submission_test.dart
                                         3/3 通过
flutter test --no-pub                    34/34 通过
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
                                         退出码 0；502 条既有 info，0 warning/error
dart run tooling/format_check.dart       20 个文件通过，0 变更；5 个基线排除
git diff --check                         通过（features_wishes.dart 有 CRLF 提示）
flutter build apk --debug --no-pub       通过
```

最终 B08 APK：

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 最后写入时间：`2026-08-12 23:51:58`
- 大小：`121625769` bytes
- SHA-256：`08477BEA36C8B87DED413251323CF94A460A2ECD2501E528AA9B05DA0ADEB322`
- 构建结果只证明 APK 编译，不等同于真实设备验收

## 边界

本块已验证纯 Dart 领域规则、三个 Flutter 表单入口、内存保存回滚路径和 APK 编译。尚未进行真实 Android 设备上的连续点击、键盘/无障碍交互、长时间保存失败恢复和真实数据库故障注入；这些属于后续设备验收与数据层测试，不把 widget test 或 APK 构建结果写成设备验证。
