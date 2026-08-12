# Valora 实施基线报告

> 对应规划：`VALORA_全仓功能完善与性能优化实施规划.md`
> 基线块：B00
> 审计日期：2026-08-12
> 审计仓库：`E:\Github Program\Valora\valora_app`

## 1. B00 范围

B00 只固化后续实施需要的工具链、只读审计脚本和现状基线，不升级依赖、不修改业务代码。

审计脚本：[tooling/valora_audit.ps1](../../tooling/valora_audit.ps1)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tooling/valora_audit.ps1 -FlutterPath C:\Flutter\bin\flutter.bat
```

脚本只输出版本、Git 状态、受版本控制文件盘点、敏感文件数量和 APK 元数据；不会打印或写出凭据、密码、密钥内容或本机绝对路径。

## 2. 工具链实测值

| 工具 | 实测值 |
|---|---|
| Flutter | 3.44.8 stable |
| Flutter framework revision | `058e0af2c2b57e369d905a03ac9748b0ebf543c6` |
| Dart SDK | 3.12.2 |
| Java | Temurin OpenJDK 17.0.19 |
| Gradle Wrapper | 8.14 |
| Android SDK platforms | android-31、android-32、android-33、android-34、android-35、android-36 |
| Android build-tools | 30.0.3、34.0.0、35.0.0、35.0.1、36.0.0 |
| 应用版本 | 0.80.1+81 |
| Android minSdk | 24 |
| Android ABI | arm64-v8a |

版本来自 Flutter machine 输出、Java 版本输出、Gradle Wrapper 配置和当前 `android/local.properties` 指向的 SDK 目录。审计报告不记录本机绝对路径。

## 3. Git 与文件基线

- 基线提交：`c4f10f336ccbcbe84dca7414ca548f7c6d8135c0`
- 基线分支：`main`，与 `origin/main` 同步
- 受版本控制文件：144 个
- 规划文档在审计开始时是工作区已有的未跟踪输入文件；B00 不把它加入提交
- 本地 `tooling/android_patch` 下存在被 `.gitignore` 排除的签名材料；审计脚本只报告数量，不读取、输出或纳入提交

## 4. 测试与分析基线

| 命令 | 结果 | 说明 |
|---|---|---|
| `flutter test --no-pub` | 通过 | 3 个测试全部通过 |
| `flutter analyze --no-pub` | 非零退出 | 388 个既有 `info`，全部为 Flutter API 弃用提示；warning/error 为 0 |
| 业务代码变更 | 无 | B00 只新增工具脚本和报告 |

`--no-pub` 表示使用当前依赖缓存，不能替代联网依赖解析；正式发布前仍需单独执行联网 `flutter pub get` 并核对锁文件。

## 5. B00 前已有 APK 记录

B00 前工作区已有的 APK 只作为历史产物记录，不能代表当前 HEAD 的新构建：

| 产物 | 大小 | CreationTime（本地时间） | LastWriteTime（本地时间） | SHA-256 |
|---|---:|---|---|---|
| `build/app/outputs/flutter-apk/app-debug.apk` | 121,492,234 | 2026-06-18 21:43:45 | 2026-07-18 12:20:00 | `2301E11816E89E3CC4F4380E9080B342DB313CF732D43BE73FD2158EEC2217CB` |
| `build/app/outputs/flutter-apk/app-release.apk` | 50,255,073 | 2026-07-15 21:14:15 | 2026-07-23 01:14:49 | `9D77B2B38A42EC4E26DB9365326322AFBB88F4570AA8972245352CCA73D1F523` |

## 6. B00 验证产物

执行命令：

```powershell
C:\Flutter\bin\flutter.bat build apk --debug --no-pub
```

结果：`√ Built build\app\outputs\flutter-apk\app-debug.apk`，耗时 162.1 秒

| 产物 | 大小 | CreationTime（本地时间） | LastWriteTime（本地时间） | SHA-256 |
|---|---:|---|---|---|
| `build/app/outputs/flutter-apk/app-debug.apk` | 104,226,483 | 2026-06-18 21:43:45 | 2026-08-12 21:19:55 | `F89B339B4F183EAD06A0DC91FF168353B73AD52802091B051C220B9C41FDB0AC` |

Windows 覆盖构建文件后保留原 `CreationTime`，因此以构建成功日志、更新后的 `LastWriteTime`、文件大小和 SHA-256 共同证明本次 Debug APK 是当前 B00 工作区产物。

## 7. B00 验收边界

- 审计脚本不写文件，适合在干净克隆中运行
- 审计输出不包含用户名、密码或签名材料
- 后续块必须使用本报告中的工具链和统一验证顺序
- 388 条既有弃用提示暂不在 B00 混入修复；是否分批处理由后续独立块决定
