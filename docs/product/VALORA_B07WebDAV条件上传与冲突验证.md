# VALORA B07：WebDAV 条件上传与冲突验证

## 目标

把云端入口从“整份 JSON 直接覆盖”收敛为可验证的远程备份：

- 仅接受 HTTPS WebDAV 地址；测试环境只放行 loopback HTTP
- 上传和下载均有 10 MB 请求/响应上限、连接/读取超时和安全路径校验
- 上传记录 SHA-256 内容哈希和 ETag；已有远端资源使用 `If-Match`，首次创建使用 `If-None-Match: *`
- ETag 不一致、HTTP 409 或 412 进入冲突状态，不自动重试覆盖
- 下载先做 JSON/schema/引用校验；手动恢复沿用确认弹层，并保留当前已验证快照作为回滚点
- 启动时拉取只在本机内容哈希与远端一致时自动应用，否则进入冲突页
- 保存后的自动上传通过唯一 WorkManager 任务 `valora-cloud-backup`，带联网约束和指数退避

## 实现位置

- `lib/src_parts/models.dart`
  - `CloudSyncSettings` 保存远端 ETag、内容哈希、资产/心愿摘要和远端修改时间
- `lib/src_parts/store.dart`
  - `CloudSyncService` 负责 HTTPS、超时、响应上限、摘要、SHA-256、条件请求
  - `AppStore` 负责上传元数据持久化、下载预检、回滚和冲突状态
- `lib/src_parts/features_settings.dart`
  - 增加云端冲突入口；用户只能明确选择保留本机或从云端恢复
- `lib/src_parts/native_services.dart`
  - 自动上传改为调用唯一后台任务
- `android/app/src/main/java/com/valora/assets/CloudBackupWorker.java`
  - WorkManager 联网任务；后台读取本地快照和 Keystore 凭据，使用相同的条件上传规则
- `android/app/build.gradle`
  - `androidx.work:work-runtime:2.11.2`
- `test/repository/cloud_sync_test.dart`
  - fake WebDAV 覆盖首次条件上传、无变化跳过、ETag 冲突、下载摘要和非回环 HTTP 拒绝

## 验证结果

执行目录：`E:\Github Program\Valora\valora_app`

```text
flutter pub get                         通过，新增 crypto 3.0.7
flutter test --no-pub test/repository/cloud_sync_test.dart
                                         3/3 通过
flutter test --no-pub                    25/25 通过
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
                                         退出码 0；502 条既有 info，0 warning/error
dart run tooling/format_check.dart       待最终门禁时执行
git diff --check                         通过（仅 Java/pubspec 的 CRLF 提示）
flutter build apk --debug --no-pub       通过
```

最终 B07 APK：

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 生成时间：`2026-08-12 23:22:25`
- 大小：`121613254` bytes
- SHA-256：`755FF04C7B1393BAB5C1DA4AFDC71075730778A45CC2284035F03CA20A2B8868`

## 边界

当前已验证 Dart fake server、协议条件和 Android 编译；尚未进行真实 HTTPS WebDAV 服务、Android 设备后台重启、系统断网恢复、WorkManager 实际执行、TLS 证书错误、超大响应和真实冲突页面的设备验收。这些属于 B07 的设备/环境验收，不把 APK 构建结果等同于设备验证。
