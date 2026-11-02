# Flutter 共享转场实现与验证

## 覆盖范围

- 资产网格、列表、便利贴、首页提醒和分析排行中的资产入口，以及对应详情页。
- 资产详情到编辑页的图标，心愿卡片到心愿编辑页的图标。
- 图表卡片到详情页；其他没有共享元素的页面继续使用原有路由。
- 返回使用对应的 Flutter 共享元素；快速返回、来源移除以及返回手势取消均保留可用的导航与表单状态。
- 仅在完整动画模式下启用共享转场，减少动画、关闭动画和系统禁用动画沿用现有轻量路径。

当前没有将 SharedView Kit 接入正式应用，也没有提供模拟系统 SDK 的模式开关。已验证的 SDK 限制与设备结果见 [SharedView 接入可行性](SHAREDVIEW_MOTION_FEASIBILITY.md) 和 [真机验证记录](../../experiments/sharedview_probe/VALIDATION.md)。

## 验证记录

2026-11-02，使用 Flutter 3.44.8、Dart 3.12.2：

- `flutter test --no-pub test/widget/shared_motion_test.dart test/widget/form_submission_test.dart test/accessibility/adaptive_layout_test.dart test/performance/effects_motion_test.dart`：23 项通过。覆盖三种资产视图、资产编辑、心愿编辑、图表、快速返回、来源移除、取消返回时输入值和焦点恢复、减少及关闭动画。
- `flutter analyze --no-pub --no-fatal-infos`：无错误和警告；保留工程原有 493 条 info 提示。
- `flutter build apk --debug --no-pub` 和 `flutter build apk --release --no-pub`：通过。
- Android 36 x86_64 模拟器，使用独立包名 `com.valora.motionfixture` 和合成数据：验证经典外观下资产网格、列表、便利贴、资产编辑、心愿编辑、图表详情的打开和返回，以及液态外观下资产详情、资产编辑和心愿编辑的打开和返回。转场录像检查了网格卡片进入和返回；模拟器检查不是性能测量。
- 同一模拟器中安装并启动 release APK，确认 `com.valora.assets` 进入首次启动界面，未观察到启动异常。该 APK 按构建时工作区生成，其中还包含本任务开始前已存在、未提交的工作区更改。

此前连接的小米真机在本轮 Flutter 验证时已离线；上述 Flutter 结果尚不构成真机手势、流畅度或性能验收。应在设备重新连接后补充真机视觉、取消/完成预测式返回和性能测试。
