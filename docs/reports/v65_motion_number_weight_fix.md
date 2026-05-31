# v65 动画曲线与数字字重修正

## 动画曲线

v64 的场景化预测返回视觉层使用了比较强的 `easeOutCubic` 与较大的缩放/位移量，叠加官方预测返回本身的过渡后，会显得“弹上来慢”和拖拽发黏。

v65 改为：
- 场景化视觉层使用接近线性的进度，不再额外套一层强 easeOut；
- 减小详情页缩放、弹层下沉、设置页侧移等幅度；
- 降低蓝色焦点光晕和透明度变化强度；
- 继续保留官方 `PredictiveBackPageTransitionsBuilder` 和 `MaterialPageRoute`，不抢系统返回手势。

## 数字字重

按需求保留首页资产总览两个金额数字的粗体效果；资产详情页、分析页中的指标数字改为常规字重，避免页面里到处都是粗体数字。

修改文件：
- `lib/src_parts/common_widgets.dart`
- `lib/src_parts/features_asset_detail.dart`
- `lib/src_parts/features_analytics.dart`
