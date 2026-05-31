# v41 更新说明

这版围绕两个核心诉求改动：

1. **AI 贴纸抠图继续增强**
2. **增加“裁切 + 白色圆角矩形边”的替代封面方案**

## 1）贴纸引擎新增更高质量模式
新增 `StickerEngineMode.hqExperimental`（高质量实验）：
- Android 原生侧解码尺寸更大：`1920`
- 阈值更多：`0.24 / 0.34 / 0.44 / 0.54 / 0.64 / 0.74`
- 最大候选数更多：`6`

用途：
- 面对复杂背景时，给用户更多候选结果
- 作为比原来的 compact / balanced / quality 更激进的高质量路线

> 说明：这仍然是基于当前本地引擎的增强版本，不是彻底引入一个全新的大型分割模型；但它已经为“更大输入 + 更多候选”的高质量模式预留了完整入口。

## 2）新增“裁切白框”封面方式
在资产和心愿的封面导入条上，新增一个入口：
- `裁切白框`

交互流程：
- 先从相册选择图片
- 进入一个本地编辑器
- 可以：
  - 拖动调整构图
  - 缩放裁切
  - 调整白框厚度
  - 调整圆角大小
  - 调整外边留白
- 最后生成一个带白色圆角矩形边框的封面 PNG

这样即使 AI 贴纸不好用，用户也有一条**稳定、可控、审美统一**的封面制作路径。

## 3）新增的主要函数
位于 `lib/src_parts/native_services.dart`：
- `renderFramedCoverPngBytes`
- `saveFramedCoverImage`
- `_FramedCoverPreview`
- `editFramedCover`
- `createFramedCoverFromPicker`

## 4）界面入口变更
### SmartAssetImportBar
新增：
- 选封面
- 裁切白框
- AI贴纸
- 扫条码
- 小票 OCR

### CoverImportBar
新增：
- 选封面
- 裁切白框
- AI贴纸
