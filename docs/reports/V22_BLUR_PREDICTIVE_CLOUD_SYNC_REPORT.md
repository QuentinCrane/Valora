# V22：实时模糊 Dock、预测返回排查与云端同步设置

## 1. Dock 质感修复

本版把 v21 中偏“纯透明水滴”的 Dock 重新改回轻量实时模糊：

- `_WaterDropShell` 重新加入 `BackdropFilter.blur(sigmaX: 18, sigmaY: 18)`。
- 背景不是实心白，也不是完全透明，而是半透明白色 + 轻蓝散射。
- 边缘增加白色高光、底部折射亮边和右下角主题蓝径向光。
- 右下角加号继续复用同一套水滴壳，保持与 Dock 一致。

这样可以保留“下面内容能透出来”的感觉，同时避免变成纯透明按钮。

## 2. 预测式返回排查与修复

此前问题的核心是：

- `PredictiveBackBoundary` 类存在，但没有包裹到二级页面路由上。
- 因此系统预测返回配置虽然存在，Flutter 页面内的可见预测反馈没有真正接入。

本版修复：

```dart
Route<T> softRoute<T>(Widget page) => MaterialPageRoute<T>(
  builder: (_) => PredictiveBackBoundary(child: page),
  fullscreenDialog: false,
);
```

同时继续保留 Android 侧配置：

```xml
android:enableOnBackInvokedCallback="true"
<meta-data android:name="android.window.PROPERTY_ENABLE_BACK_ANIMATION" android:value="true" />
```

### 测试方式

1. 使用 Android 13 / 14 / 15 真机或模拟器。
2. 系统导航方式必须切换为“手势导航”。
3. 部分 Android 13 设备还需要在开发者选项中打开 Predictive back animations。
4. 必须进入二级页面测试，比如：资产详情、编辑页、新增页、设置弹出的子流程。
5. 从屏幕最左边缘慢慢向右滑，不要点页面内部返回按钮。

说明：Android 官方与 Flutter 文档都强调，预测式返回需要设备、系统设置、目标 SDK、路由栈和 Flutter 版本共同满足；根页面没有上一页时不会出现预测返回。

## 3. 云端同步设置

新增“设置 → 云端”分段，支持：

- WebDAV
- 坚果云 WebDAV
- Nextcloud
- 自定义 WebDAV
- 手动文件备份

### 已实现能力

- 保存云端配置；
- 测试 WebDAV 连接（PROPFIND）；
- 上传当前 JSON 备份（MKCOL + PUT）；
- 从云端读取 JSON 并恢复（GET）；
- 保存后自动上传开关；
- 启动时尝试拉取开关；
- 继续保留系统文件备份和系统分享备份。

### 权限

新增：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 注意

当前版本为了减少依赖，使用 Dart `HttpClient` 实现 WebDAV 基本能力。配置中的账号和密码会随本地 JSON 保存；正式发布前建议继续接入 Android Keystore / EncryptedSharedPreferences。

## 4. 本轮修改文件

- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/shell.dart`
- `lib/src_parts/models.dart`
- `lib/src_parts/store.dart`
- `lib/src_parts/features_settings.dart`
- `lib/src_parts/native_services.dart`
- `android/app/src/main/AndroidManifest.xml`
- `pubspec.yaml`
- `android/app/build.gradle`

## 5. 本地验证命令

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```
