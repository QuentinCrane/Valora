# VALORA B13 媒体选择、相机与主体分割验证

## 范围

- 图库在 Android 13+ 优先使用 Photo Picker，旧版本保留 `ACTION_OPEN_DOCUMENT` 回退
- 所有原生外部 Activity 结果统一经过 Activity Result Registry，并持久化 pending operation
- 相机通过专用 `valora_capture/` 目录和 FileProvider `EXTRA_OUTPUT` 输出全分辨率图片
- 外部图片先复制到应用私有媒体目录，使用临时文件原子落盘，并限制 256 MiB 单文件输入
- EXIF 方向在主体分割前应用，避免设备旋转后裁切方向错误
- ML Kit Subject Segmentation 等待 `getInitTask()`，状态明确为 `downloading`、`ready` 或 `unavailable`
- 模型不可用时保留离线启发式主体轮廓，但详细结果带 `modelStatus`，不再把回退伪装成 ML Kit 成功
- FileProvider 只暴露 `cache/share/` 和 `files/valora_capture/`

## 已执行检查

| 检查 | 结果 |
| --- | --- |
| `flutter test --no-pub` | 53/53 通过 |
| `flutter analyze --no-pub --fatal-warnings --no-fatal-infos` | 退出 0；492 条既有 info，无 warning/error |
| `dart run tooling/format_check.dart` | 通过；未改动基线排除文件 |
| `git diff --check` | 通过；仅有 Windows LF/CRLF 提示 |
| `:app:testDebugUnitTest --no-daemon --offline` | BUILD SUCCESSFUL；30 tasks，原生测试通过 |
| Debug APK | 构建后核对路径、写入时间和 SHA-256 |

## 设备验收矩阵

以下项目需要在 Android 7、10、13+ 真机或对应模拟器上执行；本次仓库验证未将静态检查、单元测试或 APK 构建冒充设备验证。

| 场景 | 预期 |
| --- | --- |
| Android 7 / 10 / 13+ 选择图片 | 分别走文档选择器或 Photo Picker，取消返回取消态 |
| 拒绝相机权限 | 原生桥返回 `permission_denied`，不留下 capture 文件 |
| 相机拍摄 | 相机写入 FileProvider 全分辨率输出；没有输出文件时返回失败 |
| 旋转、后台回收后返回 | pending request 可由 Activity Result Registry 接回；进程重启且无回调时发出恢复取消事件并清理状态 |
| 取消选择、超大图 | 取消不落盘；超过 256 MiB 拒绝且删除临时文件 |
| 主体模型首次使用 | 状态先为 `downloading`，初始化完成后为 `ready` |
| 离线或模型不可用 | 状态为 `unavailable`，详细结果明确标注并使用离线轮廓回退 |
