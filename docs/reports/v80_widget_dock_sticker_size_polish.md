# V80 小组件、Dock、贴纸与体积发布前优化

## 调研结论
- Android 12+ 小组件重点是圆角背景、可调整尺寸、widget picker 预览、目标 cell 尺寸和更高信息密度。
- 值谱当前是 Flutter + Java 原生桥结构，小组件继续使用 RemoteViews 更稳，不引入新的 Glance/Compose 运行链，避免显著增加 APK 体积和构建复杂度。
- HyperOS/MIUI 桌面更依赖紧凑卡片和白底高对比风格，因此为小米/红米/POCO/HyperOS 单独切换更紧凑的布局 XML。

## 体积优化
- 发布包默认限定 `arm64-v8a`，避免 universal APK 同时带入 32 位与 x86 原生库。
- 仅保留中文和英文资源配置。
- release 已保持 `minifyEnabled true` 与 `shrinkResources true`。
- 继续排除 META-INF license/notice/kotlin module 等非运行资源。

## 小组件升级
- 新增 `值谱｜轻量卡片` 2×1 小组件，显示总资产与日均成本。
- 所有小组件增加 Android 12+ `previewLayout`、`minResizeWidth/Height`、`maxResizeWidth/Height`。
- 所有小组件使用更统一的圆角白底/深色背景和两行信息承载。
- 快捷记录小组件从系统 Button 改成可点击 TextView，视觉更像原生卡片，体积与兼容性也更稳定。
- Java 端新增 HyperOS/MIUI 设备判断，小米/红米/POCO/HyperOS 设备使用 `*_hyperos.xml` 布局。

## 贴纸模式
- 首页贴纸模式卡片在浅色模式下统一为白色贴纸纸片。
- 倾斜角度加大但控制在轻微范围内。
- 底部阴影加强，增加贴纸悬浮感。
- 深色模式下贴纸卡片跟随卡片模式切换为暗色表面，避免白色纸片在暗色界面中过于突兀。

## Dock
- Dock 背景改成轻量高斯模糊，sigma 从 16~18 降到 8~9。
- 移除内部蓝色径向高光，只保留当前选中项的指示高亮。
- 手指按住或滑动 Dock 时，图标按距离手指的远近非线性放大，使用 `Curves.easeOutBack` 模拟 macOS Dock 弹性放大。
- 手指离开后图标回缩到正常尺寸。
