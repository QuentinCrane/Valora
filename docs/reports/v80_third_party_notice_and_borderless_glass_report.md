# Valora v80 第三方声明与普通毛玻璃无外框修正报告

本次继续整理 v0.80 发布前文档与普通毛玻璃视觉，版本号保持不变：`0.80 / build 80 / versionCode 80 / versionName 0.80`。

## 修改目标

1. 在仓库与 GitHub Release 文档中加入第三方开源声明，明确 `liquid_glass_easy` 的使用用途和归属。
2. 只移除普通毛玻璃组件的边缘外圈高亮外框，不调整真实液态玻璃的 `OpticalBorder`、形状折射、折射强度或捕获清晰度参数。

## 第三方声明新增

- 路径：`THIRD_PARTY_NOTICES.md`、`docs/v80_github_release_notes.md`。
- 内容包含：
  - `liquid_glass_easy` 组件名称。
  - 用途说明：实时液态玻璃、背景捕获、形状折射、模糊、动态镜片与 Optical Border 光学边界。
  - pub.dev 页面地址：`https://pub.dev/packages/liquid_glass_easy`。
  - MIT 许可与版权归属说明。

## 普通毛玻璃外框处理

本次只处理普通毛玻璃 / fallback glass：

- `_StaticValoraGlassSurface` 不再绘制外圈高亮框、内圈描边、顶部 specular 条和底部反光条。
- 经典毛玻璃 Dock 胶囊移除额外白色描边和浅色外发光，只保留轻微阴影用于层级感。
- 首页顶部搜索/筛选毛玻璃胶囊移除白色外框。
- 首次教程提示弹窗、教程说明气泡等 BackdropFilter 毛玻璃容器移除白色外框。

## 未改动

- 未修改 `LiquidGlass` 真液态玻璃组件。
- 未移除 `OpticalBorder`。
- 未调整 `shapeRefraction`。
- 未调整 `LiquidGlassView.pixelRatio / useSync`。
- 未加入会员、VIP 或支付功能。

## 主要修改文件

- `lib/src_parts/common_widgets.dart`
- `lib/src_parts/shell.dart`
- `lib/src_parts/features_asset_home.dart`
- `THIRD_PARTY_NOTICES.md`
- `README.md`
- `docs/guides/OPEN_SOURCE_RELEASE.md`
