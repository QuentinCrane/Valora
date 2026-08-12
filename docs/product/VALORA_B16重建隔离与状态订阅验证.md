# VALORA B16 重建隔离与状态订阅验证

## 交付范围

- `StoreSelector<T>` 为 `AppStore` 提供可比较的选择器订阅，并在 dispose、替换 store 时解除监听
- `AppScope.read`/`readStore` 允许只读访问而不把整个页面注册为全量 Store 依赖
- `ValoraApp` 只在 `AppSettings` 身份变化时重建 `MaterialApp`，主题和语言仍保持实时更新
- Shell 的液态玻璃动画从整页 `setState` 逐帧重建改为局部 `AnimatedBuilder`；持久化状态横幅改为定向订阅
- 首页通过 `homeRevision` 订阅资产、筛选、视图和相关设置变化，并把 Store 传入卡片，避免卡片逐个注册全量依赖
- 搜索页把输入暂存到本地 controller，完成/清空时才提交 Store 更新；controller 在 dispose 中释放

## 验证结果

- `flutter test --no-pub test/performance/store_selector_test.dart`：2/2 通过
- `flutter test --no-pub test/performance/performance_baseline_test.dart`：4/4 通过
- `flutter test --no-pub`：全套通过
- `flutter test --no-pub test/performance/performance_application_baseline_test.dart`：1/1 通过；JSONL 仍保留宿主页面已有框架诊断字段
- `flutter analyze --no-pub --fatal-warnings --no-fatal-infos`：0 error、0 warning，既有 info 493 条
- `dart run tooling/format_check.dart`：32 个 Dart 文件通过
- `git diff --check`：通过

本阶段未宣称设备级 UI/raster p95 改善；Android 设备采集仍按 B15 harness 契约执行。APK 新鲜构建与性能前后数据锁定留待后续列表懒加载和设备基准阶段。
