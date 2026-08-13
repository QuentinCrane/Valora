# B24 本地化生成与三语言验证

## 实施结果

- 新增 `l10n.yaml`，开启 Flutter `gen_l10n`、命名参数、未翻译消息报告和固定的 locale 顺序
- 新增 `lib/l10n/app_zh_Hans.arb`、`app_zh_Hant.arb`、`app_en.arb`，共 925 个稳定消息和 466 个字面量消息，总计 1,391 个资源
- 新增 `app_zh.arb` 作为 Flutter 对脚本 locale 要求的中文 fallback；应用自己的 `supportedLocales` 仍明确只有 `zh-Hans`、`zh-Hant`、`en`
- 生成 `ValoraLocalizations` 及三语言实现，并将生成 delegate 接入 `MaterialApp`
- 用 `message_keys.json` 保存旧动态 key 到 ARB resource id 的稳定映射，`tooling/generate_l10n_catalog.dart` 从 ARB 生成兼容现有 `tr`、`tl`、`tlf` 的同步 catalog
- 删除 `l10n.dart` 中原有 2,300 余行手写稳定消息和字面量 Map，保留动态调用 API 与未知 key 的安全 fallback，避免一次性修改全仓调用点
- `AppLanguageSetting` 增加 `zhHans`；`zh-CN`、无脚本 `zh` 路由到简体，`zh-TW/HK/MO` 和 `Hant` 路由到繁体，英文路由到 `en`，未知系统语言默认简体

## 验证记录

| 检查 | 结果 |
| --- | --- |
| `flutter gen-l10n` | 通过；`untranslated_messages.json` 为 `{}` |
| ARB/catalog 生成器 | 通过；925 messages + 466 literals，三语言 key 集合一致 |
| 本地化聚焦测试 | 5/5 通过；包含 zh-CN、zh-TW、en、稳定设置 code、生成类、日期/数字/货币格式和 320dp 语言选择器布局 |
| 全量 `flutter test --no-pub` | 86/86 通过 |
| `flutter analyze --no-pub` | 0 error、0 warning、493 条既有 info |
| `tooling/format_check.dart` | 43 个文件检查，5 个历史 baseline 排除，0 个变更 |
| `git diff --check` | 通过；仅有 Git 的 LF/CRLF 提示 |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk`，122,963,859 bytes，2026-08-13 11:05:43，SHA-256 `BCDD02E4A954F185DD8C70ED6559F72B26EBE66802D8C1A251B37A9F281345A9` |

全量测试输出仍包含既有的 ListTile DecoratedBox assertion、`features_asset_home.dart:1313` 的 1px RenderFlex overflow，以及性能基线中的 `Bad state: No element`；它们不是 B24 本地化聚焦测试失败。上述测试和 APK 构建也不等同于真实设备、TalkBack 或截图验收。
