# Valora SharedView Kit 可行性与接入顺序

核对日期：2026-11-01。官方 [SharedViewDemo](https://gitee.com/itgsa_sharedviewkit/SharedViewDemo) 提交 `b449a426a340f1827d942592bddf0a416eae3ac4` 包含 SDK 1.0.0.5 的 AAR。SDK 源码未开放；Demo 的 `NOTICE` 说明 SDK 是独立产物，授权以 SDK 发布说明为准。Demo 提供的仓库地址为 HTTP，且 README 描述的本地 AAR 开关在该提交的构建脚本中被注释；实际复现应固定已核对的产物，不在 Valora 的正式构建中引入不安全的动态依赖。

## 已确认的接口与约束

- `ViewAnimationManager.isViewAnimationSupported()` 返回 ROM 声明的协议版本；大于零表示设备声明支持，零表示不支持。
- `makeViewAnimationOptions` 接收 Android `View`，或 `Bitmap`、`Rect` 和像素圆角，返回用于启动 Activity 的 `ActivityOptions`。示例使用 `startActivity(intent, options.toBundle())`。
- `overrideViewAnimationTransition` 接收即将退出的 Activity 和参数；返回前可以更新坐标。扩展参数和坐标系应由 `getViewAnimationExtras()` 判断。
- 回调仅报告开始、结束、取消和打开／返回方向，不能单独证明具体动画类型或手势连续性。
- AAR 清单要求 `minSdkVersion=26`；当前 Valora 的 `minSdk` 为 24。直接增加该依赖会遇到清单合并冲突，不能为了 SDK 悄然提高 Valora 最低系统版本。
- 官方公开的示例和 API 以跨 Activity 转场为中心；它们没有提供 Flutter 同 Activity 路由接入示例，也没有公开让 Flutter 驱动返回手势进度的接口。不能据此断言同 Activity 方案可行或不可行。

Valora 的资产列表和详情目前是同一 Flutter Activity 内的路由；`softRoute` 使用 `MaterialPageRoute`，Android 主题使用 `PredictiveBackPageTransitionsBuilder`。现有 `MotionMode` 控制完整、减少或关闭动画，需继续优先服从系统关闭动画设置。Flutter 多引擎各自拥有独立状态与导航栈；同一引擎在 Activity 间转移也涉及宿主和插件生命周期。参考 [Flutter 多引擎文档](https://docs.flutter.dev/add-to-app/multiple-flutters) 和 [ActivityControlSurface](https://api.flutter.dev/javadoc/io/flutter/embedding/engine/plugins/activity/ActivityControlSurface.html)。

## 当前验证成果与边界

`experiments/sharedview_probe` 是独立的 API 26+ 原生应用，使用调用者提供的官方 AAR。它提供 View／Bitmap 起点、能力查询、返回坐标及 Android 默认转场，记录 SDK 回调；具体构建和设备操作见该目录的 README。这个探针不连接 Valora Flutter 页面，不能证明 Flutter 页面、预测式返回、应用数据同步或性能通过验收。

2026-11-01 的本机验证：探针使用 1.0.0.5 AAR 和 Gradle 8.14 离线完成 debug 构建，APK 的 minSdk 为 26。官方 Demo 首次联网构建因 Kotlin Compose 编译器下载时 TLS 握手失败而中止；在临时副本中改为本地 AAR、复用本机 Gradle 8.14、去掉示例未使用的 Compose 插件和构建开关后，debug 构建成功。未修改或复制 SDK 源码。

随后在一台 Xiaomi 23127PN0CC、Android 16／HyperOS `OS3.0.307.0.WNCCNXM` 手机上运行：探针能力查询返回协议版本 `0`；官方 Demo 的 View 和 Bitmap 构造接口均返回空启动参数并回退。具体操作、日志和证据边界见 [真机验证记录](../../experiments/sharedview_probe/VALIDATION.md)。该结果不代表其他设备或系统版本，也不能证明 Flutter 混合宿主可行。

下一步首先在支持设备上运行官方 Demo 和探针，再制作隔离的 Flutter 混合宿主实验，比较至少以下方案：

1. 复用 FlutterEngine，在两个 Activity 间转移宿主；验证返回时原页面的渲染表面、路由、插件和 Activity 生命周期。
2. 使用 `FlutterEngineGroup` 的独立引擎承载详情；验证资产状态同步、修改／删除、返回、内存和首帧延迟。

这两种方案均需证明源和目标可见、无黑屏、回调及返回取消状态正确，再决定是否适合进入 Valora。截图起点必须同时考虑捕获／传输成本、屏幕与窗口坐标、密度、裁切、旋转、列表滚动和源项消失。

## 计划中的 Motion Engine 契约

- 将用户选择的“智能自动／系统增强／Flutter 标准”和既有动画强度设置分开保存。系统增强是优先尝试，不能跳过能力、准备和可访问性检查；关闭动画优先于所有引擎。
- 原生适配器独立报告 SDK 是否集成、API 是否满足、协议版本、场景和宿主是否可用；设备声明支持不等于 Flutter 场景已准备好。
- 每次点击只在导航前选择一次执行方。仅在原生会话所需的宿主、起点、返回路径均已准备时启动原生；否则使用现有 Flutter 路由。不要同时启动 Hero 和 SDK 来控制同一转场。
- 会话持有资产 ID 和有效的源坐标，协调完成、取消、退出及源项失效；无法安全返回原位置时使用经过验证的回退。切换设置不改变正在执行的会话。
- 先仅覆盖资产卡片到详情的往返，覆盖列表、卡片和便利贴及其各自坐标；其他资产入口保持可用。再考虑扩展到心愿和图表。

当前主应用尚未接入 SDK，也没有提供会让人误以为已可切换的双引擎开关。待 Flutter 混合宿主、授权和真机验证完成后，才实现适配器和设置，进行同设备 profile A/B；在此之前不能声称系统增强已生效或更快。
