# v42 更新说明

这版主要解决你刚刚指出的三个问题：

1. **每次稍微调一下就整张预览重新转圈，体验很怪**
2. **裁切应该直接在图片上框选，而不是靠滑动条**
3. **需要一种手动勾勒物体边缘，然后自动裁切生成贴纸的方式**

---

## 一、白框封面改成“直接框选裁切”

### 原问题
v41 的裁切白框虽然能用，但还是通过缩放/位移思路在调，不够直观。

### v42 改法
现在 `裁切白框` 改成了：
- 直接在图片上看到一个裁切框
- 可以 **拖动整个裁切框**
- 可以拖动 **四个角的手柄** 来调整大小
- 预览不会在每次微调时重新整张生成并转圈

### 技术实现
- 预览阶段不再每次都重新渲染 PNG
- 直接使用 `Image.file` + Flutter 覆盖层显示裁切框
- 只有用户点击“生成白框封面”时，才真正导出 PNG

相关新增/重写：
- `_decodeImageSizeFromUri`
- `_fitContainRect`
- `_normalizeClampedCropRect`
- `_CropSelectionPainter`
- `_DirectCropSelectionPreview`
- `renderFramedCoverPngBytes`
- `saveFramedCoverImage`
- `editFramedCover`

---

## 二、新增“手动勾勒”贴纸生成方式

### 新入口
资产 / 心愿的封面导入栏新增：
- `手动勾勒`

### 使用方式
1. 先从相册选图
2. 在图片上沿着物体轮廓手动划一圈
3. 系统自动把你的轨迹闭合
4. 按轮廓自动裁切并导出透明贴纸 PNG

### 特点
- 不依赖 AI 自动分割质量
- 不需要每次微调都重算整张预览
- 更接近“手工抠图”思路

### 技术实现
预览阶段：
- `Image.file` 直接显示原图
- 覆盖一层路径绘制（不重新导出）

导出阶段：
- 将归一化路径映射回原图像素坐标
- 自动求边界框 + 留白
- 用 `clipPath` 在原图上裁出对象区域
- 输出透明 PNG

相关新增：
- `_TraceOverlayPainter`
- `_ManualTracePreview`
- `saveTracedStickerImage`
- `editManualTraceSticker`
- `createManualTraceStickerFromPicker`

---

## 三、导入栏更新

### SmartAssetImportBar
现在包含：
- 选封面
- 裁切白框
- 手动勾勒
- AI贴纸
- 扫条码
- 小票 OCR

### CoverImportBar
现在包含：
- 选封面
- 裁切白框
- 手动勾勒
- AI贴纸

---

## 四、说明
这版重点不是继续硬堆 AI，而是先把两条更可用的交互路径补起来：

1. **直接框选裁切**（做白框封面）
2. **手动勾勒轮廓**（做透明贴纸）

这样即使自动抠图效果仍然一般，至少你已经有两条更“能落地”的替代方案。
