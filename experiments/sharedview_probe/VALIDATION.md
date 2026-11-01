# SharedView 真机验证记录

## 测试条件

- 日期：2026-11-01
- 设备：Xiaomi 23127PN0CC，Android 16（API 36），HyperOS `OS3.0.307.0.WNCCNXM`
- 屏幕物理分辨率：1200 × 2670；系统设置的最高刷新率为 120 Hz。未测量测试时的实际刷新率。
- SDK：官方 Demo 所附 `sharedview-kit-1.0.0.5.aar`，SHA-256 `7C0937ECDE545A262619E5FA19D56A21B0AD3FD8013CBC4FE058C497808702BD`
- 官方 Demo：提交 `b449a426a340f1827d942592bddf0a416eae3ac4`。本机临时副本使用该本地 AAR、Gradle 8.14，并移除未使用的 Compose 插件和构建开关后构建 debug APK；APK SHA-256 `C1A8791EC1E5DF324EB010ACDF92AB3F64682F7EBF27AB501D6DCD9FCEBECD01`。
- 探针：使用同一 AAR。增加协议版本显示、日志及查询异常区分后重新构建，并重复回退和返回验证；测试 APK SHA-256 为 `EBC406AA57720B73A7BEFCB09AC3A5C377BC5F42054683D85716E94B11244A1D`。两个测试应用是独立包，不包含 Valora 资产数据。

## 结果

| 路径 | 观察结果 |
| --- | --- |
| 探针能力查询 | `isViewAnimationSupported()` 返回 `0`；探针显示未声明支持，并记录 `SDK capability protocol=0`，未记录查询异常。 |
| 探针 View 起点 | 因协议版本为 `0`，没有调用动画构造接口；详情页显示请求为 `view`，准备方式为 `system`。按钮返回到探针首页。 |
| 探针 Bitmap 起点 | 同样因协议版本为 `0` 提前回退；详情页显示请求为 `bitmap`，准备方式为 `system`。短距离注入滑动后详情页保持，长距离边缘滑动后返回首页。 |
| 探针系统默认 | 详情页显示请求和准备方式均为 `system`，系统返回键返回首页。 |
| 官方 Demo，View 源 | 保持“一镜到底”开关开启，点击纵向信息流卡片后进入详情；`HomePresenter` 记录 `oneshotTransition options is null, fallback to base transition`。 |
| 官方 Demo，Bitmap 源 | 启用“使用Bitmap接口”，再次点击卡片后进入详情；日志再次记录启动参数为 null 并回退。边缘滑动返回到信息流。 |

关键日志：

```text
11-01 09:47:00.749 D HomePresenter: oneshotTransition options is null, fallback to base transition
11-01 09:47:30.298 D HomePresenter: oneshotTransition options is null, fallback to base transition
11-01 09:50:59.493 I ValoraSharedViewProbe: SDK capability protocol=0
```

短滑和长滑由 ADB 注入，结果只证明观察到的页面停留与返回，不能证明预测式返回的进度或取消回调。由于 SDK 未在此设备上启用，没有获得 SharedView 动画回调、帧时间、跟手性或与 Flutter 的 A/B 结果，也没有验证 Flutter 混合宿主。结论仅适用于记录中的设备、系统构建和 SDK 版本，不能推广到其他机型或系统版本。

## 后续验证

在 `isViewAnimationSupported()` 返回正协议版本的设备上重复 View／Bitmap、返回完成／取消、快速打断和屏幕几何变化测试。确认原生 Demo 正常后，再运行 Flutter 混合宿主实验并进行同设备性能对照。
