# 数据库升级路线：从 JSON 到本地数据库

当前版本使用 Android SharedPreferences 保存整份 JSON。这种方式适合原型和学习，但正式资产管理 App 建议升级为本地数据库。

## 当前存储结构

```text
AppStore
└─ LocalJsonStorage
   └─ MethodChannel('valora/local_store')
      └─ Android SharedPreferences
```

## 推荐升级路线

### 第一阶段：Repository 抽象

先不要直接换数据库，先增加接口：

```dart
abstract class AssetRepository {
  Future<List<Asset>> findAll();
  Future<void> upsert(Asset asset);
  Future<void> delete(String id);
}
```

同理增加：

```text
CategoryRepository
TagRepository
WishRepository
SettingsRepository
SnapshotRepository
```

### 第二阶段：JSON Repository

先把现在的 JSON 存储包装成 Repository，确保 UI 不直接依赖存储实现。

### 第三阶段：替换数据库

可以选：

| 方案 | 优点 | 适合情况 |
|---|---|---|
| Isar | Flutter 生态友好，查询快，写法舒服 | 个人资产 App 首选 |
| SQLite | 稳定通用，迁移容易 | 想长期可控 |
| Realm | 接近参考 App 技术栈 | 想学习类似架构 |

## 字段迁移建议

保留当前模型字段：

- `Asset`
- `Wish`
- `Category`
- `Tag`
- `AddonItem`
- `AppSettings`
- `SnapshotRecord`

新增建议字段：

```text
Asset.imagePaths       # 本地图片路径
Asset.usageCount       # 使用次数
Asset.location         # 物品位置
Asset.condition        # 成色/状态
Asset.source           # 购买渠道
Asset.serialNumber     # 序列号/保修编号
Asset.deletedAt        # 软删除
Asset.archivedAt       # 归档时间
```

## 备份格式不要丢

即使使用数据库，仍建议保留：

```text
导出 JSON
导入 JSON
本机快照
```

因为个人资产数据非常适合用户自己备份、迁移和长期保存。
