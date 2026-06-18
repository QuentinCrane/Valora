# v80 Glass / Predictive Back / Performance Fix

本次目标是恢复 v0.79 风格的干净毛玻璃、让液态玻璃统一使用光学边界与形状折射，并修复 Android 预测式返回失效和界面过渡卡顿问题。

## 修改点

1. 预测式返回
   - `buildAppTheme` 的 Android 页面转场恢复为 `PredictiveBackPageTransitionsBuilder()`。
   - `softRoute()` 从自定义 `PageRouteBuilder` 恢复为 `MaterialPageRoute`，让 Flutter 能接入 Android 系统预测式返回进度。
   - `PredictiveBackBoundary` 重新监听 `ModalRoute.animation`，只在 `AnimationStatus.reverse` 时添加轻量的页面返回视觉提示，避免 push 进入时闪动。

2. 0.79 风格毛玻璃
   - 普通小按钮继续使用轻量 `BackdropFilter`，提高到接近 0.79 的白透、干净、柔和风格。
   - 返回按钮尺寸与位置更接近 0.79，减少之前过厚、过脏的伪液态质感。

3. 液态玻璃统一参数
   - 所有 `lge.LiquidGlass` 保留 `RoundedRectangleShape(cornerRadius: ...)`。
   - 所有真实液态玻璃均使用 `LiquidGlassRefractionMode.shapeRefraction`。
   - 所有真实液态玻璃均使用 `OpticalBorder`，并将 `borderSolidity` 调整为 `0.0`，更接近你给的示例。
   - 光学边界参数向 `borderSaturation: 1.5 / ambientIntensity: 1.0` 靠拢，降低过亮、过厚、脏边的问题。

4. 过渡与滚动性能
   - 真实液态玻璃层的 `useSync` 改为 `false`，避免同步捕获压住页面动画。
   - 真实液态玻璃层的 `pixelRatio` 从 `1.0` 下调到 `.78/.80/.82`，按压交互时进一步降低到 `.68`，减少 PageView 与表单页面切换时的捕获压力。
   - Dock / Add / 保存按钮保留形状折射与光学边界，但降低折射、色散、放大强度，避免视觉过重和卡顿。

## 主要文件

- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/common_widgets.dart`
- `lib/src_parts/shell.dart`
- `lib/src_parts/features_asset_detail.dart`
- `lib/src_parts/features_asset_editor.dart`
- `lib/src_parts/features_wishes.dart`
