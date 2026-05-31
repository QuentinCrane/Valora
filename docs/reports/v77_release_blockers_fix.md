# Valora V77 发布阻塞修复记录

本版本基于用户上传的 `valora_app.zip` 继续修改，重点处理发布前阻塞问题。

## 1. 新手教程无法完成 / 只能返回退出

- 为 `OnboardingTutorialPage` 增加关闭保护，避免连续点击“完成 / 返回 / 跳过”时重复 pop 或重复写入设置。
- 返回键现在会走统一 `_close`，并在允许时写入 `onboardingCompleted`，避免教程状态卡住。
- 教程目标定位改为多次延迟 settle，并加入当前步骤校验，防止上一步异步定位覆盖下一步。
- 教程说明气泡增加最大高度约束和滚动能力，避免小屏设备上按钮被挤出屏幕导致无法点“完成教程”。

## 2. Android 系统图片选择 API

- Dart 端 MethodChannel 统一改为 `valora/native` 与 `valora/local_store`，修复 Dart/Java 通道名不一致导致原生选择图片无法稳定调用的问题。
- Android 13+ 优先调用系统 Photo Picker action：`android.provider.action.PICK_IMAGES`。
- 低版本或系统不支持时回退到 `ACTION_OPEN_DOCUMENT`。
- 仍然在选择后复制到 App 私有目录，避免导入后图片 URI 权限失效。

## 3. 新建资产的日耗目标

- “日耗目标”从普通下拉改为四段式切换：不设定 / 按日耗 / 按周期 / 自定义。
- `按周期` 显示目标达成日期选择字段，并保存到 `targetDate`。
- `自定义` 显示目标使用天数字段，并保存到 `targetCustomDays`。
- 切换时增加 `AnimatedSwitcher + AnimatedSize`，字段区域不会硬切。
- 保存时增加校验：按日耗必须大于 0，按周期必须选择日期，自定义天数必须大于 0。

## 4. Valora 命名统一

- Flutter 包名改为 `valora_assets`。
- Android `namespace` / `applicationId` / widget / deep link / native channel / local store channel 改为 Valora 体系。
- 应用名称、组件名称、小组件名称、默认备份路径和导出文件名前缀改为 Valora / valora。
- 为降低发布前风险，部分内部 Dart 函数名仍保留旧标识，但不再作为用户可见名称、包名、通道名或 Android 组件名暴露。

## 5. 导入数据后资产图标显示异常

- 修复贴纸/白框裁切图导入后文件名被 `restored_...` 前缀包裹，导致识别不到 `framed_cover_` / `manual_trace_sticker_` / `cutout_` 的问题。
- 现在按文件 basename 判断贴纸类型，导入后的裁切白框、手动勾勒、AI 贴纸仍按完整方形圆角展示，不会被首页图标容器二次裁切。
