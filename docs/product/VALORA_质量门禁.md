# Valora 质量门禁

> 对应规划块：B01
> 工具链基线：见 [VALORA_实施基线报告.md](VALORA_实施基线报告.md)

## 本地命令

在仓库根目录执行以下命令。CI 使用相同的 Dart/Flutter 命令和参数，只有工具安装方式不同：

```powershell
C:\Flutter\bin\flutter.bat pub get
dart run tooling/format_check.dart
C:\Flutter\bin\flutter.bat test --no-pub
C:\Flutter\bin\flutter.bat analyze --no-pub --fatal-warnings --no-fatal-infos
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
```

`tooling/format_baseline.txt` 暂时列出 B01 之前的 5 个格式债务文件；检查器仍会检查其余 Dart 文件，并在基线条目消失时失败。`--no-fatal-infos` 只允许当前既有 info 级问题不阻断门禁；信息仍会打印。warning、error、格式变更、测试失败和 Debug 构建失败都会使命令返回非零状态。

## 测试边界

- `test/` 负责本地 unit/widget 测试，当前既有 Store 回归测试仍由全量 `flutter test` 执行
- `test/domain/`、`test/repository/`、`test/widget/` 和 `integration_test/` 已建立目录边界
- 需要真实 Android 生命周期、相机、通知或媒体通道的测试不在 B01 伪造为通过；由对应功能块补充

## CI 入口

- `.github/workflows/quality-gates.yml` 在 `main` push、Pull Request 和可复用调用时运行
- 发布工作流先等待同一份质量门禁成功，再执行 Release APK 构建
- 故意引入格式错误、让测试断言失败或制造分析 warning/error 时，分别会在对应门禁命令处失败

## B01 实测结果

| 门禁 | 结果 |
|---|---|
| `flutter pub get` | 通过；新增 `flutter_lints 6.0.0` 与 `lints 6.1.0`，未升级运行时依赖 |
| `dart run tooling/format_check.dart` | 通过；检查 11 个 Dart 文件，排除 5 个既有格式债务文件 |
| `flutter test --no-pub` | 通过；3 个测试全部通过 |
| `flutter analyze --no-pub --fatal-warnings --no-fatal-infos` | 通过；499 个 info 可见，warning/error 为 0 |
| 故障注入 | 通过验证；格式探针和失败测试分别返回非零退出码，探针已删除 |
| `flutter build apk --debug --no-pub` | 通过；Gradle `assembleDebug` 18.8 秒 |

Debug APK 元数据：大小 121,512,166 bytes，CreationTime 为 2026-06-18 21:43:45，LastWriteTime 为 2026-08-12 21:34:09，SHA-256 为 `16FF1F5F518E409A824AD480E47E88A5D43C83B23F51CBDB773CCAC300142DBC`

## B01 停止边界

B01 只建立规则、目录、命令和工作流，不批量重写既有 Dart 代码，也不升级现有运行时依赖。388 条既有弃用 info 的修复留给后续独立块。
