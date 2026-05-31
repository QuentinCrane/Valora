# V76 发布前细节修复

本版基于 V75 继续修复正式发布前反馈：

1. 日期选择器
   - 表单不再调用 Android Material DatePicker，避免标题/年份布局错行和紫红色残留。
   - 新增Valora自定义 iOS 风格日期选择器：
     - 左侧显示当前年月与选中日期。
     - 右上角左右箭头按月份小范围跳转。
     - 点击左侧年月区域后，原日期网格切换为独立的年份 / 月份滚轮。
     - 完成后统一写回 `YYYY-MM-DD`。
   - 表单日期输入框简化占位文字，避免窄列下多行挤压。

2. 系统相册选择
   - Android 13+ 优先使用系统 Photo Picker (`MediaStore.ACTION_PICK_IMAGES`)。
   - 低版本继续回退到 `ACTION_OPEN_DOCUMENT`。
   - 选择后的图片仍会复制到 App 私有目录，保证封面、贴纸和备份恢复后的可用性。

3. 资产图标显示
   - 图片封面、裁切白框、AI 贴纸、手动勾勒贴纸统一按方形圆角渲染。
   - 避免首页圆形底二次裁切导致导入数据后显示异常。
   - `framed_cover_` 也纳入贴纸/裁切图片识别，使用 `BoxFit.contain` 保留完整白框和透明边缘。

4. 版本号
   - Flutter: `0.76.0+76`
   - Android: `versionCode 76`, `versionName 0.76.0`
