# VALORA B23 渐进模块化第一批验证

日期：2026-08-13

## 目标与边界

B23 只提取第一批稳定边界，不改变 UI、MethodChannel 方法名、结果 envelope 或业务模型：

- 复用已经存在的纯 Dart `lib/domain/validators.dart`
- 将原生桥接的状态、错误码、Widget 目标、进度和泛型结果移到 `lib/platform/native_bridge_contract.dart`
- `main.dart` 继续导出 domain 与 platform public API，保留现有 `part` 文件调用方式
- `lib/src_parts/native_services.dart` 只保留 MethodChannel 适配器和 UI 侧错误展示

## 变更摘要

原本 202 行契约类型位于 `native_services.dart` 的 `part` 文件中，无法被独立 platform/domain 使用，也让纯契约测试必须依赖整个 Flutter 入口。本块将这些类型原样移动到独立 library：

- `NativeBridgeStatus`
- `WidgetRefreshTarget` 与 `kAllWidgetRefreshTargets`
- `NativeBridgeErrorCode` 及 wire 映射
- `NativeBridgeError`
- `NativeOperationProgress`
- `NativeBridgeResult<T>`

兼容层只有 `main.dart` 的 import/export；现有页面仍通过 `main.dart` 访问同名 API，原生调用方法、超时、错误映射和返回值均未改动。

## 公共 API 验收

新增 `test/platform/native_bridge_contract_test.dart`，覆盖：

- Widget target 与错误码 wire name 稳定
- 平台错误大小写和未知错误码映射
- success/cancelled/failure 结果状态
- 不定长与已完成 native progress 的 fraction/terminal 语义

原有 `test/repository/native_bridge_contract_test.dart` 继续覆盖 MethodChannel envelope、取消、平台异常脱敏、类型错误、进度事件和取消操作，作为适配器回归。

## 验证记录

- 聚焦测试：`flutter test --no-pub test/platform/native_bridge_contract_test.dart test/repository/native_bridge_contract_test.dart`，13/13 通过
- 纯契约格式：`dart format --output=none --set-exit-if-changed lib/main.dart lib/platform/native_bridge_contract.dart lib/src_parts/native_services.dart test/platform/native_bridge_contract_test.dart`，formatter 后无未格式化文件
- 全量 Flutter 测试：81/81 通过（新增 3 个契约测试）
- 独立 platform contract 分析：0 issue
- 静态分析：0 error、0 warning、493 条仓库既有 info；命令因 info 按当前配置退出 1
- 格式门槛：36 个 Dart 文件检查、5 个基线文件排除、0 个改动
- `git diff --check`：通过；仅有既存的 LF/CRLF 提示
- Debug APK：`build/app/outputs/flutter-apk/app-debug.apk` 构建成功；122,478,960 bytes；LastWriteTime `2026-08-13 10:30:41`；SHA-256 `55CB1AD7A3ECCD2D40562D14A30705AC6979256EDEEF6A94E27FC3D33F4FE4E2`

测试运行中的既有日志仍包括 ListTile DecoratedBox 警告、首页 1px RenderFlex overflow 和性能基线中的 `Bad state: No element`；它们不是本块新增失败，也没有把测试结果当作设备验证。

## 后续拆分边界

本块不搬迁 `NativeBridge` 的 MethodChannel 实现，不拆分 UI feature，也不移动 models/store。下一批只能在保持此 public contract 的前提下提取一个叶子适配器或领域模块，并单独增加行为回归。
