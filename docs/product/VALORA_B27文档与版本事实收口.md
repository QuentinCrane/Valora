# VALORA B27 文档与版本事实收口

## 当前事实基线

| 主题 | 当前实现 |
| --- | --- |
| 版本 | `pubspec.yaml`：`0.80.1+81`；Android `versionName`：`0.80.1`，`versionCode`：`81` |
| Android | `applicationId com.valora.assets`，`minSdk 24`，普通 Release 默认 `arm64-v8a` |
| 持久化 | Flutter `LocalSqliteStorage` 通过 `valora/local_store` 使用 `valora_assets_local.db` 的 `kv_store`；`storageSchemaVersion: 1`，`exportSchemaVersion: 3` |
| 备份 | JSON、CSV、Markdown、SQLite 副本和完整 ZIP；ZIP 预检、脱敏、媒体 SHA-256、staging、确认后原子提交和失败回滚 |
| 云同步 | 可选 WebDAV/坚果云/Nextcloud；正式 HTTPS、条件上传、ETag/内容哈希冲突、WorkManager 自动上传；不静默覆盖 |
| 权限 | `INTERNET`、`VIBRATE`、`CAMERA`、`RECEIVE_BOOT_COMPLETED`、`POST_NOTIFICATIONS`；无外部存储权限，图片使用 Photo Picker/文件选择器和受限 FileProvider |
| 提醒 | `BootReceiver` 已处理 boot、locked boot、时区/时间变化和应用替换，并调用 `ReminderScheduler.sync`；这不是空实现 |
| Widget | 8 类 Provider：总览、心愿、日均、体检、快捷记录、到期、快照、轻量卡片；摘要来自本地 SharedPreferences，保存时按目标范围刷新 |
| 贴纸 | ML Kit Subject Segmentation + 多候选/手动修边；首次使用可能下载模型，模型不可用时使用离线启发式轮廓；没有随 APK 发布的本地 TFLite 模型 |
| 发布 | Release 缺少正式签名配置时失败，不回退 debug；CI 生成 APK/AAB 清单、Pub SBOM 和 provenance attestation |

## 本次文档调整

- README、用户教程、技术指南、构建流程、开源发布清单、贡献指南和安全策略统一到 `0.80.1+81`、arm64 Release、正式签名、SQLite、备份/同步/权限/Widget/贴纸事实。
- `CHANGELOG.md` 增加 `0.80.1` 维护版本入口，README 将当前版本指向 Changelog，并把 `v0.80.0` 明确为历史发布文案。
- `DATABASE_UPGRADE_PLAN.md` 改为“当前 SQLite + JSON 边界及未来规范化路线”，不再把 SharedPreferences JSON 写成当前主存储。
- `REFERENCE_IMPLEMENTATION_MAP.md`、`ORIGINAL_VUE_HANDOFF.md`、`docs/v80_github_release_notes.md` 和 v32/v33 贴纸资料增加历史文档标记；早期设计中的“无云同步”“SharedPreferences 原型”“本地模型”不再作为当前能力说明。
- `android/app/src/main/assets/models/README.txt` 明确模型目录只是未来离线 TFLite 预留，当前 APK 使用 ML Kit 和回退链路。
- `docs/README.md` 补齐 B25、B26、B27 入口，并说明历史报告和当前实现文档的边界。

## 验证计划与结果

| 检查 | 结果 |
| --- | --- |
| Markdown 相对路径扫描 | B27 完成后逐文件检查，跳过外部 URL 和锚点；无缺失目标 |
| 版本事实扫描 | `pubspec.yaml`、`android/app/build.gradle`、README、技术指南和 B26 清单一致 |
| 过时实现声明扫描 | 仅历史文档保留早期描述，均有历史状态标记；规划文档作为用户输入保持未提交 |
| `flutter pub get` | 在当前仓库根目录重新解析依赖并保持锁文件 |
| `dart run tooling/check_supply_chain.dart` | 直接依赖许可证检查和 27 包 SBOM 生成通过 |
| `dart run tooling/format_check.dart` | 45 个 Dart 文件，0 个变更 |
| `flutter test --no-pub` | 91 个测试全部通过 |
| `flutter analyze --no-pub` | 0 error、0 warning；493 条既有 info |
| `flutter build apk --debug --no-pub` | 通过；仅作为构建验证，不等同于设备验收 |

最终 Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`，`122,970,657 bytes`，`2026-08-13T12:08:13.5670996+08:00`，SHA-256 `BB14ECB0F375F868F002CA9A25BF282FC339992CFCD172E70FB9E3EB7765F6DF`。

全量测试日志仍可能输出仓库已知的 ListTile 背景断言、1px RenderFlex 溢出和性能基准 `Bad state: No element` 记录；只要退出码为 0，它们分别作为既有测试日志边界记录，不在 B27 伪装成设备级结论。
