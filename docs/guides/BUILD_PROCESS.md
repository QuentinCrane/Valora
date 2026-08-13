# Flutter 构建流程与问题记录

本文档描述当前 `0.80.2+82` 的构建入口。旧版 ABI 冲突、Dart 类型和字符串编码问题属于历史修复记录，不再作为当前构建配置示例。

## 环境

- Flutter stable；项目约束见 `pubspec.yaml`
- JDK 17
- Android SDK / Android Studio；正式 Flutter AAB 命令需要可用的 Android `cmdline-tools`
- Gradle Wrapper 8.14
- Android 最低版本 API 24；普通 Release 默认 arm64-v8a

在仓库根目录执行：

```bash
flutter doctor -v
flutter --version
flutter pub get
```

## 日常 Debug 验证

```bash
dart run tooling/check_supply_chain.dart
dart run tooling/format_check.dart
flutter test --no-pub
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
flutter build apk --debug --no-pub
```

Debug APK：

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## 正式 arm64 构建

Release 不使用 debug 签名兜底。构建前必须准备未提交的 `android/key.properties` 和对应 keystore；字段可参考 `android/key.properties.example`。缺少签名配置时 Gradle 会让 `assembleRelease`/`bundleRelease` 失败。

```bash
flutter build apk --release --no-pub --target-platform android-arm64
flutter build appbundle --release --no-pub --target-platform android-arm64
```

输出：

```text
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

CI 使用 `.github/workflows/release-apk.yml`，通过以下 Secrets 临时生成签名配置，不把密钥写入仓库：

- `VALORA_RELEASE_KEYSTORE_BASE64`
- `VALORA_RELEASE_STORE_PASSWORD`
- `VALORA_RELEASE_KEY_PASSWORD`
- `VALORA_RELEASE_KEY_ALIAS`

CI 还会执行 `apksigner`/`jarsigner` 校验，生成 `valora-release-manifest.json` 和 `valora-pub-sbom.json`，上传构建 artifact，并创建 provenance attestation。详细权限与产物字段见 [B26 验证报告](../product/VALORA_B26%20CI签名与供应链加固验证.md)。

## 体积与 ABI 说明

`android/app/build.gradle` 对普通 Release 设置 `arm64-v8a` 过滤；`flutter build apk --release --split-per-abi --no-pub` 是兼容性/体积诊断命令，不代表产品默认发布所有 ABI。不要用历史的 100–110MB 通用包大小判断当前 arm64 产物。

若需要复核 Gradle 任务本身：

```powershell
android\gradlew.bat :app:assembleRelease :app:bundleRelease --no-daemon -Ptarget-platform=android-arm64
```

## 本机 AAB 收尾限制

如果 `flutter build appbundle` 已输出 AAB，但最后报告无法 strip native debug symbols 并退出非零，先检查 `flutter doctor -v` 是否提示缺少 Android `cmdline-tools`。Gradle `bundleRelease`、AAB 文件存在和签名校验可以分别核对，但不能把部分成功描述成 Flutter CLI 完整通过。修复 SDK command-line tools 后重新运行完整命令。

## 辅助脚本

仓库根目录的 `build_android.sh` 和 `build_windows.bat` 用于 Debug 构建；它们会先检查 Android 平台文件和 Gradle Wrapper，避免覆盖本地原生修改。正式 Release 使用 CI 或上面的签名命令，不使用辅助脚本隐式生成发布包。

## 不应提交的文件

- `android/local.properties`
- `android/key.properties`
- `android/app/*.p12`、`*.jks`、`*.keystore`
- `build/`、`.dart_tool/`、`.gradle/`
- APK、AAB、ZIP 和本地性能日志

完整许可证和第三方依赖声明见根目录 `LICENSE`、`NOTICE`、`THIRD_PARTY_NOTICES.md`。供应链检查命令会拒绝缺少直接 hosted 依赖声明的变更。
