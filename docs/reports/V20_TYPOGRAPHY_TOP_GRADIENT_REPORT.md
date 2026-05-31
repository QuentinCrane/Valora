# V20 字体与首页顶部渐变修正

本版针对用户反馈继续修正：

1. 全局字体不使用粗体：
   - 所有 Dart 文件中的 `FontWeight.w400` 替换为 `FontWeight.normal`；
   - 检查并确认没有 `FontWeight.w500/w600/w700/w800/w900/bold`；
   - ThemeData 中重新细化 display/headline/title/body/label 的字号层级。

2. 首页顶部蓝色背景不再是圆角矩形块：
   - Shell 根层新增 `HomeTopGradientWash`；
   - 蓝色渐变从屏幕最顶层开始铺开，向下自然过渡到白色；
   - `HomeHeroHeader` 去掉自身蓝色圆角矩形，只保留标题、搜索胶囊和白色总览卡。

3. 版本：`0.20.0+20`。

建议本地继续运行：

```bash
flutter clean
flutter pub get
dart format .
flutter analyze
flutter build apk --debug
```
