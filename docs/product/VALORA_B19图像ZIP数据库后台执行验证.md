# VALORA B19 图像、ZIP 和数据库后台执行验证

## 目标

将大文件复制、贴纸解码与分割、ZIP 导入导出、归档提交和本地数据库桥接从 Android 主线程移出，并建立可取消、可报告进度、结果回主线程的统一通道约定。

## 实现范围

- `MainActivity` 使用单线程 `databaseExecutor` 串行执行 SQLite、迁移和凭据存取，保持保存与校验快照的顺序
- 使用独立 `backgroundExecutor` 执行媒体复制、相机输出持久化、文本文件读写、条码/票据识别、贴纸处理和归档操作
- ZIP 仍使用 `ZipInputStream`、`ZipOutputStream` 和分块缓冲；归档媒体复制、解压、哈希和提交过程增加中断检查
- `nativeOperationProgress` 事件提供 `operationId`、操作名、状态、处理量和可选消息；`cancelNativeOperation` 支持取消已登记任务
- Activity 销毁时取消 worker、关闭 executor，并以一次性完成标记避免晚到回调重复完成 MethodChannel 结果
- Dart native bridge 为后台任务提供 5 分钟调用窗口，并解析进度事件与稳定错误码

## 验证记录

| 检查 | 结果 |
|---|---|
| B19 native bridge 专项测试 | 通过：进度事件、未知总量、取消请求 |
| Flutter 全量测试 | 通过：74/74 |
| Dart 分析 | 通过：0 error、0 warning；仓库既有 493 条 info |
| Android Java 编译 | 通过：`:app:compileDebugJavaWithJavac` |
| 格式检查 | 通过：34 个非基线 Dart 文件，0 changed |
| `git diff --check` | 通过；仅有 Git 行尾转换提示 |
| APK 新鲜度 | 通过：`build/app/outputs/flutter-apk/app-debug.apk`，2026-08-13 09:18:44，104,995,693 bytes，SHA-256 `2EB2D93EAF438E938E8FF9B58A2696030272AA77E65041E7CDDA917CED051E34` |

## 边界与限制

- 当前验证覆盖编译、Flutter 合约和主机测试，不等同于真实 Android 设备上的 UI 帧响应验证
- 贴纸分割的 ML Kit 任务由 worker 等待，像素后处理也在 worker 执行；进度事件是通道级能力，页面可按 `operationId` 选择展示或取消
- Flutter 页面销毁后的调用方仍需遵循现有 `mounted` 检查；native 侧会取消任务并保证 MethodChannel 结果最多完成一次
