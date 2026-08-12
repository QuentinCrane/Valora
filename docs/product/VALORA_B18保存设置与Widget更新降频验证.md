# VALORA B18 保存、设置和 Widget 更新降频验证

## 交付范围

- `SettingSliderRow` 使用本地 draft 值，拖动过程中只更新当前控件，`onChangeEnd` 才提交设置
- `AppStore.updateSettings` 对序列化后没有变化的设置直接去重，不产生持久化 revision
- 设置变更先更新内存和 UI，再进入已有的 `SaveCoordinator`；连续设置保存仍按 settings 队列合并
- 设置持久化按 revision 合并受影响的 Widget 集合，避免前一个设置变更在队列合并时丢失刷新目标
- Android `updateHomeWidget` 支持目标列表，只写入相关 SharedPreferences 字段并更新相关 provider；CRUD 仍刷新全部 Widget
- 手动刷新桌面小组件显式使用全量目标集合

## 验证结果

| 检查 | 结果 |
| --- | --- |
| B18 针对性测试 | 通过：滑杆松手后才提交、设置目标筛选、Widget 通道目标列表、保存队列和设置去重 |
| `flutter test --no-pub` | 70/70 通过 |
| `flutter analyze --no-pub --fatal-warnings --no-fatal-infos` | 0 error、0 warning，既有 info 493 条 |
| Dart 格式检查 | 34 个 Dart 文件通过，0 个变更 |
| `git diff --check` | 通过（仅有 Git 的换行提示） |
| Debug APK 新鲜构建与哈希 | `2026-08-13 04:54:29`，121,698,915 bytes，SHA-256 `77D34E38B30639491927D5D045D3178C06D1E44760B7B4926EA1C422B8A4A18B` |

## 边界

本块验证的是 Flutter 测试环境中的保存/设置/通道契约和 Android 编译路径，不等同于真机上拖动滑杆、桌面 Widget 更新次数或主线程耗时的实测。B19 再处理图片、ZIP 和数据库重任务的后台执行；本块未声称设备级性能结论。APK 构建成功，但未进行设备安装或真机交互验证。
