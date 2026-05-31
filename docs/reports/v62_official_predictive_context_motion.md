# v62 官方预测返回 + 场景化视觉层

## 目标
用户要求：在不破坏 Google / Android 官方预测式返回链路的前提下，保留更细致、更花哨的页面动画。

## 真实改法
- 保留 `MaterialPageRoute`。
- 保留 `PredictiveBackPageTransitionsBuilder()`。
- 保留 Android Manifest 的 `android:enableOnBackInvokedCallback="true"`。
- 不再使用 `GestureDetector` 抢左边缘返回手势。
- 在 `PredictiveBackBoundary` 内监听当前 `ModalRoute.animation`，只做轻量视觉叠加。

## 场景化视觉
- 详情页：中心缩小、透明度下降、轻微品牌色焦点光。
- 编辑/新增页：向左下角轻收起。
- 设置页：侧向层级返回。
- 弹层页：向底部收起。
- 分析页：轻缩放和下沉。
- 普通页：轻侧移淡出。

## 说明
这不是重新伪造预测返回。官方系统返回进度仍由 Android + Flutter route transition 驱动；v62 只是在页面内容层额外响应 route animation。
