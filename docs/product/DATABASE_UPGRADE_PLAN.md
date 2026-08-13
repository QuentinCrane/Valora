# 数据库与持久化路线

> 状态更新：2026-08-13。本文档早期标题是“从 JSON 到本地数据库”；B19 之后 SQLite 已经是当前实现，下面的“升级路线”只描述未来是否需要进一步规范化，不再把 SQLite 迁移当作未完成能力。

## 当前存储结构

```text
AppStore
└─ LocalSqliteStorage
   └─ MethodChannel('valora/local_store')
      └─ MainActivity.LocalStoreDb
         └─ SQLite: valora_assets_local.db / kv_store
```

`kv_store` 当前保存两个受控 payload：`app_payload_json` 和
`last_validated_payload_json`。数据库 schema version 为 `1`；Flutter 导出格式
`exportSchemaVersion` 为 `3`。JSON 仍是稳定的导入/导出边界，数据库内部实现不应改变备份文件的字段语义。

## 写入与恢复语义

- 读取返回 `empty`、`success` 或 fatal failure；数据库/通道错误不能伪装成空数据，应用进入可恢复的只读状态。
- 每次写入由 `SaveCoordinator` 串行化，写入后回读并与目标 JSON 比较，再写入最后验证快照。
- 导入先执行 schema、主键、引用、枚举、日期和媒体引用校验，再通过 staging/原子提交落盘。
- 恢复默认保留当前 snapshot history；显式恢复可先创建恢复前快照，失败时回滚到内存或最后一次验证快照。
- 备份中的 WebDAV 凭据会被移除；Android Keystore 密钥和加密凭据 SharedPreferences 不进入 Android 系统备份或导出 ZIP。

## 当前数据边界

保留并由 JSON schema 覆盖的主要模型：

- `Asset`
- `Wish`
- `Category`
- `Tag`
- `AddonItem`
- `AppSettings`
- `SnapshotRecord`
- `ValueRecoveryRecord`、`ReminderRecord`

数据库只负责可靠保存经过验证的整体 payload；业务模型、财务口径、迁移和导入导出仍由 Flutter `store.dart` 统一管理。不要直接在 Widget 或 Android Provider 中另建一套资产数据源。

## 可选的后续路线

如果资产规模、查询需求或增量同步需要规范化表结构，可按以下顺序推进，并保持 JSON v3 兼容：

1. 为 `AssetRepository`、`WishRepository`、`SnapshotRepository` 等增加明确接口，先不改变当前 payload。
2. 增加 SQLite migration table 和可回滚迁移测试；每次迁移都要能从现有 `kv_store` JSON 重建。
3. 评估将高频查询字段拆为表，但保留 JSON 导出、快照恢复和旧版文件名兼容。
4. 只有在迁移、备份、云同步冲突和 Android 升级路径均有测试后，才改变默认内部结构。

当前不建议把 Isar、Realm 或另一套数据库引入生产包；这会扩大迁移、许可证、体积和恢复风险，而当前 SQLite + JSON 边界已经满足产品数据规模。
