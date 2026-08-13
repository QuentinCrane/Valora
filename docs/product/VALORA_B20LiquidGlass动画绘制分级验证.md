# B20 Liquid Glass、动画和绘制分级验证

## 实施范围

- 在 `AppSettings` 中增加 `MotionMode`：完整动效、减少动效、关闭动效，并写入已有设置持久化结构
- 通过 `MediaQuery.disableAnimations` 接入系统减少动效偏好；系统偏好优先于应用档位
- 完整档使用设备刷新率实时捕获，减少档使用缩短动画和中等液态玻璃刷新率
- 关闭档不创建 `LiquidGlassView`，统一回退到已有的 `ClipRRect + BackdropFilter` 轻量毛玻璃路径，不启动场景后台捕获
- 主 Shell 的液态玻璃场景将静态背景作为 `AnimatedBuilder.child` 复用，并在场景外增加 `RepaintBoundary`
- Dock、加号、返回、保存、日期切换等主要交互使用统一的动效时长分级
- 修复贴纸手绘层 `CustomPainter.shouldRepaint` 的无条件重绘，使用笔画签名和快照列表判断变化，并隔离绘制边界

## 验证记录

| 检查项 | 结果 |
| --- | --- |
| B20 聚焦测试 | 通过，4/4 |
| Flutter 全量测试 | 通过，77/77 |
| Dart 分析 | 0 error，0 warning，493 条既有 info |
| 格式门禁 | 35 个非基线 Dart 文件，0 个变化 |
| `git diff --check` | 通过；仅报告已有 CRLF 转 LF 提示 |
| Debug APK | 构建成功；`LastWriteTime=2026-08-13 09:38:59`，122,478,750 bytes，SHA-256 `29A8D5271548D28948A7FB5206D35DC1472D0B9DF04F541F25522338921B0789` |

## 验收边界

主机测试覆盖了动效档位解析、设置往返、关闭档不启用场景液态玻璃和实时捕获。低端参考机滚动 p95、120Hz 设备约 8ms 帧预算和真实 GPU 合成仍需在目标 Android 设备上用 profile/release 包复测；Flutter host test 与 APK 构建本身不等同于设备帧率验证。
