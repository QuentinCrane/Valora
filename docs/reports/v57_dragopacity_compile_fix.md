# v57 编译修复

## 修复内容

v56 中 `common_widgets.dart` 被错误插入了多份 `_dragOpacity(...)` 方法。
这些方法出现在 `GlassBackButton`、`IconPickerSheet`、`SmartAssetImportBar` 等无 `style` 字段的组件里，却访问了 `widget.style`，因此编译会失败。

v57 已经保留 `_PredictiveBackBoundaryState` 内唯一正确的 `_dragOpacity(...)`，并删除其他组件中的误插入副本。

## 影响范围

- `lib/src_parts/common_widgets.dart`
- 版本号更新为 `0.57.0+57`

## 说明

这次只做编译修复，不改变 v56 的功能逻辑。
