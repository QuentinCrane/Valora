# v74 真实控件定位版新手教程

- 删除上版教程中的手算 `Rect.fromLTWH` 目标坐标。
- 新增 `TutorialTargetAnchor` / `_TutorialTargetRegistry`，由真实控件在布局完成后注册 RenderBox 位置。
- 新手教程扩展为首页、Dock、新增资产、附加项目、心愿页、分析页、资产详情页、设置首页和三个设置二级菜单。
- 切换步骤后会尝试 `Scrollable.ensureVisible`，让被讲解控件先滚入可见区域，再绘制遮罩。
- 继续保留 v73 的二级菜单入场不闪、小字完整折行、编译坑修复。
