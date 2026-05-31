# v73 真实界面新手教程与编译兜底修复

## 真实界面新手教程

- 重写新手教程为真实 App 页面上的遮罩式引导。
- 教程底层直接渲染首页、分析页、设置页和底部 Dock，不再使用单独的说明卡片页。
- 每一步使用暗色遮罩、透明挖孔、高亮描边和说明气泡指向真实界面区域。
- 设置页“新手教程”入口仍可重新播放教程。

## 设置二级菜单动画修复

- 修正 `PredictiveBackBoundary` 的动画判断。
- v72 中 `animation.value < .999` 会把页面进入动画误判为返回动画，导致二级菜单进入时列表项/页面内容看起来闪一下。
- v73 改为仅在 `AnimationStatus.reverse` 时应用预测式返回视觉层，进入二级菜单时不再闪动。

## 小字说明展示修复

- 设置项 `SettingRow.description` 不再固定 `maxLines: 1 + ellipsis`。
- 改为自然折行完整显示，避免长说明被直接省略。
- 首页资产卡片副信息不再强制省略，金额与已使用天数可折行完整显示。

## 编译问题同步兜底

保留并固化了上一轮遇到的编译修复：

1. `android/app/build.gradle` 删除 `splits { abi { ... } }`，避免 ABI 配置冲突。
2. `lib/src_parts/common_widgets.dart` 中 `radialGradient` 改为 `gradient`。
3. 绘图相关 `math.max(..., 1)` 的 double 场景改为 `1.0`。
4. `android/app/src/main/res/values/styles.xml` 移除无效 `textColor` 属性。
5. `MainActivity.java` 日期正则使用 `\\d`。
6. `forceBlueMaterialDatePicker` 不再调用 Material 1.14.0 已移除的 `addOnShowListener`。

## 版本号

- pubspec: `0.73.0+73`
- Android: `versionCode 73`, `versionName 0.73.0`
