# V80 教程弹窗、Dock 神奇放大与性能修正

- 首次启动不再自动打开教程 Overlay，而是根据 `onboardingCompleted` 判断是否弹出确认框。
- 未看过教程时弹出“要进入新手教程吗？”；点击“开始教程”才进入真实界面 Overlay。
- 只有教程走到最后并点击完成，才会写入 `onboardingCompleted = true`；选择“暂不”不会写入，下一次启动仍会提示。
- Dock 在按压/滑动时通过 Shell 层同步放大整个 LiquidGlass lens，而不只是放大图标。
- 液态玻璃模式提升捕获清晰度，交互时提高 pixelRatio，并加强 OpticalBorder 与形状折射。
- 设置页预测式返回视觉层减负，去掉重阴影和裁切动画，减少返回过程卡顿。
