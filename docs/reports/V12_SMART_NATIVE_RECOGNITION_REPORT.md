# V12 Smart Native Recognition Report

本版在 V11 Android 原生能力基础上继续接入媒体识别与真实封面能力。

## 已接入

1. **真实资产封面持久化**
   - Android Photo Picker / ACTION_OPEN_DOCUMENT 返回的图片会复制到 App 私有目录 `files/valora_media/`。
   - Flutter 侧 `Asset.iconValue` 支持保存 `file://...`，资产列表、详情入口和新增页预览会显示真实图片。
   - 系统相机 Intent 返回的缩略图会保存为本地 jpg。

2. **条码 / 二维码识别**
   - Android 侧接入 ML Kit Barcode Scanning。
   - Flutter 新增页和编辑页提供“扫条码”入口。
   - 识别结果会写入资产草稿：名称、标签、备注。

3. **小票 OCR 识别**
   - Android 侧接入 ML Kit Text Recognition Chinese。
   - Flutter 新增页和编辑页提供“小票 OCR”入口。
   - 会尝试提取价格、日期、标题，并把完整 OCR 文本写入备注。

4. **设置页原生媒体面板增强**
   - 增加相册持久化、拍照、条码扫描、小票 OCR 测试入口。

## 新增 Android 依赖

```gradle
implementation "com.google.mlkit:barcode-scanning:17.3.0"
implementation "com.google.mlkit:text-recognition:16.0.1"
implementation "com.google.mlkit:text-recognition-chinese:16.0.1"
```

## 注意

- 现在是“从图片识别”的稳定接入，不是实时 CameraX 扫描预览。这样更轻量，也更适合当前 Flutter + MethodChannel 架构。
- OCR 的价格 / 日期 / 标题提取采用启发式正则，真实使用中可以继续优化。
- 如 ML Kit 依赖下载较慢，请确保 Gradle 可访问 `google()` 仓库。
