# VALORA B11 原生桥接契约验证

## 目标

为 `valora/native` MethodChannel 建立版本化、类型化的 Dart/Android 返回契约，使取消、失败和成功不会再通过 `null` 或未约定的原始值混淆。

## 已完成内容

- Android 增加 `NativeBridgeContract`，统一返回 `protocolVersion = 1`、`status` 和 `data` 字段
- 原生异常统一映射为稳定错误码，并通过安全消息返回；不透传异常文本、路径、凭据或 WebDAV 细节
- Dart 增加 `NativeBridgeResult<T>`、`NativeBridgeStatus` 和 `NativeBridgeErrorCode`
- 统一处理成功、取消、权限、空间、格式、模型、超时、不可用和处理失败等结果
- 对图片选择、拍照、裁剪、条码/OCR、剪贴板、文件导入导出、分享、备份、通知、快捷方式、Widget 和系统设置等调用方改用类型化结果
- 保留旧 API 作为兼容包装；新增调用方只根据类型化结果显示成功或错误文案
- 触感和系统 UI 配置属于 best-effort 副作用，不使用业务超时，避免非阻塞调用污染 Widget 测试生命周期

## 契约边界

成功示例：

```json
{"protocolVersion":1,"status":"success","data":true}
```

取消示例：

```json
{"protocolVersion":1,"status":"cancelled","data":null}
```

失败通过 `PlatformException.code` 传递稳定错误码，Dart 侧只保留枚举化错误，不保留原生异常 message。未知错误降级为 `unknown`，错误文案由本地化 key 统一提供。

## 验证记录

- Dart 定向契约测试：5/5 通过
- 既有表单回归测试：3/3 通过
- Flutter 全量测试：49/49 通过
- Android `:app:testDebugUnitTest`：通过
- `flutter analyze --no-pub --fatal-warnings --no-fatal-infos`：退出码 0；仓库现有 492 条 info，无 warning/error
- `dart run tooling/format_check.dart`：检查 24 个 Dart 文件，0 个文件发生格式变化；排除 5 个基线文件
- `git diff --check`：通过，仅报告工作区已有的换行风格提示
- Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`
  - 构建时间：2026-08-13 01:19:39
  - 文件大小：121,663,998 bytes
  - SHA256：`A613003B6B2C974D1FBDE4275E9FCA1CD8D827A3BB9E6026FBFC85700A100CD3`

## 未覆盖范围

本块完成了契约、调用方和自动化测试验证，尚未替代真机验证。权限弹窗、空间不足、系统取消、原生模型不可用、TalkBack 文案以及真实 WebDAV/分享目标仍需在后续设备验收中覆盖。
