# v8 UI 重构说明

## 改动来源

本轮根据用户新提供的三张参考图继续精修：

1. 图标选择器：顶部“取消 / 相册 / Emoji / 3D 图标 / 确定”、分类横向标签、五列网格。
2. 新增资产页：顶部关闭、资产/心愿切换、中央图标、标题输入、卡片式表单、底部保存按钮。
3. 心愿首页：大标题、右侧下拉、总值卡片、空状态、底部液态玻璃导航 + 右端加号。

## 关键实现

- `shell.dart`：重写为 `LiquidDock`，导航栏与加号分离；加号位于右端。
- `features_wishes.dart`：重写 `ComposePage`，点击加号直接进入资产/心愿统一新增页。
- `common_widgets.dart`：新增 `IconPickerSheet`、`EditableIconPreview`、`SoftFormCard`、`FormLine`、`ComposeSegmentedTabs`。
- `features_asset_home.dart`：首页移除重型分析模块，仅保留资产列表核心操作。
- `features_analytics.dart`：承接首页迁出的生命周期看板、资产体检、钱包漏洞、时光机、到期提醒等。
- `app_bootstrap.dart`：字体改为系统 `sans-serif`，并微调背景色和页面转场。

## 设计原则

- 不做第三方商业 App 的像素级复制。
- 模仿的是信息架构、页面密度、表单组织方式和动效方向。
- 所有代码均为当前工程内原创实现。
- 保留原 Vue 迁移版已有的数据结构、备份恢复、分析聚合和本地存储。

## 后续建议

下一轮最应该交给 Claude Code 做：

```text
1. 运行 flutter analyze；
2. 按报错做最小修复；
3. 运行 flutter build apk --debug；
4. 真机检查新增页、图标选择器、心愿页、首页列表、分析页是否有布局溢出；
5. 再做动效微调和空状态精修。
```
