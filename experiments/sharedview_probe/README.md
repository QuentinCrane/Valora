# SharedView Kit 独立验证

这是一个只用于验证官方 Android SDK 的独立应用，不属于 Valora 的发布包。它以原生 View 和 Bitmap 分别构造启动参数，并提供 Android 默认转场作参照。探针有两个原生 Activity，不能证明 SDK 能直接控制 Flutter 的同 Activity 路由，也不能代替 Valora 的性能对照。

## 取得 SDK 和构建

从 [金标联盟官方 Demo](https://gitee.com/itgsa_sharedviewkit/SharedViewDemo) 获取 SDK。以下记录基于 Demo 提交 `b449a426a340f1827d942592bddf0a416eae3ac4`，其中 `app/libs/sharedview-kit-1.0.0.5.aar` 的 SHA-256 是 `7C0937ECDE545A262619E5FA19D56A21B0AD3FD8013CBC4FE058C497808702BD`。先核对发布方的 SDK 授权说明；Demo 的 MIT 许可不自动确定独立 SDK 的授权。

从 Valora 项目根目录运行以下 PowerShell 命令，`$demoDir` 可换成已有的官方 Demo 副本：

```powershell
$demoDir = Join-Path $env:TEMP 'SharedViewDemo'
git clone https://gitee.com/itgsa_sharedviewkit/SharedViewDemo.git $demoDir
git -C $demoDir checkout b449a426a340f1827d942592bddf0a416eae3ac4
$kit = (Resolve-Path (Join-Path $demoDir 'app/libs/sharedview-kit-1.0.0.5.aar')).Path
Get-FileHash -Algorithm SHA256 -LiteralPath $kit
.\android\gradlew.bat -p experiments/sharedview_probe :app:assembleDebug "-PsharedViewAar=$kit"
```

构建需要 JDK 17 和 Android SDK Platform 35，Android SDK 路径可通过 `ANDROID_HOME` 指定。Gradle Wrapper 复用 Valora 的 `android/gradlew.bat`；该命令不修改 Valora 主应用的 Gradle 配置。SDK AAR 由调用者提供，不存入本仓库。

产物为 `experiments/sharedview_probe/app/build/outputs/apk/debug/app-debug.apk`，包名 `com.valora.sharedviewprobe`，最低 API 26；它与 Valora 使用不同包名和数据目录。只有连接到测试设备后才执行：

```powershell
adb devices -l
adb -s <设备序列号> install -r experiments/sharedview_probe/app/build/outputs/apk/debug/app-debug.apk
adb -s <设备序列号> shell am start -n com.valora.sharedviewprobe/.MainActivity
adb -s <设备序列号> logcat -s ValoraSharedViewProbe:I
```

## 设备验证

记录设备型号、系统版本、Android API、刷新率和探针显示的协议版本。分别打开 View、Bitmap 和 Android 默认转场，用按钮返回、系统返回手势完成和取消。还需检查快速返回、旋转或分屏后返回，以及截图丢失、黑屏、闪烁、落点偏移。探针会在可检测到窗口尺寸或方向改变时跳过旧返回坐标；它没有实现列表重排或滚动后的坐标刷新。

设备声明协议版本大于零仅表示 ROM 声明支持；`ActivityOptions` 非空仅表示 SDK 返回了启动参数。是否真正播放、回调是否完整、返回是否跟手，都需要结合屏幕和 `ValoraSharedViewProbe` 日志检查。构造或启动失败时探针使用 Android 默认转场。不同设备的能力和 `getViewAnimationExtras()` 可不同，不能按品牌推断支持情况。

首台测试设备的记录见 [VALIDATION.md](VALIDATION.md)。

## 性能边界

探针只能比较同一原生样例中的 View、Bitmap 和 Android 默认转场。它没有 Flutter 内容，不能用这些结果推断 Valora 的 Flutter UI 或双引擎性能。后续应用内 A/B 应固定设备、页面、数据、刷新率与采样次数，分别记录冷热启动、有效样本数、首次视觉响应、UI/raster 的 P95、掉帧、内存和系统合成；使用 Flutter profile 模式与 Perfetto FrameTimeline，并单独记录返回手势完成及取消的行为。60 Hz 和 120 Hz 的标称帧预算分别约为 16.67 ms 和 8.33 ms，实际判断仍以设备与系统帧时间线为准。
