# V14 Material Motion & Icon 精修报告

本轮基于 v13 继续修正用户反馈中的交互、动画、图表和图标问题。

## 1. Material 3 圆角组件统一

- 全局继续启用 `useMaterial3: true`。
- 新增全局圆角化主题：`DropdownMenuThemeData`、`MenuThemeData`、`PopupMenuThemeData`、`DialogThemeData`、`BottomSheetThemeData`、`SnackBarThemeData`、`SwitchThemeData`。
- 资产编辑页和心愿编辑页不再使用原生矩形感较强的 `DropdownButtonFormField`，改为自定义 `RoundedSelectField`。
- 分类、状态、目标模式等展开选项改为圆角底部弹层 + 圆角选项卡。

## 2. 首页数字刷新与触感

- 首页资产总览中的金额继续保留翻转/滚动效果。
- `RollingMoney` 增加分段式轻触感反馈，在数字滚动过程中伴随细腻震动。
- 总资产、日均成本数字块可点击，点击后以 SnackBar 展示当前数值。
- 服役、退役、卖出进度条可点击，直接切换状态筛选。

## 3. 折线图视觉升级

- 日均成本趋势和长期价值趋势改为平滑曲线。
- 曲线底部新增由主色渐变到透明的面积填充。
- 曲线本身增加双色渐变，整体更接近现代移动端数据卡片风格。

## 4. 页面切换重叠修复

- 首页、心愿、分析、设置之间从 `AnimatedSwitcher` 改为 `PageView`。
- 避免页面淡入淡出时旧页面和新页面同时重叠的问题。
- 支持左右滑动切换主 Tab。

## 5. 底部 Dock 滑动选择

- 底部液态玻璃 Dock 支持横向滑动切换 Tab。
- 仍保留点击切换。
- 滑动切换和页面切换都加入轻触感反馈。

## 6. App Icon

- 已将当前可访问的用户参考图片生成 Android launcher icon：
  - `mipmap-mdpi/ic_launcher.png`
  - `mipmap-hdpi/ic_launcher.png`
  - `mipmap-xhdpi/ic_launcher.png`
  - `mipmap-xxhdpi/ic_launcher.png`
  - `mipmap-xxxhdpi/ic_launcher.png`
- Manifest 已切换到 `@mipmap/ic_launcher` 与 `@mipmap/ic_launcher_round`。
- 源图副本位于 `docs/assets/app_icon_source_512.png`。

如果最终你希望使用另一张单独的 icon 图，请替换 `docs/assets/app_icon_source_512.png` 后重新生成 mipmap 图标。

## 7. 版本

- Flutter 版本号：`0.14.0+14`
- Android `versionCode`: `14`
- Android `versionName`: `0.14.0`

## 本地验证建议

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```
