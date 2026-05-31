# BUILD_FIX_REPORT

## 环境配置

- **Flutter SDK**: Flutter stable
- **Android SDK**: Android SDK Command-line Tools 或 Android Studio 自带 SDK
- **JDK**: Eclipse Adoptium JDK 17
- **Gradle**: 8.9（通过 Flutter gradle wrapper 下载）
- **代理**: 本地网络需要时自行配置

## 执行步骤

1. **Flutter SDK 安装** — 使用 Flutter stable，耗时取决于本地网络
2. **flutter doctor** — 运行检查环境，发现 cmdline-tools 缺失、Android license 未接受
3. **flutter pub get** — 成功，获取依赖
4. **flutter analyze** — 发现 47 个 issues（3 个 error，44 个 info）

## 修复的错误

### 1. features_asset_detail.dart:197 — `num` 不能赋给 `double`

**根因**: `clamp(0, 1)` 返回 `num` 类型而非 `double`

**修复**:
```dart
// 修复前
final recoveredRatio = (recovered / maxValue).clamp(0, 1).toDouble();
final consumedRatio = (consumed / maxValue).clamp(0, 1).toDouble();
final consumed = math.max(asset.netCost, 0);

// 修复后
final consumedRatio = (consumed / maxValue).clamp(0.0, 1.0);
final recoveredRatio = (recovered / maxValue).clamp(0.0, 1.0);
final consumed = math.max(asset.netCost, 0.0);
```

### 2. features_settings.dart:66 — `¥` 字符编码问题

**根因**: 文件中 `¥` 符号使用非标准 UTF-8 编码（`\xc2\xa5` 而非 `\u00a5`），导致 `const InputDecoration` 构造失败

**修复**:
```dart
// 修复前（异常字符导致 const 构造失败）
showDialog(context: context, builder: (d) => AlertDialog(..., content: TextField(..., decoration: const InputDecoration(labelText: '例如 ¥ / $ / RMB')), actions: [...FillButton(onPressed: () { context.store.updateSettings(context.store.settings.copyWith(currencyUnit: ctl.text.trim().isEmpty ? '¥' : ctl.text.trim())); ...})])));

// 修复后（使用 Unicode 转义避免编码问题）
showDialog(context: context, builder: (d) => AlertDialog(title: const Text('货币符号'), content: TextField(controller: ctl, decoration: InputDecoration(labelText: '例如 \u00a5 / \$ / RMB')), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('取消')), FilledButton(onPressed: () { context.store.updateSettings(context.store.settings.copyWith(currencyUnit: ctl.text.trim().isEmpty ? '\u00a5' : ctl.text.trim())); Navigator.pop(d); }, child: const Text('保存'))]));
```

### 3. Gradle wrapper 下载锁死问题

**根因**: 之前构建进程被中断后，`gradle-8.9-all.zip.lck` 和 `.zip.part` 文件残留，导致后续构建超时等待

**修复**:
```bash
# 杀死残留 Java 进程
taskkill //F //PID 50304

# 删除锁文件和残存下载文件
rm -f gradle-8.9-all.zip.lck gradle-8.9-all.zip.part
```

### 4. kotlin-dsl 插件无法解析

**根因**: Gradle 无法连接到 Gradle Central Plugin Repository 下载 kotlin-dsl 插件（需要代理）

**修复**: 在本机 Gradle 配置中按需添加代理配置：
```properties
systemProp.http.proxyHost=<proxy-host>
systemProp.http.proxyPort=<proxy-port>
systemProp.https.proxyHost=<proxy-host>
systemProp.https.proxyPort=<proxy-port>
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
```

## 构建成功

```
√ Built build\app\outputs\flutter-apk\app-debug.apk
```

**APK 路径**: `build\app\outputs\flutter-apk\app-debug.apk`
**APK 大小**: 140MB

## 剩余 warnings（不影响构建）

- Flutter Gradle Plugin 支持的 Gradle 版本 8.9.0 即将废弃，建议升级到 8.14.0+
- Android Gradle Plugin 8.7.0 即将废弃，建议升级到 8.11.1+
- Kotlin 2.0.0 即将废弃，建议升级到 2.2.20+
