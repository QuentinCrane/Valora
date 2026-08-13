# B21 分析缓存与事件模型验证

## 实施范围

- `AppStore.analyticsSnapshot` 改为使用递增 `analyticsRevision` 和本地日期作为缓存键，不再每次 getter 访问都扫描资产、心愿和回收记录拼接长字符串
- 所有现有数据变更入口继续通过 `_invalidateAnalytics()` 递增 revision；跨自然日访问时自动重建趋势和日均成本结果
- 分类与标签聚合继续使用 `categoryId`、`tagId` 作为稳定键，显示名称只在 UI 层解析，不把可变名称写进聚合结果
- 复盘页的最新快照比较改为按 `SnapshotRecord` 实例缓存解析结果；无关的 store rebuild 不会重复 `jsonDecode`、资产反序列化和汇总计算

## 估值事件账本 PoC 决策

候选事件结构为：

```text
ValuationEvent {
  eventId, assetId, eventDate, kind, amount, sourceId
}
kind = acquisition | addon | recovery | sale | estimate
```

其中 acquisition/addon/sale 可以从现有资产和附加项得到，recovery 需要按当日有效资产集合分摊，estimate 只能表示某个时点的观察值，不能直接当成现金流。B21 只完成事件字段和迁移边界评估，不把它替换为当前持久化事实源：现有 `Asset` 生命周期、回收记录约束和日均成本回归需要先建立逐事件 fixture，确认迁移前后逐项一致后再进入独立数据模型块。

## 验证记录

| 检查项 | 结果 |
| --- | --- |
| B21 聚焦测试 | 通过，analytics cache 回归 1/1 |
| Flutter 全量测试 | 通过，78/78；仅保留既有 UI warning、1px overflow 和性能基准日志 |
| Dart 分析 | 0 error，0 warning，493 条既有 info |
| 格式门禁 | 36 个非基线 Dart 文件，0 个变化 |
| `git diff --check` | 通过；仅报告已有 CRLF 转 LF 提示 |
| Debug APK | 构建成功；`LastWriteTime=2026-08-13 09:48:44`，122,478,394 bytes，SHA-256 `A46AB1A9A09C96EEA9B3051FC6115663A5EE45757698CBEA58804A83A3925923` |
| 稳定 ID | 分类和标签聚合结果保持 ID 键，不受显示名变化影响 |
| 快照解析边界 | 缓存条件为同一 `SnapshotRecord` 实例；替换记录或 payload 后重新解析 |

## 验收边界

本块证明了同一 revision 下 analytics getter 返回同一不可变快照，并验证数据导入导致 revision 变化后结果和稳定 ID 正确更新。事件账本仍是 PoC 决策，不改变现有财务口径；完整事件迁移、历史数据回放和真机性能数据应在后续独立块中完成。
