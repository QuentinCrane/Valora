# Valora技术与构建指南

本文档用于承接 README 中不适合展开太长的技术细节，包括技术栈、环境准备、构建流程、目录结构、源码入口、权限和隐私说明。

## 技术栈

- Flutter / Dart：主要 UI、状态组织和业务逻辑。
- Android 原生 Java：SQLite、桌面小组件、通知/提醒、文件分享、MethodChannel、媒体处理。
- Android Gradle Plugin：`8.7.0`
- Gradle Wrapper：`8.14`
- AndroidX：Core、Activity 等基础能力。
- Google ML Kit：条码扫描、文字识别、中文文字识别、主体分割。

当前仓库重点面向 Android APK 构建。README 中提到的多端方向是产品扩展方向；本仓库目前已提交的是 Android 构建壳和 Android 原生能力。

## 项目信息

- 当前版本：`0.79.0+79`
- Flutter 包名：`valora_assets`
- Android applicationId：`com.valora.assets`
- Android 最低版本：`minSdk 24`
- 构建形态：Flutter UI + Android 原生 MethodChannel / Widget / SQLite / ML Kit 能力
- 数据策略：本地优先，云端同步为可选能力

## 环境准备

建议使用以下环境：

- Flutter stable，Dart SDK 满足 `>=3.3.0 <4.0.0`
- Android Studio 或 Android SDK Command-line Tools
- JDK 17
- Git
- 一台 Android 真机或模拟器

先检查本机环境：

```bash
flutter doctor
flutter --version
```

如果 `android/local.properties` 不存在，通常执行 `flutter pub get` 会自动生成。也可以复制示例文件后手动填写路径：

```bash
cp android/local.properties.example android/local.properties
```

Windows 用户可以参考示例：

```properties
flutter.sdk=C:\\src\\flutter
sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
```

`android/local.properties` 包含本机路径，不应该提交到 Git。

## 安装依赖

```bash
flutter pub get
```

## 开发运行

连接设备后运行：

```bash
flutter run
```

如果需要指定设备：

```bash
flutter devices
flutter run -d <device-id>
```

## 构建 APK

Debug APK：

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

输出位置：

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Release APK：

```bash
flutter build apk --release
```

输出位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

仓库也提供了两个辅助脚本：

```bash
# Windows
build_windows.bat

# macOS / Linux
./build_android.sh
```

注意：当前 `android/app/build.gradle` 的 release 配置仍使用 debug 签名，便于本地测试。正式发布前请创建自己的 release keystore，并通过本地 `key.properties` 或 CI Secret 配置签名信息，不要把签名证书和密码提交到仓库。

## 目录结构

```text
.
├── lib/
│   ├── main.dart                         # Flutter 入口
│   └── src_parts/                        # 页面、状态、模型、原生桥接与公共组件
├── android/
│   ├── app/src/main/AndroidManifest.xml  # 权限、Activity、Receiver、Provider、小组件声明
│   └── app/src/main/java/com/valora/assets/
│       ├── MainActivity.java             # Flutter 与 Android 原生能力桥接
│       ├── WidgetUtils.java              # 桌面小组件工具
│       └── *WidgetProvider.java          # 多种桌面小组件
├── assets/
│   └── images/                           # 应用内图片资源
├── docs/
│   ├── guides/                           # 使用、开发和构建指南
│   ├── product/                          # 产品规格、迁移说明和参考资料
│   ├── reports/                          # 迭代报告、验证记录和修复记录
│   ├── stickers/                         # 贴纸封面和抠图相关笔记
│   └── assets/                           # 文档图片资源与脱敏截图
├── tooling/android_patch/                # Android 构建壳修复用补丁文件
├── pubspec.yaml                          # Flutter 项目配置
└── build_windows.bat / build_android.sh  # 本地构建脚本
```

## 关键源码入口

- `lib/main.dart`：应用总入口和 part 文件组织。
- `lib/src_parts/app_bootstrap.dart`：主题、路由、预测式返回、应用启动。
- `lib/src_parts/store.dart`：数据模型调度、本地存储、云同步、导入导出。
- `lib/src_parts/shell.dart`：底部 Dock、页面切换和新建入口。
- `lib/src_parts/features_asset_home.dart`：首页资产看板和资产列表。
- `lib/src_parts/features_asset_editor.dart`：新增/编辑资产与心愿。
- `lib/src_parts/features_asset_detail.dart`：资产详情页。
- `lib/src_parts/features_analytics.dart`：统计分析页。
- `lib/src_parts/features_settings.dart`：设置、备份、同步和系统集成入口。
- `lib/src_parts/native_services.dart`：Android 原生桥接封装。
- `android/app/src/main/java/com/valora/assets/MainActivity.java`：SQLite、文件、分享、识别、抠图、小组件更新等原生能力实现。

## 数据与隐私说明

- 默认情况下，资产和心愿数据保存在应用私有目录中的 SQLite 数据库内。
- 封面、贴纸抠图和导出资料包会写入应用私有目录或由系统文件选择器保存到用户指定位置。
- 相机、OCR、条码扫描和主体分割仅在用户主动使用相关功能时触发。
- WebDAV / Nextcloud / 坚果云同步为可选功能，只有在用户填写并启用云端配置后才会访问网络。
- 桌面小组件会通过本地 SharedPreferences 读取摘要数据，用于展示总资产、心愿数量、日均成本等概览。

## 权限说明

AndroidManifest 中声明的主要权限如下：

- `INTERNET`：用于可选 WebDAV/Nextcloud/坚果云同步。
- `CAMERA`：用于条码扫描、拍照识别和相关智能录入能力。
- `VIBRATE`：用于保存、切换、提醒等交互反馈。
- `POST_NOTIFICATIONS`：用于 Android 13+ 上的到期提醒通知。
- `RECEIVE_BOOT_COMPLETED`：用于设备重启后恢复已设置的提醒。

## 常用检查命令

提交代码前建议执行：

```bash
dart format .
flutter analyze
flutter build apk --debug
```

如果遇到 Android 构建壳损坏或 Gradle Wrapper 缺失，可以运行构建脚本，它会尝试用 `flutter create` 补齐 Android 壳并重新应用 `tooling/android_patch` 中的项目补丁。

## 开源前技术检查

- 不提交 `android/local.properties`、`.env`、`key.properties`、`*.jks`、`*.keystore` 等本机路径或签名密钥。
- 不提交 `build/`、`.dart_tool/`、`.gradle/`、APK/AAB、临时日志和个人备份 ZIP。
- 对外分发的 APK 放到 GitHub Releases，不提交到源码仓库。
- Flutter App 建议提交 `pubspec.lock`，这样其他人能复现当前依赖解析结果。
- 保留或替换当前 `LICENSE` 文件。本仓库默认采用 Apache License 2.0，并提供 `NOTICE` 项目归属说明。
- 如果 README 或文档中展示截图，先确认截图不包含个人资产、账号、WebDAV 地址或其他隐私信息。
