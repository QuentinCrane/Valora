# V27 SQLite 数据持久化与 1970 日期修复说明

## 这次真正修了什么

1. Android 本地存储从 `SharedPreferences` 改为原生 SQLite。
   - 文件：`android/app/src/main/java/com/valora/assets/MainActivity.java`
   - 数据库：`valora_assets_local.db`
   - 表：`kv_store(k TEXT PRIMARY KEY, v TEXT, updated_at INTEGER)`
   - MethodChannel 仍然使用 `valora/local_store`，Flutter 侧无需大规模重写页面。

2. 增加旧数据迁移。
   - 如果 SQLite 里为空，会尝试从旧的 `SharedPreferences` 读取 `payload_json` 并写入 SQLite。
   - 这样从旧版本升级到 v27 时不会直接丢失已有数据。

3. 修复 `1970-01-01` 日期回退问题。
   - 旧逻辑中 `parsePersistedDate()` 在解析失败时会回退到 `DateTime(1970, 1, 1)`。
   - v27 改为：解析失败时优先使用有效 fallback；fallback 无效时用当前时间，不再产生 1970。
   - 同时把 1970/1971 这类 epoch 默认值视为无效日期。

4. 日期兼容增强。
   - 支持 ISO 字符串、`2026-05-24`、`2026/5/24`、`2026年5月24日`。
   - 兼容误存的秒级/毫秒级时间戳，但 `0` 或 epoch-like 值会被视为缺失。

## 为什么之前会回到 1970-01-01

根因是这行旧代码：

```dart
DateTime parsePersistedDate(dynamic raw, {DateTime? fallback}) =>
  parseFlexibleDate(raw?.toString() ?? '') ?? fallback ?? DateTime(1970, 1, 1);
```

当 `purchaseDate` 为空、字段名不兼容、JSON 恢复异常、云端旧备份覆盖，或者保存时某些值没有落盘时，日期解析会失败。旧逻辑失败后直接用 `DateTime(1970, 1, 1)`，所以你会看到购买日期变成 1970-01-01。

## 还需要注意

SQLite 只能保证本地保存更可靠；如果你手动从旧 JSON 或旧 WebDAV 备份恢复了错误数据，旧备份里本身没有真实购买日期，那么 App 不可能凭空恢复原日期。v27 会避免它变成 1970，但真实日期需要你重新设置一次，之后会稳定保存到 SQLite。

## 建议测试

1. 安装 v27。
2. 新建资产，购买日期设为 `2024-01-03`。
3. 保存，杀掉 App 后重进。
4. 确认日期仍为 `2024-01-03`。
5. 编辑为 `2023-12-20`，保存，杀掉 App 后重进。
6. 测试到期日期、退役日期、卖出日期。
7. 尽量先关闭 WebDAV 的“启动拉取”，避免旧云端备份覆盖本地新数据。
