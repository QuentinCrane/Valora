# Valora v80 Liquid Glass 清晰度与白色长条修正报告

本次继续修正液态玻璃清晰度与普通毛玻璃高光观感，版本号保持不变：`0.80 / build 80 / versionCode 80 / versionName 0.80`。

## 修正原因

上一版为了降低页面切换和液态玻璃捕获成本，将 `useSync` 改为 `false`，并把部分 `LiquidGlassView.pixelRatio` 压到 `.68~.82`。这会减少实时捕获的细节量，导致折射不够清晰；同时轻量毛玻璃 fallback 中顶部高光和 Dock 内部 thumb 高光过强，在浅色背景下容易看起来像一条很长的白色横条。

## 本次处理

1. **恢复清晰优先的 LiquidGlassView 参数**
   - Shell：`pixelRatio` 调整为 `.92`，交互中 `.84`。
   - 详情页：`pixelRatio` 调整为 `.92`。
   - 保存按钮/编辑页/心愿页：常态 `.92`，按压态 `.84`。
   - `useSync` 恢复为 `true`，符合 liquid_glass_easy 对一般使用场景的推荐。

2. **增强但不过曝的折射参数**
   - 恢复更明显的 `distortion / magnification / chromaticAberration / saturation`。
   - 保留 `shapeRefraction`，折射沿圆角形状边缘走，而不是径向乱扭。
   - 保留 `RoundedRectangleShape(cornerRadius: ...)` 与 `OpticalBorder(...)`。
   - `borderSolidity` 继续保持 `0.0`，避免边界变成实体白边。

3. **修复白色长条观感**
   - 降低 `_StaticValoraGlassSurface` 顶部高光长度、厚度和透明度。
   - 降低 `_DockThumbPainter` 在液态玻璃模式下的内部白色 specular 高光。
   - 让真正的边缘高光交给 `OpticalBorder`，避免 fallback painter 和 shader 边界叠加。

4. **减少过度泛白的普通毛玻璃按钮**
   - `GlassBackButton` 的浅色模式 tint 从 `.58` 降到 `.30`。
   - Backdrop blur 从强制 `18` 降为更温和的 `8` 起步，避免整块按钮变成白膏状。

## 主要修改文件

- `lib/src_parts/common_widgets.dart`
- `lib/src_parts/shell.dart`
- `lib/src_parts/features_asset_detail.dart`
- `lib/src_parts/features_asset_editor.dart`
- `lib/src_parts/features_wishes.dart`

## 未改变

- 版本号仍是 v80。
- 预测式返回相关改动保留。
- 不加入会员、VIP、支付功能。
