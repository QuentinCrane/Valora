# Flutter Release APK 编译流程与问题记录

## 编译环境

- **Flutter SDK**: Flutter stable，Dart SDK 满足 `>=3.3.0 <4.0.0`
- **Android SDK**: Android SDK Command-line Tools 或 Android Studio 自带 SDK
- **JDK**: 17 (Eclipse Adoptium)
- **代理**: 仅在本地网络需要时自行配置
- **Gradle Wrapper**: 8.14

## 编译命令

```bash
# 在仓库根目录执行

# 编译 Release APK
flutter build apk --release
```

APK 输出路径: `build\app\outputs\flutter-apk\app-release.apk`

公开分发时不要把 APK 提交到源码仓库。建议重命名为 `Valora-v0.80-android.apk` 后上传到 GitHub Releases。

---

## 常见错误与解决方案

### 1. ABI 过滤冲突 (Conflicting ABI Filters)

**错误信息:**
```
Conflicting configuration : 'armeabi-v7a,arm64-v8a,x86_64' in ndk abiFilters 
cannot be present when splits abi filters are set : armeabi-v7a,arm64-v8a
```

**原因:** `android/app/build.gradle` 中的 `splits.abi` 配置与 Flutter 本身的 NDK ABI 过滤冲突。

**解决方案:** 删除 `splits.abi` 配置块，仅保留 `buildTypes`：

```groovy
android {
    // ... defaultConfig ...

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
}
```

---

### 2. `num` 类型不能赋值给 `double` (features_asset_detail.dart)

**错误信息:**
```
Error: The argument type 'num' can't be assigned to the parameter type 'double'.
```

**原因:** `math.max()` 和 `clamp()` 使用整数参数时返回 `num` 类型，而不是 `double`。

**解决方案:** 使用 `.0` 后缀确保参数为 `double` 类型：

```dart
// 错误代码
final consumed = math.max(asset.netCost, 0);
final maxValue = math.max(asset.price + asset.dailyAddonTotal, 1);
final recoveredRatio = (recovered / maxValue).clamp(0, 1).toDouble();

// 正确代码
final consumed = math.max(asset.netCost, 0.0);
final maxValue = math.max(asset.price + asset.dailyAddonTotal, 1.0);
final recoveredRatio = (recovered / maxValue).clamp(0.0, 1.0);
final consumedRatio = (consumed / maxValue).clamp(0.0, 1.0);
```

---

### 3. 多行字符串中的非 ASCII 字符问题 (native_services.dart)

**错误信息:**
```
Error: String starting with ' must end with '.
Error: The non-ASCII character 'xxx' (U+XXXX) can't be used in identifiers...
```

**原因:** 多行字符串中包含非标准编码的中文字符（可能是复制粘贴导致的编码问题）。

**解决方案:** 将多行字符串改为转义换行符格式：

```dart
// 错误代码
const Text('1. 从物体轮廓一侧开始画。
2. 尽量连续地绕物体一圈。
...', style: TextStyle(...)),

// 正确代码
const Text('1. 从物体轮廓一侧开始画。\n2. 尽量连续地绕物体一圈。\n...', 
    style: TextStyle(...)),
```

---

### 4. `CupertinoPageTransitionsBuilder` 在 const 上下文中不可用 (app_bootstrap.dart)

**错误信息:**
```
Error: The function 'CupertinoPageTransitionsBuilder' isn't defined.
Error: Invalid constant value.
```

**原因:** `CupertinoPageTransitionsBuilder` 不是 const 可构造的，且在 const 上下文中引用需要额外的 cupertino 导入。

**解决方案:** 仅保留 Android 的页面过渡动画：

```dart
pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    // 删除 TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
  },
),
```

---

### 5. `$` 字符在字符串中需要转义 (features_settings.dart)

**错误信息:**
```
Error: A '$' has special meaning inside a string, and must be followed by 
an identifier or an expression in curly braces ({}).
```

**原因:** `$` 在 Dart 字符串中有特殊含义（字符串插值）。

**解决方案:** 使用 `\$` 转义或 Unicode 转义：

```dart
// 错误代码
InputDecoration(labelText: '例如 ¥ / $ / RMB')

// 正确代码
InputDecoration(labelText: '例如 \u00a5 / \$ / RMB')
```

---

### 6. `String.take` 扩展方法重复定义

**错误信息:**
```
Error: The method 'take' is defined in multiple extensions for 'String' and 
neither is more specific.
```

**原因:** `store.dart` 和 `native_services.dart` 中都定义了 `String.take` 扩展方法。

**解决方案:** 删除其中一个文件中的重复定义（通常删除 `native_services.dart` 中的）。

---

## 完整编译流程

1. **检查代码错误**
   ```bash
   flutter analyze
   ```

2. **修复发现的错误**（根据上述解决方案）

3. **编译 Release APK**
   ```bash
   flutter build apk --release
   ```

4. **验证输出**
   - APK 文件应位于: `build\app\outputs\flutter-apk\app-release.apk`
   - 正常大小约 100-110MB（包含所有架构）

---

## 注意事项

1. **每次用户更新代码后**，`features_asset_detail.dart` 中的类型问题可能会重新出现，需要重新应用修复。

2. **splits.abi 配置问题**也会在用户更新 `build.gradle` 后重新出现。

3. 编译警告（关于 Gradle/AGP/Kotlin 版本）不影响编译成功，可以忽略。

---

## 版本记录

| 版本号 | 修复内容 |
|--------|----------|
| 0.34.0 - 0.46.0+ | 移除 splits.abi；修复 num/double 类型；修复多行字符串；修复扩展方法冲突 |
