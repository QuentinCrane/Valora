# Valora v5 自检与完善说明

## 边界说明

本工程是 clean-room 学习实现：参考公开功能方向和用户自己的 Vue 源码，不复用第三方商业 App 的源码、素材、品牌、接口或像素级页面。

公开功能方向主要抽象为：万物资产化、真实日耗计算、进度可视化、闲置流转复盘、资产总览看板、钱包漏洞警报、资产时光机。

## 本轮 v5 修正内容

### 1. 编译与工程完整性

- 保留 Flutter + Android 原生 MethodChannel 结构。
- 补强 `build_windows.bat` 与 `build_android.sh`：
  - 检测 Flutter 命令；
  - 如果 Gradle Wrapper 缺失，尝试通过 `flutter create --platforms=android` 自动补齐；
  - 依次执行 `flutter pub get`、`flutter analyze`、`flutter build apk --debug`。
- 更新 README 到 v5 说明。
- 对 Dart 文件做了括号/花括号平衡检查。

### 2. 逻辑 bug 修正

- 修正附加项目金额计算：
  - `addonTotal` 只统计“计入总资产”的附加项目；
  - `dailyAddonTotal` 只统计“计入日均成本”的附加项目。
- 修正删除分类后的资产归类清理逻辑：旧版 `copyWith(categoryId: null)` 无法真正清空 nullable 字段，v5 改为重建 Asset 对象并将 `categoryId` 置空。
- 分类/标签/备份管理页增加控制器释放，降低长期运行内存泄漏风险。
- 分类/标签新增操作改为在局部 `setState` 中执行，弹层内列表可以更稳定地即时刷新。

### 3. 功能完整性复核

当前 v5 覆盖：

- 资产首页：总览、状态筛选、分类筛选、搜索、排序、三种视图。
- 资产生命账本：累计投入、当前净值、二手回收、生命周期净消耗。
- 钱包漏洞警报：高日耗、闲置/吃灰、目标进度慢、临期提醒。
- 资产时光机：本机快照、生命周期事件流、长期价值地图。
- 资产详情：摘要指标、真实日耗趋势、目标进度、流转复盘、时间线、附加项、备注、编辑/删除。
- 新增/编辑资产：分类、标签、买入价、购买日期、状态、退役/卖出、目标成本、到期提醒、附加项目。
- 心愿：心愿预算、进行中/已归档、编辑、归档、转资产。
- 分析：分类占比、标签分布、日均排行、服役时长、资产体检、生命周期事件。
- 设置：分类管理、标签管理、备份恢复、主题、首页风格、货币、小数位、提醒、重置示例。
- 本地存储：Android SharedPreferences + Flutter MethodChannel。

## 当前环境限制

此生成环境未安装 Flutter / Android SDK，因此无法在容器内实际执行 `flutter analyze` 或 `flutter build apk`。v5 已尽量按 Flutter 工程规范组织，并提供本地构建脚本。请在本机运行：

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

或 Windows 直接运行：

```bat
build_windows.bat
```

如果本机首次构建提示 Gradle Wrapper 缺失，构建脚本会尝试自动运行 `flutter create --platforms=android --project-name valora_assets --org com.valora .` 来补齐 Android 构建壳。

## 下一步建议

如果 v5 本地 `flutter analyze` 通过，下一步可以继续升级：

1. 从 Dart `part` 文件升级到真正的 import-based feature-first 架构。
2. 把 SharedPreferences JSON 存储替换为 Isar / SQLite / Realm。
3. 接入图片选择、本地通知、CSV/JSON 文件导入导出。
4. 增加 Widget 测试和数据模型单元测试。
5. 增加更精细的页面转场和资产卡片入场动画。
