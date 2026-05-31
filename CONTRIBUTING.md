# Contributing to Valora

感谢你愿意改进 Valora（值谱）。这个项目目前重点面向 Android APK、本地优先数据体验和个人资产价值复盘。

## 开发环境

建议准备：

- Flutter stable，Dart SDK 满足 `>=3.3.0 <4.0.0`
- Android Studio 或 Android SDK Command-line Tools
- JDK 17
- 一台 Android 真机或模拟器

安装依赖：

```bash
flutter pub get
```

## 提交前检查

提交 Pull Request 前，请尽量运行：

```bash
dart format .
flutter analyze
flutter build apk --debug
```

如果修改了 Android 原生桥接、小组件、备份恢复、数据库或权限，请在 PR 描述中写清：

- 修改影响的功能入口。
- 手动验证过的设备或模拟器。
- 是否影响已有本地数据、导入导出、同步或通知。

## 分支与提交

- 小修复可以直接提交一个清晰的 PR。
- 较大的功能建议先开 Issue 讨论目标、数据结构和 UI 入口。
- 提交信息尽量说明用户可见变化，例如 `fix: keep asset cover after restore`。

## 隐私与素材

请不要提交以下内容：

- `android/local.properties`、`.env`、`key.properties`、签名证书和任何账号密钥。
- 包含个人资产、真实账号、WebDAV 地址或私有文件路径的截图。
- 未获得公开授权的图标、图片、模型或大段文案。

## 文档

常用入口：

- [技术与构建指南](docs/guides/TECHNICAL_GUIDE.md)
- [用户使用教程](docs/guides/USER_GUIDE.md)
- [开源发布检查清单](docs/guides/OPEN_SOURCE_RELEASE.md)
