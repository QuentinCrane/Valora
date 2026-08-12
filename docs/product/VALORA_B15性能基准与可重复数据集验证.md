# VALORA B15 性能基准与可重复数据集验证

## 交付范围

- `lib/performance_dataset.dart` 提供固定随机种子的空、小、中、大四档数据集，覆盖资产、媒体占位元数据、分类、标签、心愿和归档填充目标
- `lib/performance_metrics.dart` 提供 p50、p95、max 汇总以及 JSONL 记录模型
- `tooling/performance_dataset.dart` 生成数据集 JSON 与 manifest
- `tooling/performance_report.dart` 将 JSONL 基准记录汇总为 Markdown 表格
- `integration_test/performance_baseline_test.dart` 提供可复用的场景采集 harness；`test/performance/performance_application_baseline_test.dart` 提供宿主 Flutter 测试入口
- `integration_test/PERFORMANCE_BASELINE.md` 记录 Android 设备适配要求与运行方式

## 已覆盖场景

宿主 harness 覆盖冷启动、首页列表/网格/贴纸滚动、连续搜索与清空、主 Tab 往返、分析页滚动、设置滑杆、资产修改/删除/恢复/保存、归档导入和贴纸参数调整。记录 wall/UI/raster 时间、帧数、超预算帧数、RSS 前后值以及框架诊断计数。

宿主 Flutter 测试使用固定次数的交互动作，便于在无 Android 设备时验证采集链路；真正的 30 秒滚动、启动 p50/p95、GC、build/layout/paint 分解和 Android UI/raster 帧时序，仍需按 `integration_test/PERFORMANCE_BASELINE.md` 接入设备适配器后采集。

## 验证结果

- `flutter test --no-pub test/performance/performance_baseline_test.dart`：4/4 通过
- `flutter test --no-pub test/performance/performance_application_baseline_test.dart`：1/1 通过；宿主运行会记录当前页面已有的框架诊断，不把这些诊断静默当作性能优化结果
- `dart run tooling/performance_dataset.dart --scale=small --archive-bytes=262144`：通过，生成 256 KiB 以上数据集与 manifest
- `dart run tooling/performance_report.dart --input=test/fixtures/performance/sample.jsonl`：通过，生成 Markdown 汇总

## 已知边界

当前环境没有可用 Android 设备；同时没有引入 `integration_test` 依赖，以免离线 APK 构建被未缓存的 AndroidX runner 依赖阻断。因此本提交提供的是可重复数据集、报表工具和宿主采集链路，不宣称已经完成设备级性能基线。
