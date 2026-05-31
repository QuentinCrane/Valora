# V16 Predictive Back + Liquid Glass + Typography Report

本轮针对用户反馈继续修正，不新增 mock 数据，不改变核心业务结构。

## 1. 预测式返回

- `AndroidManifest.xml` 中在 `application` 和 `MainActivity` 两层都保留 / 增加 `android:enableOnBackInvokedCallback="true"`。
- Flutter 侧新增 `PredictiveBackBoundary`：从屏幕左边缘右滑时，当前页面会产生位移、缩放、圆角和返回提示，从而在 Flutter 层提供可见的预测式返回反馈。
- `softRoute()` 改为 opaque 的 `PageRouteBuilder`，统一把子页面包进 `PredictiveBackBoundary`，避免透明 route 导致页面叠影。

## 2. 页面切换重叠修复

- 主 Shell 保持 `PageView`，增加 `clipBehavior: Clip.hardEdge`、`pageSnapping: true`、`allowImplicitScrolling: false`。
- 子页面 route 使用 opaque 背景包裹，降低切换时底层页面穿透和重叠的概率。

## 3. 液态玻璃底部 Dock 重做

- Dock 重新调高模糊半径：`sigmaX / sigmaY = 58`。
- 背景改为多层透明渐变、径向高光、白色边框和品牌蓝轻色散。
- 右下角加号从黑色实心圆改为独立 `GlassAddButton`，使用 `BackdropFilter + 半透明渐变 + 高光 + 触摸缩放`。
- Dock 保留横向滑动切换 Tab，阈值降低，交互更轻。

## 4. 首页顶部卡片蓝色回归

- `AssetOverviewCard` 从纯白卡片改为轻蓝渐变卡片。
- 蓝色来源使用 `#7CC6F2` 体系，卡片整体仍保持白色基调，但顶部氛围更接近应用主色。

## 5. 字体体系减重

- 全项目去掉 `FontWeight.w700 / w800 / w900 / bold`。
- 主标题、卡片标题、按钮文案统一降到 `w500`。
- 大号数字和页面标题进一步缩小，减少“粗黑微软雅黑”的观感。
- 继续使用 Apple 风格优先 fallback：`.SF Pro Text / SF Pro Text / PingFang SC / SF Pro Display / Noto Sans CJK SC ...`。

## 6. 选项卡 / 弹层圆角化

- `appSheet()` 改成圆角 34 的毛玻璃弹层。
- `PopupMenuButton` 增加圆角 shape 和无阴影样式。
- 全局 Material 3 菜单、弹窗、底部弹层继续保持大圆角风格。

## 7. 构建说明

未在当前环境实际运行 Flutter SDK，请在本地执行：

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

预测式返回的系统级动画需要：

- Android 13+ / Android 14+；
- 手势导航模式；
- 较新的 Flutter / Android Gradle Plugin；
- `enableOnBackInvokedCallback` 已开启。

如果系统级预测返回仍不明显，Flutter 层 `PredictiveBackBoundary` 已提供边缘右滑的可见预测返回效果。
