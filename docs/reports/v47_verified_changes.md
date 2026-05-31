# v47 修改说明

本版本基于 v46 源码修改，重点处理：提示条遮挡、预测式返回覆盖不完整、震动/触感没有开关。

## 1. 应用内提示条改造
修改文件：
- `lib/src_parts/native_services.dart`
- 相关直接 `ScaffoldMessenger.showSnackBar` 调用点

改动：
- `showNativeSnack` 改为统一的 floating snackbar。
- 提示条默认上移，避开底部导航、保存按钮、底部操作区。
- 增加 `关闭` action，可主动关闭。
- 支持横向滑动关闭。
- 新提示出现前会先清除旧提示，避免堆叠。
- 多处原本直接调用 `ScaffoldMessenger.of(context).showSnackBar(...)` 的地方改为 `showNativeSnack(...)`。

## 2. 交互反馈开关
修改文件：
- `lib/src_parts/models.dart`
- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/store.dart`
- `lib/src_parts/features_settings.dart`

新增设置：
- `hapticsEnabled`：控制 App 内触感反馈。
- `nativeHapticsEnabled`：控制 Android 原生 Vibrator 调用。
- `compactSnackbars`：控制紧凑上浮提示条。

设置页新增：
- 触感反馈
- Android 原生震动
- 紧凑提示条

## 3. 预测式返回覆盖增强
修改文件：
- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/features_asset_home.dart`

改动：
- `softRoute` 统一包裹 `PredictiveBackBoundary`。
- 原先少量直接 `MaterialPageRoute` 的入口改为 `softRoute`。
- 设置页预测返回说明改为“增强”，避免误导为所有系统版本都完全相同。

## 4. 注意
系统级预测返回的最终动画仍受 Android 系统版本、手势导航和 Flutter 引擎支持影响；v47 做的是统一项目内部页面路由和自定义返回边界覆盖。
