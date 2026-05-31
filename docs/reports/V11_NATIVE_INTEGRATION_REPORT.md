# Valora v11 Android Native Integration Report

本版本在 v10 UI polished 基础上新增 Android 原生能力适配，目标是让 App 从纯 Flutter UI Demo 更接近真实 Android 应用。

## 已新增的原生能力

### A. Native Feel Pack
- `valora/native` MethodChannel。
- 原生 `Vibrator` / `VibrationEffect` 触感桥接。
- Flutter 侧 `tapHaptic`、`lightHaptic`、`mediumHaptic`、`successHaptic`、`warningHaptic` 统一接入。
- Android 侧透明状态栏 / 导航栏 edge-to-edge 初步适配。

### C. Reminder & Automation Pack
- `AlarmManager` 安排本地提醒。
- `ReminderReceiver` 接收提醒并创建 Android `Notification`。
- Android 13+ 通知权限请求入口。
- 通知设置跳转入口。
- `ShortcutManager` 创建桌面长按快捷方式：新增资产 / 新增心愿。
- `BootReceiver` 已预留开机后恢复长期提醒的扩展位置。

### D. Home Widget Pack
- 新增 `ValoraWidgetProvider`。
- 新增 `widget_valora.xml` 和 `valora_widget_info.xml`。
- Flutter 数据保存时会调用 `updateHomeWidget`，把资产数量、心愿数量、总资产、日均成本同步到桌面小组件。

### E. Media & Recognition Pack
- Android Photo Picker / `ACTION_OPEN_DOCUMENT` 选择图片。
- 系统相机 Intent 拍照入口。
- 设置页新增“相册 / 拍照接入”入口。
- 条码扫描、OCR 小票识别未直接内置，因为完整实现需要 CameraX / ML Kit 依赖；当前在 UI 与文档中预留扩展口。

### F. Backup & Report Pack
- Storage Access Framework 导出 JSON。
- Storage Access Framework 导入 JSON。
- 导出 CSV 资产表。
- 导出 Markdown 资产报告。
- 系统分享面板分享资产报告 / JSON 文本。

### G. System Integration Pack
- Android 系统分享面板。
- App 可接收外部 `text/plain` 和 `image/*` 分享 Intent。
- `valora://` Deep Link 入口预留。
- 系统应用设置跳转。
- 通知设置跳转。

### 剪贴板读入
- 原生 `ClipboardManager` 读取系统剪贴板。
- 剪贴板内容如果是 JSON，会尝试恢复Valora备份。
- 剪贴板内容如果是普通文本，会打开新增资产页，并把首行文本填入资产名称草稿。
- 支持把当前 JSON 备份写入剪贴板。

## 新增 / 修改文件

### Flutter
- `lib/src_parts/native_services.dart`
- `lib/main.dart`
- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/store.dart`
- `lib/src_parts/features_settings.dart`
- `lib/src_parts/features_wishes.dart`

### Android Java
- `MainActivity.java`
- `ReminderReceiver.java`
- `BootReceiver.java`
- `ValoraWidgetProvider.java`

### Android resources
- `res/layout/widget_valora.xml`
- `res/xml/valora_widget_info.xml`
- `res/drawable/widget_background.xml`
- `res/drawable/ic_shortcut_add.xml`
- `res/drawable/ic_shortcut_wish.xml`

## 权限

Manifest 新增：

```xml
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

## 需要你本地验证的命令

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

## 仍建议后续继续做的部分

1. 把 Photo Picker 返回的 URI 真正写入 Asset 模型并展示真实封面。
2. 使用 WorkManager 做长期、可恢复的周期资产体检提醒。
3. 使用 CameraX + ML Kit 实现条码扫描和小票 OCR。
4. 用 Kotlin 重写原生桥接层，代码会更现代、更稳定。
5. 做 Widget 尺寸适配：小号、中号、大号三个布局。
6. 对 Android 13+ 通知权限结果做完整回调处理。
