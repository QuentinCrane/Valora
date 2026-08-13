# VALORA B26 CI、签名与供应链加固验证

## 实施内容

- `.github/workflows/quality-gates.yml` 和 `.github/workflows/release-apk.yml` 的第三方 Action 全部固定到完整 commit SHA；质量门禁增加依赖变更审查，Dependabot 覆盖 GitHub Actions、Pub 和 Android Gradle。
- 发布流程拆为只读构建/证明与 Release 事件写入发布两段：构建 job 只有 `contents: read`、`id-token: write`、`attestations: write`；只有 `release` 事件的发布 job 拥有 `contents: write`。PR 只进入读权限的质量门禁，不进入发布 workflow。
- 发布必须提供以下 GitHub Secrets：`VALORA_RELEASE_KEYSTORE_BASE64`、`VALORA_RELEASE_STORE_PASSWORD`、`VALORA_RELEASE_KEY_PASSWORD`、`VALORA_RELEASE_KEY_ALIAS`。缺少任一项时 job 在构建前失败。
- Android release 配置不再回退到 debug 签名。没有真实 keystore、必需属性为空或签名文件不存在时，`assembleRelease`、`bundleRelease` 等正式打包任务由 Gradle 直接失败。
- CI 同时构建 arm64 APK/AAB，使用 `apksigner`/`jarsigner` 校验证书，生成版本、证书、大小、SHA-256 和 GitHub 运行来源清单，并用 `actions/attest-build-provenance` 对 APK、AAB、清单和 SBOM 做 provenance attestation。
- `tooling/check_supply_chain.dart` 校验所有主/开发直接 hosted 依赖都有第三方声明，并生成 CycloneDX 1.5 Pub SBOM；当前锁定清单包含 27 个 hosted 包。

## 验收结果

| 检查项 | 结果 |
| --- | --- |
| 无签名配置执行 `:app:assembleRelease` | 按预期失败，退出码 1，提示 `Release signing is required` |
| 有正式 keystore 执行 `:app:assembleRelease :app:bundleRelease --no-daemon` | 通过，退出码 0 |
| `dart run tooling/check_supply_chain.dart` | 7 个直接依赖声明通过许可证覆盖检查，生成 27 个 hosted 包 |
| SBOM | `CycloneDX` / `1.5`，`build/release/valora-pub-sbom.json` 可解析 |
| Action SHA 检查 | 所有外部 Action 引用全部为 40 位 commit SHA；本地 reusable workflow 除外 |
| `flutter test --no-pub` | 91 个测试全部通过 |
| `dart run tooling/format_check.dart` | 45 个 Dart 文件，0 个变更 |
| `flutter analyze --no-pub` | 0 error、0 warning；仓库现有 493 条 info |
| `flutter build apk --debug --no-pub` | 通过 |
| APK/AAB 签名校验 | APK `apksigner` 通过；AAB `jarsigner` 通过；两者证书一致 |

## 最终 arm64 产物证据

| 产物 | 大小 | 生成时间 | SHA-256 |
| --- | ---: | --- | --- |
| `build/app/outputs/flutter-apk/app-release.apk` | 32,905,135 bytes | `2026-08-13T11:52:47.6347371+08:00` | `19C4EE0EBA70F196D50C0CA9513D0DC5D7D65F061998B6039840E761BAD1BC04` |
| `build/app/outputs/bundle/release/app-release.aab` | 44,401,996 bytes | `2026-08-13T11:53:12.9512783+08:00` | `216A45288F705B6231E05698071C572470D5CD586522CE229FA08C2A667947F8` |

- 应用 ID：`com.valora.assets`
- 版本：`0.80.1+81`
- APK/AAB certificate SHA-256：`EE7146F09C201A4F82FB303215785A19D915FDF04B2CDE692BA5704DE13ACB90`
- 清单：`build/release/valora-release-manifest.json`

## 本机限制与边界

本机 `flutter build appbundle --release --target-platform android-arm64 --no-pub` 已生成上述新 AAB，但 Flutter CLI 在最后的 native debug-symbol 检查阶段因 Android SDK 缺少 `cmdline-tools` 退出 1；对应 Gradle `bundleRelease` 已以 0 退出，AAB 也已通过 `jarsigner` 校验。这是本机工具链收尾限制，不等同于签名或 Gradle 构建失败；CI runner 仍会执行完整 Flutter 命令。

本块完成的是 CI 配置、脚本、静态/构建/签名验证，不等同于真实 GitHub Actions 运行记录、GitHub attestation 服务端验证或设备安装验收。正式启用发布前，需要在仓库或环境中配置上述四个 Secrets，并在 GitHub 页面确认 attestation 可查询。
