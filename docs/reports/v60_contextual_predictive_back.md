# v60 场景化预测返回动画

基于 v59 源码修复和增强预测式返回体验。

## 修改文件

- `lib/src_parts/common_widgets.dart`
- `lib/src_parts/app_bootstrap.dart`
- `pubspec.yaml`
- `android/app/build.gradle`

## 主要改动

### 1. 详情页 / 卡片页返回

资产详情、心愿详情这类 `detail` 页面现在在手势返回时：

- 不再只是固定侧滑；
- 页面会向中心缩小；
- 透明度同步降低；
- 背景逐渐透出；
- 中央出现淡蓝色焦点光晕，模拟从详情回到卡片列表的聚焦感。

### 2. 不同页面类型对应不同动作

`PredictiveBackBoundary` 按 `ValoraRouteStyle` 区分：

- `detail`：中心缩小消失
- `editor / compose`：向左下角收起
- `settings`：层级侧向返回
- `sheet`：向底部收起
- `analytics`：轻缩放 + 轻偏移
- `plain`：轻侧滑

### 3. 返回提示更细致

手势返回时左上角不再只有固定箭头，而是根据页面类型显示：

- 返回列表
- 返回编辑前
- 返回设置
- 收起页面
- 返回分析

### 4. 动画性能优化

- `PageRouteBuilder` 设置 `opaque: false`，拖拽时能露出上一层页面；
- 页面内容包裹 `RepaintBoundary`；
- 触感反馈只在少数进度阈值触发，不逐帧震动；
- 详情页反向动画中心缩小到约 0.76 起始尺度，强化“回到卡片”的感觉。
