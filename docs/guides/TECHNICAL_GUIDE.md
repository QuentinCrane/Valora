# Valora技术与构建指南

本文档用于承接 README 中不适合展开太长的技术细节，包括技术栈、环境准备、构建流程、目录结构、源码入口、权限和隐私说明。

## 技术栈

- Flutter / Dart：主要 UI、状态组织和业务逻辑。
- Android 原生 Java：SQLite、桌面小组件、通知/提醒、文件分享、MethodChannel、媒体处理。
- Android Gradle Plugin：`8.7.0`
- Gradle Wrapper：`8.14`
- AndroidX：Core、Activity 等基础能力。
- Google ML Kit：条码扫描、文字识别、中文文字识别、主体分割。
- 贴纸主体分割：Google ML Kit Subject Segmentation；`android/app/src/main/assets/models/` 仅保留未来离线 TFLite 模型的预留位置，当前没有随 APK 发布的本地 TFLite 模型。

当前仓库重点面向 Android APK 构建。README 中提到的多端方向是产品扩展方向；本仓库目前已提交的是 Android 构建壳和 Android 原生能力。

## 项目信息

- 当前版本：`0.80.2+82`
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
flutter build apk --release --no-pub --target-platform android-arm64
```

输出位置：

```text
build/app/outputs/flutter-apk/app-release.apk
```

AAB：

```bash
flutter build appbundle --release --no-pub --target-platform android-arm64
```

输出位置：`build/app/outputs/bundle/release/app-release.aab`

仓库也提供了两个 Debug 辅助脚本：

```bash
# Windows
build_windows.bat

# macOS / Linux
./build_android.sh
```

Release 不再使用 debug 签名兜底。正式构建必须提供未提交的 `android/key.properties` 和真实 keystore；缺少其中任一项时 `assembleRelease`/`bundleRelease` 会失败。CI 发布工作流要求 `VALORA_RELEASE_KEYSTORE_BASE64`、`VALORA_RELEASE_STORE_PASSWORD`、`VALORA_RELEASE_KEY_PASSWORD`、`VALORA_RELEASE_KEY_ALIAS`，并生成 APK/AAB 哈希、证书指纹、版本清单和 provenance attestation。详见 [B26 验证报告](../product/VALORA_B26%20CI签名与供应链加固验证.md)。

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
│   ├── stickers/                         # 贴纸封面和抠图相关笔记
│   └── assets/                           # 文档图片资源与脱敏截图
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
- Flutter 导出的 canonical JSON 当前为 `storageSchemaVersion: 1`、`exportSchemaVersion: 3`；数据库使用 `kv_store` 保存 payload 和最后一次验证快照，导入前会迁移、校验，写入后回读确认。
- 封面、贴纸抠图和导出资料包会写入应用私有目录或由系统文件选择器保存到用户指定位置。
- 相机、OCR、条码扫描和主体分割仅在用户主动使用相关功能时触发。
- WebDAV / Nextcloud / 坚果云同步为可选功能，只有在用户填写并启用云端配置后才会访问网络；正式服务要求 HTTPS，测试只允许 loopback HTTP，上传使用 ETag/`If-Match` 或首次创建的 `If-None-Match: *`，冲突交给用户选择，不自动覆盖。
- 自动上传使用唯一 WorkManager 任务并带联网约束；启动拉取发现本机与远端哈希不一致时进入冲突状态。
- 完整 ZIP 备份在应用私有 staging 目录预检，包含脱敏 JSON、CSV/Markdown、SQLite 副本和媒体 SHA-256 清单；确认后原子提交，失败会回滚。
- 桌面小组件会通过本地 SharedPreferences 读取摘要数据，用于展示总资产、心愿数量、日均成本等概览。
- 当前 Manifest 声明 8 类 AppWidgetProvider：总览、心愿、日均、体检、快捷记录、到期、快照和轻量卡片；Flutter 保存时按目标集合刷新，手动刷新才使用全量集合。

## 权限说明

AndroidManifest 中声明的主要权限如下：

- `INTERNET`：用于可选 WebDAV/Nextcloud/坚果云同步。
- `CAMERA`：用于条码扫描、拍照识别和相关智能录入能力。
- `VIBRATE`：用于保存、切换、提醒等交互反馈。
- `POST_NOTIFICATIONS`：用于 Android 13+ 上的到期提醒通知。
- `RECEIVE_BOOT_COMPLETED`：用于设备重启后恢复已设置的提醒。
- 未声明外部存储权限；图片优先使用 Android Photo Picker/系统文件选择器，拍照通过受限 FileProvider 路径交给应用私有目录。
- `android:usesCleartextTraffic="false"`：禁止普通 HTTP；仅测试代码可放行 loopback HTTP。

## 常用检查命令

提交代码前建议执行：

```bash
dart run tooling/format_check.dart
flutter test --no-pub
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
flutter build apk --debug --no-pub
```

供应链检查：

```bash
dart run tooling/check_supply_chain.dart
```

如果 Android 构建壳或 Gradle Wrapper 缺失，构建脚本会停止而不会覆盖本地原生修改。在 Git 检出中运行以下命令恢复受版本控制的 Android 文件：

```bash
git restore --source=HEAD --worktree -- android
```

如果当前目录不是 Git 检出，请从干净的仓库副本恢复 `android/` 目录后再构建。

## 开源前技术检查

- 不提交 `android/local.properties`、`.env`、`key.properties`、`*.jks`、`*.keystore` 等本机路径或签名密钥。
- 不提交 `build/`、`.dart_tool/`、`.gradle/`、APK/AAB、临时日志和个人备份 ZIP。
- 对外分发的 APK 放到 GitHub Releases，不提交到源码仓库。
- 正式发布由 `.github/workflows/release-apk.yml` 触发；它只接受正式签名 Secrets，构建后上传 APK、AAB、版本/哈希清单和 Pub SBOM，并创建 provenance attestation。
- Flutter App 建议提交 `pubspec.lock`，这样其他人能复现当前依赖解析结果。
- 保留或替换当前 `LICENSE` 文件。本仓库默认采用 Apache License 2.0，并提供 `NOTICE` 项目归属说明。
- 如果 README 或文档中展示截图，先确认截图不包含个人资产、账号、WebDAV 地址或其他隐私信息。
