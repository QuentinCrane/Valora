# Valora Flutter 安卓版 v6 深度审计与完善说明

## 这次重新检查了什么

### 1. 有数 APK 解包痕迹（只做技术栈学习，不复用代码）

从你上传的解包内容和 `libapp.so` 字符串中，可以确认该类应用不是普通网页套壳，而是 Flutter 体系为主，常见痕迹包括：

- `assets/flutter_assets/`
- `libflutter.so`
- `libapp.so`
- `FlutterActivity`
- `realm` / `realm_dart`
- `fl_chart`
- `flutter_inappwebview`
- `flutter_local_notifications`
- `flutter_screen_lock`
- 资产、分类、标签、心愿、统计、备份、密码安全、会员/支付等页面/服务命名痕迹

v6 仍然保持 clean-room：只学习“Flutter + 本地优先 + 生命周期资产管理”的开发方法，不还原或复制任何商业源码、图片、品牌、接口和像素级布局。

### 2. 你的 Vue 项目

重点重新参考了：

- `HANDOFF.md`：页面结构、底部 Dock、FAB、二级页返回、视觉风格说明；
- `src/pages/AssetHome.vue`：资产总览、视图切换、搜索/筛选/排序、多视图资产列表；
- `src/pages/AssetDetail.vue`：基础信息、生命周期、目标进度、日均成本趋势；
- `src/pages/AssetEditor.vue`：资产字段、附加项、状态、目标、提醒；
- `src/pages/WishHome.vue` / `WishEditor.vue`：心愿预算、归档、转资产；
- `src/pages/AnalyticsHome.vue`：资产趋势、分类/标签分布、服役时长、日耗排行；
- `src/pages/SettingsHome.vue`：分类标签管理、主题、货币、小数位、备份快照；
- `src/domain/formulas.ts` 和 `src/utils/assetMetrics.ts`：日均成本、实际损耗、目标天数、趋势、分布等计算思路。

### 3. 当前 Flutter v5 工程

检查了：

- Dart part 文件结构；
- 本地 JSON 存储和 Android `MethodChannel`；
- 页面跳转与弹窗；
- 资产/心愿/分类/标签 CRUD；
- 统计聚合方法；
- 可能导致运行时崩溃的重复 Hero tag；
- Gradle / Manifest / Android MainActivity / 构建脚本。

## v6 具体新增与修正

### 1. 修复一个重要运行时风险：重复 Hero tag

v5 的 `AssetIcon` 默认包了一层 `Hero(tag: asset.id)`。当同一个资产同时出现在首页列表和“钱包漏洞警报”中时，一个路由里会出现多个相同 Hero tag，Flutter 可能直接抛异常。

v6 已去掉全局 Hero 包裹，改成稳定的 `AnimatedContainer`，优先保证首页不崩。

### 2. 增加全局卡片入场动效

`AppCard` 现在有轻量淡入 + 上浮动效。这样首页、分析、详情、设置里的卡片会更接近 Vue 版的“轻量动效”观感。

### 3. 新增资产健康度

新增 `PortfolioQualityCard`：

- 目标覆盖率；
- 标签覆盖率；
- 待复盘风险数；
- 已完成流转数；
- 0—100 本地健康评分；
- 自动给出下一步建议。

### 4. 新增分析页价值象限

新增 `ValueQuadrantCard` / `ValueQuadrantChart`：

- 横轴：服役天数；
- 纵轴：日均成本；
- 帮助区分“长期低耗”“高耗短用”“仍需观察”的资产。

### 5. 新增快照对比

新增 `SnapshotCompareCard`：

- 当前资产数量 vs 最近快照；
- 当前心愿数量 vs 最近快照；
- 当前净值 vs 最近快照；
- 当前日耗 vs 最近快照。

这让“资产时光机”不只是保存 JSON，而是能开始产生可视化复盘价值。

### 6. README / 版本 / 构建脚本更新

- `pubspec.yaml` 升级到 `0.6.0+6`；
- Android `versionCode` / `versionName` 已更新；
- README 更新为 v6；
- 构建脚本提示更新为 v6。

## 仍然无法在本环境完成的验证

当前容器没有 Flutter / Android SDK / Gradle Wrapper，因此无法真实执行：

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

我已经完成源码级检查、括号平衡检查、zip 完整性检查和明显运行时风险修复。最终 APK 编译仍需要你本机或 Codex 具备 Flutter Android 环境。

## 下一轮如果本机编译报错，优先排查顺序

1. Flutter 版本是否过旧；建议 Flutter 3.22+。
2. 如果 `CardThemeData` 报错，说明 Flutter 版本偏旧，可把它改成 `CardTheme`。
3. 如果 Android Gradle 插件版本不兼容，运行 `flutter create --platforms=android --project-name valora_assets --org com.valora .` 修复 Android 壳。
4. 如果 Java 版本错误，使用 JDK 17。
5. 如果 `flutter analyze` 给出 Dart API 差异，按报错行逐条修正。

