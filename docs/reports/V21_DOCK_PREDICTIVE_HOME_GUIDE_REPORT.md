# V21 Dock / 首页卡片 / 预测式返回修复说明

## 1. 首页资产卡片

本版把首页资产小卡片继续往参考截图靠近：

- 两列卡片固定高度，避免同屏卡片高低不齐。
- 卡片内容只保留：资产图标、状态、名称、买入价 + 使用天数、日均成本。
- 去掉标签、买入块、附加统计等干扰信息。
- 状态胶囊改成圆点 + 文本，弱化颜色块。
- 图标从圆形底色容器改成更接近参考图的贴纸/3D 物件浮放感。

## 2. 顶部蓝色渐变

首页顶部的品牌蓝色不再是局部矩形，而是从屏幕顶层开始铺开，向下过渡到白色画布：

- 顶层更明显使用 `#7CC6F2` 系浅蓝。
- 渐变覆盖高度加大。
- 白色资产总览卡悬浮在渐变上。

## 3. Dock 水滴质感

本版将底部 Dock 从“磨砂玻璃”转为“水滴透明玻璃”方向：

- 去掉明显实心底色。
- 去掉强磨砂感的视觉主体。
- 保留极低透明填充、高光边缘、顶部水滴反光、蓝色轻散射、柔和阴影。
- 右侧加号按钮也改为同一套水滴材质。
- Dock 仍支持横向滑动切换 Tab。

## 4. 新建页保存按钮

新增资产/心愿页底部保存按钮已统一改成水滴液态玻璃按钮，不再使用黑色实心按钮。

## 5. 预测式返回

本版继续修复预测式返回：

- AndroidManifest 中保留：
  - `android:enableOnBackInvokedCallback="true"`
- 新增：
  - `android.window.PROPERTY_ENABLE_BACK_ANIMATION=true`
- Flutter 路由继续使用 `MaterialPageRoute`，避免自定义路由拦截系统预测返回。
- Android 页面转场从 `FadeUpwardsPageTransitionsBuilder` 改为 `ZoomPageTransitionsBuilder`，更贴近新版 Material/Android 返回动画。

### 重要测试条件

预测式返回不是普通左滑返回。请按以下条件测试：

1. 使用 Android 13 / Android 14 / Android 15 真机或模拟器。
2. 系统导航方式必须设置为“手势导航”，不是三键导航。
3. 需要进入二级页面测试，例如：
   - 首页点击某个资产进入详情页；
   - 新建资产页；
   - 设置中的二级页面。
4. 从屏幕左边缘慢慢向右滑动，不要从页面中部滑动。
5. 如果使用旧 Flutter SDK，可能只能看到普通返回，不会出现系统预测动画。建议使用较新的 Flutter stable。

### CLI 检查

```bash
flutter --version
flutter doctor -v
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

## 6. 仍需真机确认

我当前环境没有 Flutter/Android SDK，无法替你真机编译验证。预测式返回特别依赖系统版本、手势导航和 Flutter 版本，因此必须在 Android 13+ 真机或模拟器上确认。
