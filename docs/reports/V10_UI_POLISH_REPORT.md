# V10 UI Polish Report

本轮根据反馈继续精修：

1. 图标选择器
   - 相册、Emoji、3D 图标三类内容已经拆分为不同资源池，不再显示同一批图标。
   - Emoji 扩充到数码、电器、家居、交通、穿搭、娱乐、收藏等多分类。
   - 3D 图标以更强的渐变、阴影和选中态模拟立体贴纸感。
   - 相册页提供本地学习版封面贴纸占位，后续可接入 image_picker。

2. 紧凑度
   - 收紧 SoftFormCard / AppCard 默认内边距和圆角。
   - 新增页表单间距、备注图片入口、开关行密度进一步压缩。

3. 设置页
   - 更接近 Vue 项目的设置页结构：本机数据 Hero、显示预览、数值与单位、数据管理、显示与外观、通用。
   - 首页风格保留“卡片 / 列表 / 贴纸”，贴纸视图在设置里更明显。
   - 设置行采用轻量 icon badge + value pill / segmented，不再是厚重的安卓列表感。

4. 字体与字重
   - 字体 fallback 改为更偏 Apple/PingFang/SF Pro 的顺序，并移除 Microsoft YaHei 优先级。
   - 大量 w900/w800 字重降为 w700/w600，减少“全页面粗黑”的感觉。

5. 版本
   - Flutter version: 0.10.0+10
   - Android versionCode: 10
