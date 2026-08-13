# VALORA B25 无障碍与窗口自适应验证

## 范围

B25 以 Flutter 窗口自适应和无障碍交互为目标，覆盖紧凑手机窗口、平板/桌面宽度、系统大字号、减少动画、语义树和关键触控区域。自适应检查参考了 adaptive 技能中的窗口断点、内容约束、导航区域和布局测试原则；项目仍保持 Flutter 原生实现，不引入 Compose 或 Navigation 3。

## 实施内容

- 新增 `ValoraAdaptiveContent`、窗口级别判断和最小触控目标常量：紧凑窗口 `<600dp`、中等窗口 `600–839dp`、扩展窗口 `>=840dp`，页面内容最大宽度为 `840dp` 并居中。
- 底部 Dock 在 `320dp`、`390dp` 等窄窗口下自动收窄，避免导航项和新增按钮重叠；导航、筛选、分段选择、日期格和关键图标操作补齐至少 `48dp` 触控区域及选中语义。
- 为返回、添加、重试、筛选、日期、标签页和 Dock 补齐按钮语义；持久化错误横幅声明 live region；分析趋势、分类、标签和服务时长图表提供可读摘要。
- DetailCell 在 `200%` 文字缩放下允许多行显示；AppCard、Dock 指示器、筛选和日期动画遵循“减少动画”设置。

## 验证结果

| 检查项 | 结果 |
| --- | --- |
| `flutter test --no-pub test/accessibility/adaptive_layout_test.dart` | 5/5 通过 |
| `flutter test --no-pub test/l10n/locale_routing_test.dart` | 5/5 通过 |
| `flutter test --no-pub` | 91 个测试全部通过 |
| `dart run tooling/format_check.dart` | 45 个 Dart 文件，0 个变更 |
| `git diff --check` | 通过 |
| `flutter analyze --no-pub` | 0 error、0 warning；仓库现有 493 条 info |
| `flutter build apk --debug --no-pub` | 通过 |

## APK 证据

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 大小：`122,971,949 bytes`
- 生成时间：`2026-08-13T11:28:23.3346558+08:00`
- SHA-256：`4AD6D76BCD738067BC3240DF2A51DD7C5FEAC43DDAA39DF3F83DE2B89E9CBFDB`

## 已知边界

全量测试日志仍会输出仓库原有的 ListTile 背景断言、`features_asset_home.dart` 的 1px RenderFlex 溢出，以及性能基准中的 `Bad state: No element` 记录；本次退出码为 0，未将它们扩大到 B25 范围。当前完成的是代码级、Widget 级和构建级验证，不等同于真实设备上的 TalkBack、VoiceOver、系统字体和多窗口人工验收。
