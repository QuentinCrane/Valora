# V18 首页总览卡、字体与图标修正说明

本轮根据最新截图反馈，重点处理三件事：

1. **首页资产总览卡重构**
   - 首页顶部改为蓝色品牌渐变区域；
   - 顶部保留应用标题与搜索/筛选胶囊按钮；
   - 资产总览卡改为白色圆角浮层，布局对齐参考图中的“资产总览 4/4 + 总资产/日均成本 + 虚线分割 + 服役/退役/卖出进度条”；
   - 数值、标签、状态文字整体缩小，去掉厚重字重。

2. **字体体系继续减重**
   - 批量移除 `w500/w600/w700/w800/w900/bold` 显式字重；
   - 全局主题字号继续收窄；
   - 主要标题、金额、设置页数字等进一步降低字号，整体更接近 Apple 风格的轻量排版。

3. **替换为用户提供的蓝色 App Icon**
   - 将本轮上传的 `icon.png` 作为 App 图标源图；
   - 重新生成 Android `mipmap-mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi` 的 `ic_launcher.png` 与 `ic_launcher_round.png`；
   - 同步加入 Flutter asset：`assets/images/app_icon.png`；
   - `LogoMark` 也改为显示该蓝色图标，避免启动页/占位 Logo 仍显示旧图标。

## 修改文件

- `lib/src_parts/features_asset_home.dart`
- `lib/src_parts/app_bootstrap.dart`
- `lib/src_parts/common_widgets.dart`
- `pubspec.yaml`
- `android/app/build.gradle`
- `android/app/src/main/res/mipmap-*/ic_launcher*.png`
- `assets/images/app_icon.png`

## 版本

- Flutter version：`0.18.0+18`
- Android versionCode：`18`
