# VALORA B17 懒列表与 Sliver 验证

## 范围

- 新增可复用的 `SliverPageFrame`，用 `SliverChildBuilderDelegate` 按可见区块构建长页面
- 首页资产网格和列表改为 `SliverGrid` / `SliverList` builder，心愿卡片改为懒构建
- 首页、心愿、分析页面增加稳定的 `PageStorageKey`
- 资产与心愿卡片使用业务 ID 作为稳定 key，减少滚动和筛选后的状态错位
- 贴纸卡片改为服从 SliverGrid 单元格约束，避免依赖屏幕宽度的固定宽度

## 验证门槛

| 检查 | 结果 |
| --- | --- |
| `flutter test --no-pub test/performance/sliver_surface_test.dart` | 1/1 通过 |
| `flutter test --no-pub` | 66/66 通过 |
| `flutter analyze --no-pub --fatal-warnings --no-fatal-infos` | 0 error、0 warning，既有 info 493 条 |
| Dart 格式检查 | 33 个 Dart 文件通过，0 个变更 |
| `git diff --check` | 通过 |
| Debug APK 新鲜构建与哈希 | `2026-08-13 04:35:26`，121,694,288 bytes，SHA-256 `6C8DFDF19B82A88C29DF631E3973057A9C752B05D140BE384A35088D2AE3F835` |

## 边界

本块验证的是 Flutter widget 层的懒构建和滚动结构，不等同于真机滚动 p95 测量。图片解码尺寸、2,000 条真实数据下的设备帧耗时和跨设备滚动位置恢复仍需在后续性能矩阵中补充；现有 host benchmark 中记录的框架异常也不作为设备验证结论。APK 构建成功，但未进行设备安装或真机交互验证。
