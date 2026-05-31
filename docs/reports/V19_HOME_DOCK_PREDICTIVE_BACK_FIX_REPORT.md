# V19 首页卡片、透明 Dock 与预测返回修复说明

## 本轮目标

根据最新反馈，V19 重点不再堆新功能，而是修复几个影响观感和系统体验的核心问题：

1. 底部 Dock 改为更纯透明的玻璃效果，去掉明显底色；
2. 首页资产卡片统一高度，并去掉小卡片里的买入块、底部标签和过多信息；
3. 移除首页的「全部 / 未分类 / 分类」横向分类条，让页面更接近参考截图；
4. 折线图曲线统一为主题蓝色，曲线下方使用从上到下逐渐透明的蓝色面积填充；
5. 预测式返回恢复为系统 MaterialPageRoute，以匹配早期版本中更稳定的 Android 预测返回体验。

## 具体修改

### 1. 首页资产卡片

文件：`lib/src_parts/features_asset_home.dart`

- 网格卡片固定高度为 `188`；
- 贴纸卡片固定高度为 `166`；
- 网格卡片只保留：封面图标、状态、名称、价格/已使用天数、日均成本；
- 移除卡片内的「买入」小块；
- 移除卡片底部标签；
- 列表模式同步去除标签，信息层级更轻。

### 2. 首页分类条

文件：`lib/src_parts/features_asset_home.dart`

- 移除首页顶部 `CategoryStrip(store: store)`；
- 保留状态筛选、排序和更多筛选入口；
- 分类仍可通过筛选弹层和设置管理，不再占用首页主视觉区域。

### 3. Dock 透明液态玻璃

文件：`lib/src_parts/shell.dart`

- 降低 Dock 背景白色和品牌色不透明度；
- 去掉明显的实心底色感；
- 保留 `BackdropFilter` 高模糊、边框高光和极轻阴影；
- 右侧加号按钮同样改为更透明的玻璃圆形按钮。

### 4. 折线图

文件：

- `lib/src_parts/features_analytics.dart`
- `lib/src_parts/features_asset_detail.dart`

修改：

- 曲线线条颜色统一为 `kBrand` 主题蓝色；
- 曲线下方填充从 `kBrand.withOpacity(.34)` 过渡到透明；
- 去掉之前蓝绿渐变线条，避免偏离主色。

### 5. 预测式返回

文件：`lib/src_parts/app_bootstrap.dart`

- `softRoute` 从自定义 `PageRouteBuilder` 恢复为 `MaterialPageRoute`；
- 继续保留 Manifest 中的 `android:enableOnBackInvokedCallback="true"`；
- 这样更符合 Android 13+ / 14+ 的系统预测返回机制，也更接近早期可用版本。

预测式返回需要：

- Android 13+ / Android 14+；
- 系统手势导航；
- 较新的 Flutter 和 Android Gradle 构建链；
- 子页面通过 `softRoute(...)` 打开。

## 版本

- Flutter package version: `0.19.0+19`
- Android versionCode: `19`
- Android versionName: `0.19.0`
