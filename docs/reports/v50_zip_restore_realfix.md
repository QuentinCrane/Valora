# v50 ZIP 恢复真实修复说明

这版专门修复 v49 中“ZIP 资料包无法导入/恢复不完整”的问题。

## 核查到的 v49 风险点

1. **文件选择器 MIME 过滤过窄**
   一些国产文件管理器会把 `.zip` 标记成 `application/octet-stream`、`application/x-zip` 或其他类型，v49 的 `EXTRA_MIME_TYPES` 可能导致 ZIP 根本选不到。

2. **大 JSON 直接通过 MethodChannel 回传不稳**
   资料包大时，恢复 JSON 可能很长。v49 直接把完整 JSON 放进原生返回字符串中，存在不稳定风险。

3. **媒体路径改写不够可靠**
   v49 主要靠文件名猜测图片对应关系。如果文件名经过清洗、存在中文/空格/重复文件名，图片路径可能无法正确改写。

## v50 实际修改

### 1. ZIP 选择器改为完全开放
`importDataArchive` 现在只使用：

```java
openArchive.setType("*/*");
```

并移除 `EXTRA_MIME_TYPES` 限制，避免文件管理器不显示 ZIP。

### 2. 恢复 JSON 写入私有文件，再让 Flutter 读取
原生侧不再强制把完整 JSON 直接塞进返回值。

现在会写入：

```text
files/valora_restore/last_import_*.json
```

返回：

```json
{
  "ok": true,
  "jsonPath": "file:///.../last_import_xxx.json",
  "mediaCount": 3,
  "sqliteCount": 1,
  "entryCount": 9
}
```

Flutter 侧再读取这个私有文件。

### 3. 新增媒体 manifest
导出 ZIP 时新增：

```text
backup/media_manifest.tsv
```

记录：

```text
entry originalPath originalUri originalName
```

恢复时优先使用 manifest 精确改写旧设备图片路径到新设备路径。

### 4. 兼容 v49 旧 ZIP
如果 ZIP 中没有 manifest，仍然会回退到按文件名进行旧版兼容匹配。

## 新增/修改方法

### Android 原生
- `readPrivateTextFile`
- `addMediaFiles` 返回 media manifest
- `applyMediaManifest`
- `restoreDataArchiveFromUri` 重写
- `rewriteArchiveMediaPaths` 增强

### Flutter
- `NativeBridge.readPrivateTextFile`
- `restoreDataArchiveFromPicker` 支持从 `jsonPath` 读取恢复 JSON

## 注意
SQLite 文件仍然不会被直接覆盖。恢复方式仍然是：

```text
ZIP JSON + media
↓
Store.restoreFromJson
↓
Store.save
↓
重新写入当前 SQLite
```

这样比运行中覆盖 `.db/.wal/.shm` 更安全。
