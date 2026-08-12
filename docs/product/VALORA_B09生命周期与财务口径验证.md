# VALORA B09：生命周期与财务口径验证

## 目标

让资产详情、分析页、生命周期时间线和首页摘要使用同一组生命周期与财务公式：

- 服务天数按购买日和生命周期结束日的包含首尾日期计算；未来购买日不产生服务天数
- 售出/退役后服务天数停止增长，日耗趋势保留结束时的分母，不继续摊薄
- 资产总投入统一为基础价格加计入总额的附加项
- 日耗按计入日耗的附加项计算，并按指定日期的售出/回收状态计算
- 净成本允许为负，超额售出或回收不被静默截断
- 多资产回收按稳定资产 ID 分摊；同日生命周期事件用稳定排序键展示
- 分类和标签分析按稳定 ID 聚合，显示时再本地化，重名不会合并
- 详情页移除没有数据依据的固定进度条

## 实现位置

- `lib/src_parts/models.dart`
  - 增加 `serviceDaysAt`、`serviceEndDateAt`、`acquisitionCostAt`、`netCostAt` 和 `dailyCostAt`
  - 统一附加项生效日期、售出日期和日耗口径
- `lib/src_parts/store.dart`
  - 生命周期趋势复用资产公式并纳入按日期生效的回收记录
  - 保留负净成本；统一总投入、售出损益和生命周期净消耗
  - 分类/标签按 ID 聚合，生命周期事件和同日回收记录稳定排序
- `lib/src_parts/features_analytics.dart`
  - 聚合结果在展示层通过 ID 解析本地化名称
- `lib/src_parts/features_asset_detail.dart`
  - 详情净成本、回收摘要、趋势说明和趋势图复用统一公式
  - 删除固定 `.48/.54/.64` 的伪进度条
- `test/analytics/lifecycle_semantics_test.dart`
  - 覆盖购买当天、跨日、未来日、零成本、售出、退役、超额回收、共享回收、日耗趋势、同日事件和稳定 ID 聚合

## 验证结果

执行目录：`E:\Github Program\Valora\valora_app`

```text
flutter test --no-pub test/analytics/lifecycle_semantics_test.dart
                                         6/6 通过
flutter test --no-pub                    39/39 通过
flutter analyze --no-pub --fatal-warnings --no-fatal-infos
                                         退出码 0；499 条既有 info，0 warning/error
dart run tooling/format_check.dart       21 个文件通过，0 变更；5 个基线排除
git diff --check                         通过
flutter build apk --debug --no-pub       通过
```

最终 B09 APK：

- 路径：`build/app/outputs/flutter-apk/app-debug.apk`
- 最后写入时间：`2026-08-13 00:06:19`
- 大小：`121629530` bytes
- SHA-256：`1C5AE75EF7896D3D4AABBE208CD95E495E962C61B3CCDF21F9007F681320047B`

## 边界

本块验证了 Dart 公式、内存聚合和 Flutter 代码编译路径，未进行真实 Android 设备上的时区切换、跨午夜系统时间变化、图表截图验收或大数据量 profile。设备与性能验收保留到后续规划块。
