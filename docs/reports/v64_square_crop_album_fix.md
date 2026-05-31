# v64 修复说明：白框裁切比例与相册选择

## 1. 白框裁切锁定为正方形

白框封面最终导出是正方形，如果允许用户框选长方形，导出时会把长方形内容拉伸进正方形画布，导致比例变形。

v64 做了以下修改：

- 新增 `_defaultSquareCropForImageSize`：根据原图宽高初始化一个居中的正方形裁切框。
- 新增 `_normalizeSquareCropRect`：拖动四角时始终保持源图像素意义上的 1:1 正方形裁切。
- 裁切框移动时保持当前正方形大小不变。
- 重置时会重新按当前图片宽高生成默认正方形裁切框。

相关文件：

- `lib/src_parts/native_services.dart`

## 2. 白框封面不再拉伸变形

因为裁切框已经锁定为正方形，所以 `renderFramedCoverPngBytes` 仍然可以把 `srcRect` 绘制到正方形 `innerRect`，但源区域本身已经是正方形，不会再出现横向或纵向拉伸。

## 3. 相册选择改用 Storage Access Framework

之前 Android 13+ 使用 `MediaStore.ACTION_PICK_IMAGES`，在部分系统 / ROM 上会只显示一部分照片或最近照片，不适合资产封面这种需要访问完整相册的场景。

v64 改为统一使用：

```java
Intent.ACTION_OPEN_DOCUMENT
CATEGORY_OPENABLE
image/*
```

并增加：

- `FLAG_GRANT_READ_URI_PERMISSION`
- `FLAG_GRANT_PERSISTABLE_URI_PERMISSION`
- 常见图片 MIME 类型过滤

这样能通过系统文件选择器访问更多图片来源、相册目录和云端/本地图片提供器。

相关文件：

- `android/app/src/main/java/com/valora/assets/MainActivity.java`
