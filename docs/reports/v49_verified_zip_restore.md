# v49 完整资料包 ZIP 恢复说明

本版重点补齐 v48 缺失的 ZIP 导入恢复闭环。

## 已实现

1. Flutter 侧新增：
   - `NativeBridge.importDataArchive()`
   - `restoreDataArchiveFromPicker(BuildContext context)`

2. Android 原生侧新增：
   - `importDataArchive` 方法通道
   - `REQ_OPEN_ARCHIVE`
   - `restoreDataArchiveFromUri(...)`
   - `rewriteArchiveMediaPaths(...)`

3. 恢复流程：
   - 选择 ZIP
   - 读取 `backup/valora_backup.json`
   - 解压 `media/` 下的封面、贴纸、手动勾勒图片到当前 App 私有目录
   - 尝试把 JSON 中旧设备的本地图片路径改写为新复制的图片路径
   - 二次确认
   - 恢复前自动创建快照
   - 调用现有 Store 恢复 JSON，并通过现有保存链路写入 SQLite

## SQLite 恢复策略

ZIP 中的 `sqlite/` 文件不会直接覆盖当前运行中的数据库。
原因是 Android App 运行时数据库可能打开，直接覆盖 `.db/.wal/.shm` 有损坏风险。

本版采用更稳的方式：

`ZIP -> JSON + media -> Store.importMap -> Store.save -> 当前 SQLite 重建`

这符合用户要求的 SQLite 存储方式，同时避免直接替换运行中数据库。

## 已知限制

- 通过文件名映射媒体路径；若两个媒体文件同名，可能只能命中最后一个副本。
- 直接恢复 SQLite 文件仍未开放为普通入口，需要未来做成高级恢复模式并提示重启 App。
