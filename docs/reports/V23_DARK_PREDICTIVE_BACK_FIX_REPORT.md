# V23 深色模式、设置稳定性与预测返回修复说明

## 本轮目标

针对 V22 在实机测试中暴露的问题做定向修复：

1. 深色模式下 Dock / 加号的液态玻璃高光不自然；
2. 深色模式下局部文字仍然是黑色，影响阅读；
3. 设置页切换分区或切换选项时有明显跳动；
4. 预测式返回仍未表现出来；
5. 合并本地 release 编译时已经确认的 4 个编译修复。

## 已完成修改

### 1. 深色模式液态玻璃重新调校

- `_WaterDropShell` 在深色模式下不再绘制大面积白色反光块和蓝色散射光；
- 深色模式仅保留：
  - 微弱实时模糊；
  - 边缘轮廓光；
  - 顶部细光线；
  - 底部弱折射线；
- Dock thumb 的深色模式高光也同步降低，避免出现灰白色脏块。

### 2. 深色模式文字可读性修复

- `SettingsHeroCard`、`SettingsMetricPill`、`SettingRow`、首页总览金额、资产卡日均成本等位置改为根据 `context.isDark` 动态取色；
- 移除多个深色模式下仍使用 `kText` 的黑色文字点；
- Theme 的 `ColorScheme` 显式补充 `surface / onSurface / outline`，让 Material 3 组件在深色模式下更稳定。

### 3. 设置页切换不再明显跳动

- 设置页分区内容从「横向滑动 + 淡入」改为纯淡入；
- 外层增加 `AnimatedSize`，高度变化更柔和；
- `SettingsTabBar` 改为固定宽度胶囊，切换时不会因为文字宽度或阴影变化抖动；
- `MiniChoiceBar` 的每个选项改为固定宽度，避免切换时控件宽度变化导致整行跳动。

### 4. 预测式返回修复

- Android 侧继续保留：
  - `android:enableOnBackInvokedCallback="true"`；
  - `android.window.PROPERTY_ENABLE_BACK_ANIMATION=true`；
- Flutter 侧改为官方要求的：
  - `TargetPlatform.android: PredictiveBackPageTransitionsBuilder()`；
- `softRoute()` 继续使用 `MaterialPageRoute`，并包裹 `PredictiveBackBoundary` 作为 App 内兜底反馈；
- `PredictiveBackBoundary` 的触发区域从 28px 扩大到 92px，阈值降低，确保即使系统动画不明显，也能从二级页面左侧区域滑动看到 App 内预测返回反馈。

> 注意：系统级预测返回依赖 Android 13+。Android 13 / 14 还需要在开发者选项中开启 Predictive back animations；Android 15+ 默认更完整。测试时必须进入资产详情、编辑、新增等二级页面，首页根页面没有上一页，不会显示返回预测。

### 5. 合并编译修复

本轮合并你那边 release 编译时已经验证过的 4 个修复：

1. 移除 `CupertinoPageTransitionsBuilder`；
2. 将货币提示中的 `$` 改为 `\$`；
3. 删除 `native_services.dart` 中重复的 `String.take` 扩展；
4. `consumed` 相关值补 `.toDouble()`，避免 `num` 赋值给 `double`。

## 版本

- App version: `0.23.0+23`
- Android versionCode: `23`

## 建议测试流程

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --release
```

预测返回测试：

1. 使用 Android 13/14/15 真机或模拟器；
2. 开启系统手势导航；
3. Android 13/14 进入开发者选项，开启 `Predictive back animations`；
4. 打开 App，进入任一资产详情或新增页；
5. 从左边缘慢慢向右滑动；
6. 若系统动画不明显，尝试从距离左边 30~80px 的区域慢慢右滑，应能看到 App 内兜底的预测返回位移反馈。
