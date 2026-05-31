# v61 Google Predictive Back 修正

本版重点把此前“仿预测式返回”的 Flutter 手写边缘拖拽逻辑移除，改为让 Android/Flutter 官方预测式返回链路接管。

## 为什么要改

v60 的 `PredictiveBackBoundary` 通过 `GestureDetector` 自己监听左边缘拖拽，并用 `_progress` 控制页面缩放/透明度。这种做法看起来像预测式返回，但并不是 Android Developers 文档中说的系统 Predictive Back：

- 它不使用系统返回手势进度；
- 它会和 Android 的 OnBackInvokedCallback / Flutter 的 PredictiveBackPageTransitionsBuilder 抢手势；
- 页面动画虽然自定义很多，但不是系统驱动，容易卡顿和不一致。

## v61 的真实修改

### 1. 保留 Manifest 中的官方开关

`android:enableOnBackInvokedCallback="true"` 保留在 application 和 MainActivity 上。

### 2. 保留 Flutter 主题中的官方构建器

`ThemeData.pageTransitionsTheme` 中继续使用：

```dart
TargetPlatform.android: PredictiveBackPageTransitionsBuilder()
```

### 3. softRoute 改回 MaterialPageRoute

把原来的 `PageRouteBuilder` 改为 `MaterialPageRoute`。

原因：Flutter 的 `PredictiveBackPageTransitionsBuilder` 需要 Material route 参与系统预测返回流程。自定义 `PageRouteBuilder` 虽然可以做动画，但不是 Google 的系统预测返回。

### 4. PredictiveBackBoundary 改为轻量 PopScope

删除：

- GestureDetector 边缘拖拽
- _progress
- _dragScale / _dragOpacity
- 自己触发 maybePop

现在只保留：

```dart
PopScope(canPop: true)
```

让系统返回管线自己处理手势进度。

## 说明

这版会牺牲此前那些“按页面类型自定义”的花哨动画，但换来真正的 Google/Android 预测式返回行为。系统是否展示完整预测返回动画仍取决于：

- Android 版本；
- 是否开启手势导航；
- Android 13/14 是否在开发者选项启用预测式返回动画；
- Flutter 引擎版本对 PredictiveBackPageTransitionsBuilder 的支持。
