# V13 预测返回、小组件与首页贴纸精修报告

## 本轮目标

根据最新参考图和反馈，v13 聚焦四个问题：

1. 首页顶部资产总览卡片需要更接近参考图：白色大圆角、双指标、虚线分割、状态进度条。
2. 贴纸模式需要从普通小卡片变成更像“便利贴粘上去”的两列轻微旋转布局。
3. 底部导航需要更接近 Apple 液态玻璃，透明度更高、模糊更明显、能看到下方内容。
4. 补齐 Android 预测返回与更多桌面小组件。

## 已完成改动

### 1. Android 预测返回

- `AndroidManifest.xml` 增加：
  - `android:enableOnBackInvokedCallback="true"`
- Flutter 路由从自定义 `PageRouteBuilder` 改为 `MaterialPageRoute`：
  - 让 Android 系统手势返回、Flutter Material Route 和 Android 13+ Predictive Back 更容易协同。
- 设置页新增“预测返回”说明入口。

> 注意：预测返回的系统预览动画需要 Android 13+、系统手势导航，以及较新的 Flutter/Android Gradle 环境共同支持。

### 2. 首页总览卡片重构

- 改为白色 / 半透明白卡片。
- 新增 `总资产` 与 `日均成本` 双列展示。
- 新增虚线分割线。
- 新增服役中、已退役、已卖出的横向进度条。
- 保留数字滚动/翻动后停下来的效果。

### 3. 贴纸模式重构

- `AssetStickerChip` 改成两列便利贴卡片。
- 每张卡片根据 asset id 做轻微随机旋转。
- 背景增加轻微色调变化。
- 信息层级改成：封面/状态 → 名称 → 日均成本。

### 4. 液态玻璃底部 Dock 增强

- Dock 背景透明度下调。
- 增强 `BackdropFilter` 模糊。
- 增加多层渐变、高光边框和浅阴影。
- 左侧导航与右侧加号分离更清楚。

### 5. 设置页分层

设置页从“所有设置塞在一个页面里”改为横向分段：

- 总览
- 数据
- 外观
- 原生
- 高级

这样更接近系统设置的分组体验，也更符合全局卡片风格。

### 6. Android 小组件增加

原来只有一个资产总览小组件，现在增加到 5 个：

1. `ValoraWidgetProvider`：资产总览小组件
2. `ValoraWishWidgetProvider`：心愿数量小组件
3. `ValoraDailyWidgetProvider`：日均成本小组件
4. `ValoraHealthWidgetProvider`：资产体检小组件
5. `ValoraQuickWidgetProvider`：快速新增小组件

对应新增资源：

- `widget_wish.xml`
- `widget_daily.xml`
- `widget_health.xml`
- `widget_quick.xml`
- `valora_wish_widget_info.xml`
- `valora_daily_widget_info.xml`
- `valora_health_widget_info.xml`
- `valora_quick_widget_info.xml`

### 7. 桌面快捷小组件数据同步

`AppStore.save()` 会同步更多数据到原生层：

- 资产数
- 心愿数
- 总资产
- 平均日耗
- 服役中数量
- 已退役数量
- 已卖出数量
- 临期数量
- 钱包漏洞数量
- 快照数量

## 本地验证建议

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```

Android 小组件需要在真机或支持 Launcher Widget 的模拟器中验证。
