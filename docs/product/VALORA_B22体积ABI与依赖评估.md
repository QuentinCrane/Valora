# VALORA B22 体积、ABI 与依赖评估

日期：2026-08-13

## 结论

B22 完成了可复现的 Release/AAB、ABI、资源和 ML 依赖评估，并保留 Android 7（API 24）支持。

- 保留产品默认 `arm64-v8a` 限制，不以删除功能换取 32 位或 x86 包
- 将 Flutter 内部 Logo 资源从 1254×1254、1,316,780 bytes 缩为 384×384、155,277 bytes
- 移除项目自有的 `-keep class com.google.mlkit.** { *; }` 全包规则，使用 ML Kit AAR 自带的 consumer rules
- 将 Jetifier 关闭；Release 依赖树和完整 Gradle Release 构建均验证通过
- 增加 `--split-per-abi` 的诊断构建条件，避免默认 arm64 `abiFilters` 与 Flutter split 参数冲突
- 不删除条码、中文 OCR、主体分割及其模型资产；这些能力均有原生调用链

## 实施内容

### 1. 显示尺寸与资源

`assets/images/app_icon.png` 只由 `LogoMark` 使用，最大调用尺寸为 72 logical px（启动页和错误页）。按 4×密度保留 384×384，视觉检查通过。

| 项目 | 修改前 | 修改后 | 变化 |
| --- | ---: | ---: | ---: |
| 图片尺寸 | 1254×1254 | 384×384 | 保留足够的启动/错误页密度余量 |
| PNG 文件 | 1,316,780 bytes | 155,277 bytes | -1,161,503 bytes（约 -88.2%） |

没有发现其他未引用的 Flutter asset。Android `mipmap` 图标按 mdpi 到 xxxhdpi 提供，未删除任一 launcher 或通知图标密度。

### 2. ABI 与 Android 版本边界

- `minSdk 24` 保持不变，对应 Android 7
- 普通 Release 默认通过 `ndk.abiFilters "arm64-v8a"` 生成 arm64 产品包
- 当 Flutter 传入 `-Psplit-per-abi=true` 时跳过默认过滤，允许诊断构建生成 `armeabi-v7a`、`arm64-v8a`、`x86_64` 三份比较包
- 这三份 split APK 是兼容性/体积评估产物，不代表产品默认放开 32 位或模拟器 ABI

此前直接执行 `flutter build apk --release --split-per-abi` 会因默认 arm64 filter 与 Flutter 自动注入的 ABI split 冲突而失败；条件化后已成功。

### 3. R8、ML Kit 和 Jetifier

项目使用 Release `minifyEnabled true` 与 `shrinkResources true`。ML Kit AAR 已提供生成 proto 字段、JNI native method 等必要 consumer rules；项目不再额外保留整个 `com.google.mlkit` 包，仅保留 `-dontwarn org.tensorflow.**`。

ML 能力矩阵如下：

| 能力 | 依赖 | 原生调用证据 | 决策 |
| --- | --- | --- | --- |
| 条码识别 | `com.google.mlkit:barcode-scanning:17.3.0` | `BarcodeScanning.getClient()`、`scanner.process(image)` | 保留 |
| 中文 OCR | `text-recognition:16.0.1`、`text-recognition-chinese:16.0.1` | `TextRecognition.getClient(new ChineseTextRecognizerOptions...)` | 保留 |
| 主体分割 | `play-services-mlkit-subject-segmentation:16.0.0-beta1` | `SubjectSegmentation.getClient()`、`SubjectSegmenter.process(image)` | 保留 |

AAB 中 ML Kit 模型资产共 33 个文件，压缩后约 2,332,275 bytes、未压缩约 3,392,457 bytes；这是实际能力成本，不能通过删除未引用资源规则安全裁剪。

依赖树只解析到 AndroidX，未发现 `com.android.support:*`。在 `android.enableJetifier=false` 下执行完整 `:app:assembleRelease` 成功，因此正式关闭 Jetifier。Manifest 中历史兼容的 `android.support.FILE_PROVIDER_PATHS` 元数据名称不代表仍存在 support library 依赖。

## 构建与体积证据

### AAB

底层 Gradle 定向构建命令：

```text
android/gradlew.bat :app:bundleRelease --no-daemon -Ptarget-platform=android-arm64
```

结果：`BUILD SUCCESSFUL`。

| 产物 | bytes | MiB | LastWriteTime | SHA-256 |
| --- | ---: | ---: | --- | --- |
| `build/app/outputs/bundle/release/app-release.aab` | 44,885,024 | 42.81 | 2026-08-13 10:19:44 | `60C08B3BDBD08675CF9EDD0226134A2AEBBE8B3157016AB6B335B7FC1FFECA59` |

AAB 内容检查确认 arm64 包含 `libapp.so`、`libflutter.so`、ML Kit 原生库；ML Kit 的部分通用库仍带有 v7a/x86_64 变体，这是依赖自身的 ABI 内容，不等于产品已放开这些 ABI。

Flutter size-analysis 命令：

```text
flutter build appbundle --release --analyze-size --target-platform android-arm64 --code-size-directory build/b22-size-arm64-final2 --no-pub
```

Flutter 已生成：

- `build/b22-size-arm64-final2/snapshot.arm64-v8a.json`：16,314,056 bytes
- `build/b22-size-arm64-final2/trace.arm64-v8a.json`：1,723,425 bytes

该命令最后因本机 Flutter doctor 报告缺少 Android `cmdline-tools`，在“检查 AAB 调试符号”阶段退出 1；Gradle bundle 本身成功，AAB 和 size-analysis 文件均已生成。后续若需让 Flutter CLI 以 0 退出，应补齐 Android command-line tools 并接受 SDK licenses。

### 分 ABI APK

```text
flutter build apk --release --split-per-abi --no-pub
```

| ABI | 产物 | bytes | MiB | SHA-256 |
| --- | --- | ---: | ---: | --- |
| armeabi-v7a | `app-armeabi-v7a-release.apk` | 19,084,514 | 18.20 | `CFFA82256D2C4EDAB2CB46D47FA2F7DE001AABAE11C37D0EBE2F9466B1EB5C99` |
| arm64-v8a | `app-arm64-v8a-release.apk` | 20,661,378 | 19.70 | `CF4FC9C9F90F91107D13E592FE1B1D13D734311D0C645B70470F6BC2017EEADC` |
| x86_64 | `app-x86_64-release.apk` | 21,251,573 | 20.27 | `B50053C72C230CA1BB66003F705E451AB08B1B4EF5A1656063CA0A66DF6A44B0` |

## 验证记录

- `flutter build apk --release --split-per-abi --no-pub`：三 ABI 成功
- `android/gradlew.bat :app:assembleRelease --no-daemon -Pandroid.enableJetifier=false`：成功
- `android/gradlew.bat :app:bundleRelease --no-daemon -Ptarget-platform=android-arm64`：成功
- `flutter build appbundle --release --analyze-size ...`：Gradle 成功并生成 AAB/分析文件；Flutter 收尾检查受缺少 cmdline-tools 影响而退出 1
- `flutter doctor -v`：Flutter/SDK 可用，但 Android toolchain 缺少 cmdline-tools、licenses 状态未知

## 后续限制

当前产品继续按 arm64-only 发布。若未来需要 Android 7 的 32 位设备支持，必须把它作为独立兼容性版本验证：至少覆盖 ML Kit 首次初始化、条码、中文 OCR、主体分割、备份和通知链路，不能仅凭 split APK 能生成就宣称完整支持。
