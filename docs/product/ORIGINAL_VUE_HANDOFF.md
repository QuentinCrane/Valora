# Valora（Valora-cleanroom）交接说明

这份文档用于让另一个 Codex/开发者快速接手 `youshu_cleanroom_app`，理解当前实现、功能范围、页面结构、交互路径、关键文件和后续可做的优化点。

本文以当前 `codes/src` 中的 Vue 实现为准，重点解释每个页面“长什么样、有什么内容、点击后发生什么、跳到哪里”。如果要重构为原生 Android，请把这里当成功能说明书和交互说明书，而不是逐行翻译代码。

## 一句话概览

Valora是一个移动优先、多端适配的本地资产与心愿管理 Web App：以“日均成本”和“生命周期”作为核心指标，提供资产/心愿记录、筛选排序、多视图浏览、统计分析、设置与本地备份恢复。

## 当前状态（可交付能力）

- 主品牌名：Valora（已在首页标题、`index.html`、`capacitor.config.json` 中更新）
- UI 风格：浅色默认 + 深色模式；半透明液态玻璃底部 Dock；较高信息密度；平板/宽屏自适配布局
- 交互：页面切换淡入淡出；二级页固定左上返回；点击/切换/展开/卡片入场/Bottom Sheet 都有轻量动效；支持 `prefers-reduced-motion`
- 数据：纯前端本地存储（`localStorage`），具备 JSON 导出/覆盖恢复、本机快照与快照恢复
- 分析：趋势图（ECharts）、分类/标签分布、服役时长、日均成本排行等
- 当前没有真实后端请求，没有账号体系，没有云同步

## 运行方式

在 `codes` 目录下：

```bash
npm install
npm run dev
```

构建与预览：

```bash
npm run build
npm run preview
```

类型检查：

```bash
npm run check
```

说明：构建阶段会先跑 `vue-tsc -b` 再 `vite build`。ECharts 体积较大，构建时可能出现 chunk size warning（不影响结果）。

## 总体页面与导航结构

路由集中定义在 `src/router.ts`。根路径 `/` 会重定向到 `/assets`。

| 路由 | 页面文件 | 类型 | 说明 |
| --- | --- | --- | --- |
| `/` | redirect | 入口 | 自动跳转到 `/assets` |
| `/assets` | `AssetHome.vue` | 主 Tab | 资产首页，总览、筛选、排序、资产列表 |
| `/assets/new` | `ComposePage.vue` | 二级页 | 统一新增页，默认打开“资产”表单 |
| `/assets/:id` | `AssetDetail.vue` | 二级页 | 资产详情，查看指标、趋势、生命周期 |
| `/assets/:id/edit` | `AssetEditor.vue` | 二级页 | 编辑已有资产 |
| `/wishes` | `WishHome.vue` | 主 Tab | 心愿首页，心愿统计、筛选、列表 |
| `/wishes/new` | `ComposePage.vue` | 二级页 | 统一新增页，默认打开“心愿”表单 |
| `/wishes/:id` | `WishEditor.vue` | 二级页 | 编辑心愿，也可转资产 |
| `/analytics` | `AnalyticsHome.vue` | 主 Tab | 资产分析、趋势、分布、排行 |
| `/settings` | `SettingsHome.vue` | 主 Tab | 设置、分类标签、备份恢复 |

主 Tab 页面包括：

```text
/assets     /wishes     /analytics     /settings
```

它们会显示底部 Dock 和右下角 FAB：

```text
┌──────────────────────────────┐
│ 当前主页面内容                │
│                              │
│                              │
│                              │
│                              │
│   ┌────────────────────┐   ┌─┐│
│   │ 资产 心愿 分析 设置 │   │+││
│   └────────────────────┘   └─┘│
└──────────────────────────────┘
```

二级页包括详情、编辑、新增页。它们隐藏底部 Dock 和 FAB，并由 `App.vue` 统一渲染左上角圆形返回按钮：

```text
┌──────────────────────────────┐
│  ○ 返回                       │
│                              │
│ 二级页面内容                  │
│                              │
└──────────────────────────────┘
```

### 全局返回规则

返回逻辑在 `App.vue`：

- 如果浏览器历史中存在上一个页面，点击左上返回按钮会执行 `router.back()`
- 如果没有历史，使用兜底路径：
  - `/assets/:id/edit` 返回 `/assets/:id`
  - 其他 `/assets...` 二级页返回 `/assets`
  - `/wishes...` 二级页返回 `/wishes`
  - 其他未知情况返回 `/assets`

### 底部 Dock 行为

底部 Dock 由 `AppNav.vue` 控制：

```text
┌────────────────────────┐
│  首页图标  心愿  分析  设置 │
└────────────────────────┘
```

- 点“资产”跳 `/assets`
- 点“心愿”跳 `/wishes`
- 点“分析”跳 `/analytics`
- 点“设置”跳 `/settings`
- 当前路由以对应前缀开头时，该项进入 active 状态
- Dock 是半透明液态玻璃效果，固定在底部，宽屏时居中显示

### FAB 行为

FAB 由 `FloatingActionButton.vue` 控制，实际跳转逻辑在 `App.vue`：

- 当前在 `/assets`：点击 `+` 跳 `/assets/new`
- 当前在 `/wishes`：点击 `+` 跳 `/wishes/new`
- 当前在 `/analytics` 或 `/settings`：点击 `+` 默认跳 `/assets/new`

## 不运行网页时的整体视觉复原

如果只读本文档，不打开网页，可以先把整个 App 想成一个“手机 App 壳”：

```text
浏览器/设备背景
┌────────────────────────────────┐
│ 居中的 App 外壳                 │
│ - 手机宽度默认约 430px          │
│ - 平板扩展到 820px              │
│ - 宽屏扩展到 1060px             │
│ - 520px 以上出现圆角外壳         │
│ - 背景是浅蓝灰到浅灰的柔和渐变    │
│                                │
│ ┌────────────────────────────┐ │
│ │ 页面内容区域                │ │
│ │ 卡片、筛选、图表、表单       │ │
│ └────────────────────────────┘ │
│                                │
│ 主 Tab 页面底部有玻璃 Dock + FAB │
└────────────────────────────────┘
```

全局视觉关键词：

- 背景：浅色模式是浅蓝灰/浅灰渐变；深色模式是近黑、深灰、深蓝黑渐变
- 主色：明亮浅蓝 `#7cc6f2`
- 卡片：白色或深灰底，圆角较大，轻阴影，局部有半透明高光
- 文本：标题粗重，正文紧凑；金额使用 tabular numbers，方便数字对齐
- 交互：按钮、卡片、Tab、Dock、FAB 都有按压缩放反馈
- 动效：页面切换淡入淡出，卡片入场上浮，Bottom Sheet 滑入
- 适配：手机优先；平板/宽屏主要改变列数、外壳宽度和页面密度

全局色彩与尺寸可从 `src/styles/tokens.css` 复原：

```text
浅色：
  背景       #f4f4f7
  卡片       #ffffff
  软背景     #eeeeef
  正文       #141518
  次级文字   #8b8c92
  主色       #7cc6f2
  危险色     #ff674d

深色：
  背景       #0b0d0d
  卡片       #1f1f20
  软背景     #18191a
  正文       #f2f3ef
  次级文字   #8e9296
```

全局页面骨架：

```text
主页面：
┌──────────────────────────────┐
│ 页面标题 / 顶部内容            │
│ 页面主体                       │
│                              │
│                              │
│ ┌──────────────────────┐  ┌─┐ │
│ │ 底部 Dock             │  │+│ │
│ └──────────────────────┘  └─┘ │
└──────────────────────────────┘

二级页面：
┌──────────────────────────────┐
│ ○ 返回                        │
│ 页面标题 / 表单 / 详情          │
│                              │
│ 如果是编辑页：底部固定保存按钮   │
└──────────────────────────────┘
```

## 页面功能清单（按页面）

### 资产首页 `/assets`

对应文件：`src/pages/AssetHome.vue`

#### 页面定位

资产首页是 App 的主入口，也是信息密度最高的页面。它用于快速回答：

- 当前资产总值是多少？
- 有多少资产正在服役、退役、卖出？
- 哪些资产日均成本最高？
- 是否可以按状态、分类、标签、目标成本筛选？
- 资产列表用什么视图浏览？

#### 页面排布

移动端大致排布：

```text
┌──────────────────────────────┐
│ 顶部蓝色区域                  │
│ ┌──────────────────────────┐ │
│ │ Valora             搜索 筛选 │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ 资产总值                  │ │
│ │ ¥xxxxx.xx                 │ │
│ │ 资产数量 服役中 退役 卖出  │ │
│ │ 总日均成本 ¥x.xx          │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ 状态 Tab：全部 服役中 退役 卖出 │
│                         排序 更多 │
├──────────────────────────────┤
│ 分类横向滚动：全部 未分类 手机... │
├──────────────────────────────┤
│ 资产列表                       │
│ ┌──────────┐ ┌──────────┐     │
│ │ 资产卡片  │ │ 资产卡片  │     │
│ └──────────┘ └──────────┘     │
│                              │
│ 底部 Dock + FAB               │
└──────────────────────────────┘
```

宽屏时：

- 顶部蓝色区域变为两列：左侧标题/操作，右侧总览卡
- 网格视图从 2 列扩展到 3 列、4 列
- 列表视图可变为 2 列
- 贴纸视图会根据宽度增加列数

#### 页面内容

顶部区域：

- 标题：`Valora`
- 搜索按钮：打开搜索 Bottom Sheet
- 筛选按钮：打开筛选 Bottom Sheet
- 资产总览卡：
  - 资产总值
  - 当前可见资产数 / 总资产数
  - 服役中数量
  - 已退役数量
  - 已卖出数量
  - 总日均成本

筛选区域：

- 状态筛选：全部、服役中、退役、卖出
- 分类筛选：全部、未分类、每个自定义分类
- 排序按钮：打开排序 Bottom Sheet
- 更多筛选按钮：打开筛选 Bottom Sheet

列表区域有三种视图：

1. 网格视图 `AssetCard`
   - 图标
   - 状态标签
   - 名称
   - 分类 / 价格 / 使用天数
   - 日均成本
   - 目标进度条
   - 标签

2. 列表视图 `AssetListRow`
   - 横向排布，适合扫读
   - 图标、名称、状态、分类、使用天数、价格、日均成本、目标进度、标签

3. 贴纸视图 `AssetStickerItem`
   - 每个资产像小贴纸，带轻微旋转和位移
   - 显示图标、名称、状态、日均成本

#### 状态与筛选逻辑

页面状态：

- `query`：搜索关键词
- `statusFilter`：状态筛选，默认 `all`
- `categoryFilter`：分类筛选，默认 `all`
- `sortMode`：排序方式，默认 `dailyCost`
- `viewMode`：首页视图，来自 `settings.defaultHomeViewMode`
- `searchSheetOpen`：搜索 Sheet 是否打开
- `filterSheetOpen`：筛选 Sheet 是否打开
- `sortSheetOpen`：排序 Sheet 是否打开
- `advancedFilters.taggedOnly`：仅看有标签
- `advancedFilters.targetedOnly`：仅看有目标

筛选顺序：

```text
全部资产
  -> 分类筛选
  -> 状态筛选
  -> 高级筛选（有标签 / 有目标）
  -> 搜索关键词（名称、备注、分类名、标签名）
  -> 排序
  -> 按当前 viewMode 渲染
```

排序规则：

- 日均：按日均成本从高到低
- 价格：按购买价格从高到低
- 时长：按服役天数从高到低
- 最新：按 `updatedAt` 从新到旧

#### 点击与交互效果

- 点击顶部搜索图标：
  - 打开“搜索资产” Bottom Sheet
  - 搜索输入框自动 focus
  - 输入关键词后列表实时过滤
  - 点“清空搜索”会清空 `query`
  - 点“完成”关闭 Sheet

- 点击顶部筛选图标或状态行更多按钮：
  - 打开“筛选” Bottom Sheet
  - 可切换“仅看有标签”“仅看有目标”
  - 点“重置筛选”会清空搜索、高级筛选，并把排序恢复为日均

- 点击排序按钮：
  - 打开“排序” Bottom Sheet
  - 切换日均/价格/时长/最新
  - 列表立刻按新规则排序

- 点击状态 Tab：
  - 当前 Tab 变为 active，有下划线 pop 动效
  - 列表立刻过滤

- 点击分类 chip：
  - chip 变为黑底 active
  - 列表立刻过滤

- 点击资产卡片/列表行/贴纸：
  - 跳转到 `/assets/:id`
  - 页面切换使用 `route-fade` 淡入淡出和轻微上移动效

- 如果没有资产：
  - 显示空状态
  - 点“新增资产”跳 `/assets/new`

### 资产详情 `/assets/:id`

对应文件：`src/pages/AssetDetail.vue`

#### 页面定位

资产详情页展示单个资产的完整指标与生命周期，是从资产首页卡片进入后的阅读页。

#### 页面排布

```text
┌──────────────────────────────┐
│ ○ 返回                 编辑 删除 │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │        图标              │ │
│ │        资产名称          │ │
│ │ 分类 · 状态              │ │
│ │ 价格                     │ │
│ │ 使用天数 · 日均成本       │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ 日均成本趋势图            │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ 目标成本                  │ │
│ │ 当前日均 / 目标天数 / 日期 │ │
│ │ 进度条                    │ │
│ └──────────────────────────┘ │
│ ┌──────────┐ ┌──────────┐   │
│ │ 基础信息  │ │ 生命周期  │   │
│ └──────────┘ └──────────┘   │
│ ┌──────────────────────────┐ │
│ │ 备注 / 标签 / 附加物品     │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

移动端在窄屏下，基础信息和生命周期会纵向堆叠。

#### 页面内容

顶部动作：

- 编辑按钮 `✎`
- 删除按钮 `🗑`

摘要卡：

- 资产图标
- 名称
- 分类名，未分类显示“未分类”
- 状态：服役中 / 已退役 / 已卖出
- 购买价格
- 服役天数
- 日均成本

趋势图：

- 标题：日均成本趋势
- 描述：随着使用天数增加，日均成本会逐步下降
- 使用 ECharts line chart
- x 轴为第几天
- y 轴为日均成本

目标成本卡：

- 当前目标描述
  - 按日均：`目标日均成本 x.xx`
  - 按日期：`目标日期 yyyy-mm-dd`
  - 自定义：`目标总天数 x 天`
  - 无目标：显示“还没有设置目标成本”
- 当前日均成本
- 目标达成天数
- 预计达成日期
- 剩余天数
- 达成进度条

基础信息卡：

- 价格
- 购买日期
- 分类
- 标签

生命周期卡：

- 当前状态
- 服役天数
- 实际损耗
- 如果退役：显示退役日期
- 如果卖出：显示卖出日期和卖出价格

附加信息卡：

- 有备注时显示备注
- 有标签时显示标签 chip
- 有附加物品时显示附加物品名称和价格

#### 点击与交互效果

- 点击编辑按钮：
  - 跳 `/assets/:id/edit`

- 点击删除按钮：
  - 弹出浏览器确认框：`删除「资产名」？`
  - 确认后调用 `store.deleteAsset(id)`
  - 删除成功后跳回 `/assets`
  - 取消则停留当前页面

- 如果 URL 中的资产 id 找不到：
  - 显示空状态“找不到资产”
  - 点“返回资产页”跳 `/assets`

### 编辑资产 `/assets/:id/edit`

对应文件：`src/pages/AssetEditor.vue`

#### 页面定位

编辑资产页用于修改已有资产的所有字段。它也保留了 create 模式的代码结构，但当前路由中新增资产实际走 `ComposePage`。

#### 页面排布

```text
┌──────────────────────────────┐
│ ○ 返回                   重置 │
├──────────────────────────────┤
│ 图标按钮  编辑资产             │
│          说明文字              │
├──────────────────────────────┤
│ 名称输入                       │
│ 价格输入                       │
│ 购买日期                       │
│ 分类下拉                       │
│ 标签选择                       │
│ 状态下拉                       │
│ 计入总资产 switch              │
│ 计入日均 switch                │
│ 条件字段：退役/卖出日期价格     │
│ 目标模式 + 条件字段             │
│ 到期时间 / 提醒天数             │
│ 备注                           │
│ 附加物品列表                   │
├──────────────────────────────┤
│             保存按钮（固定底部）│
└──────────────────────────────┘
```

#### 可编辑字段

- 图标：emoji / 内置 SVG 图标 / 本地图片 data URL
- 名称
- 价格
- 购买日期
- 分类
- 标签
- 状态：服役中 / 已退役 / 已卖出
- 是否计入总资产
- 是否计入日均
- 退役日期（状态为退役时显示）
- 卖出日期、卖出价格（状态为卖出时显示）
- 目标模式：无 / 按日均 / 按日期 / 自定义
- 目标日均成本（按日均时显示）
- 目标日期（按日期时显示）
- 目标总天数（自定义时显示）
- 到期时间
- 提前提醒天数
- 备注
- 附加物品：
  - 名称
  - 价格
  - 是否计入总资产
  - 是否计入日均

#### 点击与交互效果

- 点击重置按钮 `↺`：
  - 如果编辑已有资产，将表单恢复为当前 store 中的资产数据
  - 如果是 create 模式，则恢复默认空表单

- 点击图标区：
  - 打开 `IconPickerSheet`
  - 可在“相册 / Emoji / 3D 图标”之间切换
  - 选择并确认后更新表单图标

- 点击标签：
  - 标签 active 状态切换
  - 再次点击移除该标签

- 修改状态：
  - 选“已退役”后显示退役日期
  - 选“已卖出”后显示卖出日期和卖出价格

- 修改目标模式：
  - `none` 不显示目标输入
  - `daily` 显示目标日均成本
  - `date` 显示目标日期
  - `custom` 显示目标总天数

- 点击附加物品“新增”：
  - 在当前表单中追加一条 addon

- 点击附加物品“删除”：
  - 从表单中移除该 addon

- 点击保存：
  - 名称为空：弹出 `请先填写资产名称`
  - 状态为已卖出但卖出价为空/0：弹出 `已卖出资产需要填写卖出价格`
  - 状态为退役且未填退役日期：自动填今天
  - 状态为卖出且未填卖出日期：自动填今天
  - 数字字段会转为 Number
  - 与目标模式无关的目标字段会被清空为 `null`
  - 调用 `store.upsertAsset(payload)`
  - 保存成功后跳 `/assets/:id`

### 统一新增 `/assets/new` 与 `/wishes/new`

对应文件：`src/pages/ComposePage.vue`

#### 页面定位

这是资产和心愿共用的新增页。进入路径不同，会决定默认打开哪个 tab：

- `/assets/new`：默认资产
- `/wishes/new`：默认心愿

页面内部仍可手动切换“资产 / 心愿”。

#### 页面排布

```text
┌──────────────────────────────┐
│ ○ 返回                       │
├──────────────────────────────┤
│      [ 资产 | 心愿 ]          │
├──────────────────────────────┤
│      图标按钮                 │
│      新增资产/新增心愿         │
│      说明文字                 │
├──────────────────────────────┤
│ 当前 tab 的表单               │
│                              │
│ asset tab: 资产完整新增字段    │
│ wish tab : 心愿新增字段        │
├──────────────────────────────┤
│             保存按钮（固定底部）│
└──────────────────────────────┘
```

#### 资产 Tab 内容

- 名称
- 价格
- 购买日期
- 分类
- 标签
- 目标模式
- 目标日均 / 目标日期 / 目标天数
- 附加物品
- 备注
- 不计入总资产
- 不计入日均
- 已退役
- 已卖出
- 退役日期（已退役时显示）
- 卖出日期、卖出价格（已卖出时显示）
- 到期时间
- 提前提醒天数

注意：新增页里的“已退役”“已卖出”是 switch 形式，内部通过 computed proxy 把状态写到 `assetForm.status`。

#### 心愿 Tab 内容

- 名称
- 价格
- 分类
- 标签
- 附加物品
- 备注

#### 点击与交互效果

- 点击顶部 segmented：
  - 在资产表单和心愿表单之间切换
  - 标题、说明、图标预览都随 tab 变化

- 点击图标按钮：
  - 打开同一个 `IconPickerSheet`
  - 选择结果写入当前 tab 的表单

- 点击“+ 添加物品”：
  - 当前 tab 添加一条 addon
  - 资产 addon 默认计入总资产和日均
  - 心愿 addon 默认不计入总资产，但计入日均字段仍存在

- 点击保存：
  - 如果当前是资产 tab：
    - 校验资产名称
    - 校验卖出价格
    - 自动补退役/卖出日期
    - 调用 `store.upsertAsset`
    - 跳 `/assets/:id`
  - 如果当前是心愿 tab：
    - 校验心愿名称
    - 调用 `store.upsertWish`
    - 跳 `/wishes`

### 心愿首页 `/wishes`

对应文件：`src/pages/WishHome.vue`

#### 页面定位

心愿页用于记录“还没买，但未来可能购买”的物品，并支持一键转成资产。

#### 页面排布

```text
┌──────────────────────────────┐
│ 心愿                           │
│ 先记下想要的东西...             │
│ ┌──────────────────────────┐ │
│ │ 心愿总值                  │ │
│ │ ¥xxxxx.xx                 │ │
│ │ 共 可见/总数 个心愿        │ │
│ │ 在看 / 归档 / 已转         │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ 搜索输入                       │
│ [ 在看 | 归档 | 已转 | 全部 ]   │
├──────────────────────────────┤
│ 心愿卡片列表                   │
│ ┌──────────────────────────┐ │
│ │ 图标 名称 状态      价格    │ │
│ │ 分类 / 备注               │ │
│ │                  转资产    │ │
│ └──────────────────────────┘ │
│                              │
│ 底部 Dock + FAB               │
└──────────────────────────────┘
```

#### 页面内容

头部：

- 标题：心愿
- 副标题：先记下想要的东西，等合适的时候再把它带回资产列表
- 心愿总值卡：
  - 当前筛选下心愿总值
  - 当前筛选数量 / 总数量
  - 在看数量
  - 归档数量
  - 已转资产数量

工具栏：

- 搜索输入
- 状态筛选：在看、归档、已转、全部

列表：

- 每条由 `WishCard` 渲染
- 显示图标、名称、状态、分类、预期价格、备注、转资产按钮

#### 点击与交互效果

- 搜索：
  - 根据心愿名称、备注、标签名实时过滤

- 切换状态 segmented：
  - `active`：未归档且未转换
  - `archived`：已归档但未转换
  - `converted`：已有 `convertedAt`
  - `all`：全部

- 点击心愿卡片：
  - 如果 `convertedAssetId` 存在，跳 `/assets/:convertedAssetId`
  - 否则跳 `/wishes/:id`

- 点击“转资产”：
  - 调用 `store.convertWishToAsset(wish.id)`
  - 创建一条新资产
  - 将心愿标记为 `archived: true`
  - 写入 `convertedAt` 和 `convertedAssetId`
  - 跳到新资产详情 `/assets/:assetId`

- 如果没有心愿：
  - 显示空状态
  - 点“新增心愿”跳 `/wishes/new`

- 如果搜索/筛选后没有匹配：
  - 显示“没有找到匹配项”
  - 点“重置筛选”清空搜索并切到全部

### 编辑心愿 `/wishes/:id`

对应文件：`src/pages/WishEditor.vue`

#### 页面定位

编辑心愿页用于修改心愿，也提供心愿转资产入口。

#### 页面排布

```text
┌──────────────────────────────┐
│ ○ 返回                   转资产 │
├──────────────────────────────┤
│ 图标按钮  编辑心愿              │
│          说明文字              │
├──────────────────────────────┤
│ 名称                           │
│ 预期价格                       │
│ 分类                           │
│ 标签                           │
│ 备注                           │
│ 已归档 switch                  │
│ 附加物品                       │
├──────────────────────────────┤
│             保存按钮（固定底部）│
└──────────────────────────────┘
```

#### 可编辑字段

- 图标
- 名称
- 预期价格
- 分类
- 标签
- 备注
- 是否归档
- 附加物品：
  - 名称
  - 价格

#### 点击与交互效果

- 点击右上 `⇢`：
  - 调用 `store.convertWishToAsset`
  - 成功后跳 `/assets/:assetId`

- 点击图标：
  - 打开 `IconPickerSheet`

- 点击标签：
  - 切换选中状态

- 点击附加物品“新增”：
  - 新增一条 addon

- 点击附加物品“删除”：
  - 删除当前 addon

- 点击保存：
  - 名称为空：弹出 `请先填写心愿名称`
  - 保存成功调用 `store.upsertWish`
  - 跳 `/wishes`

### 分析 `/analytics`

对应文件：`src/pages/AnalyticsHome.vue`

#### 页面定位

分析页是只读统计仪表盘。它不修改数据，所有内容都由资产列表、分类、标签和设置计算得出。

#### 页面排布

移动端：

```text
┌──────────────────────────────┐
│ 分析                    星光图标 │
├──────────────────────────────┤
│ 时间范围横向滚动：全部 近一周... │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ 资产总值                  │ │
│ │ ¥xxxxx.xx                 │ │
│ │ 服役中/退役/卖出价值拆分   │ │
│ │ 右侧竖向状态胶囊           │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ 资产价值趋势图            │ │
│ └──────────────────────────┘ │
│ ┌──────────┐ ┌──────────┐   │
│ │ 平均日耗  │ │ 趋势变化  │   │
│ └──────────┘ └──────────┘   │
│ ┌──────────┐ ┌──────────┐   │
│ │ 主力分类  │ │ 标签覆盖  │   │
│ └──────────┘ └──────────┘   │
│ 类型分布 / 标签分布 / 时长 / 排行 │
└──────────────────────────────┘
```

平板/宽屏：

```text
┌────────────────────────────────────────┐
│ 分析                         星光图标   │
│ 时间范围 Chips                           │
├───────────────┬────────────────────────┤
│ 资产总值 Hero  │ 资产价值趋势图          │
├───────────────┴────────────────────────┤
│ 4 个洞察卡片横向排列                     │
├──────────────────────┬─────────────────┤
│ 类型分布              │ 标签分布         │
├──────────────────────┼─────────────────┤
│ 平均服役时长          │ 日均成本排行     │
└──────────────────────┴─────────────────┘
```

#### 页面内容

时间范围：

- 全部
- 最近一周
- 最近 90 天
- 最近 180 天
- 最近一年

资产总值卡：

- 总资产价值
- 服役中价值和占比
- 已退役价值和占比
- 已卖出价值和占比
- 右侧状态柱形胶囊

趋势图：

- 标题：资产价值趋势
- 根据当前时间范围展示趋势点
- ECharts 折线 + 面积渐变

洞察卡：

- 平均日耗
- 趋势变化
- 主力分类
- 标签覆盖

类型分布：

- donut 图
- 分类列表
- 显示各分类件数和比例

标签分布：

- tag cloud
- 显示标签名和数量

平均服役时长：

- 按分类显示平均使用天数
- 使用横向进度条表现相对长度

日均成本排行：

- 默认取前 5
- 显示排名、资产名、使用天数、状态、日均成本、横向条

#### 点击与交互效果

- 点击时间范围 chip：
  - `range` 更新
  - 全部统计重新计算
  - 趋势图、分类分布、标签分布、排行同步刷新

- 右上“导出分析”图标：
  - 当前只是按钮展示，没有绑定实际导出逻辑

- 分析卡片：
  - 有按压缩放反馈
  - 进入页面时，在非低动态模式下有轻微上浮入场动画

### 设置 `/settings`

对应文件：`src/pages/SettingsHome.vue`

#### 页面定位

设置页用于管理显示规则、分类标签、备份恢复、主题和提醒开关。它也是当前唯一能直接管理基础字典数据的页面。

#### 页面排布

移动端：

```text
┌──────────────────────────────┐
│ 设置                           │
│ 已自动保存 / 正在保存           │
├──────────────────────────────┤
│ 本机数据 Hero                  │
│ 总记录数                       │
│ 分类数 / 标签数 / 快照数        │
├──────────────────────────────┤
│ 数值与单位                     │
│ ┌ 显示预览                    │
│ └ 货币 / 小数 / 千分位 / 时长   │
├──────────────────────────────┤
│ 数据管理                       │
│ 分类管理（点击展开）            │
│ 标签管理（点击展开）            │
│ 备份与恢复（点击展开）          │
├──────────────────────────────┤
│ 显示与外观                     │
│ 主题 / 首页风格 / 退役计入总值   │
├──────────────────────────────┤
│ 通用                           │
│ 登录状态 / 到期提醒             │
└──────────────────────────────┘
```

宽屏时：

- 页面变为两列
- 设置头、本机数据、数据管理横跨整行
- 数值与单位、显示与外观、通用分布在两列中

#### 页面内容

顶部：

- 标题：设置
- 自动保存状态：
  - `已自动保存`
  - `正在保存`

本机数据 Hero：

- 资产 + 心愿总记录数
- 分类数
- 标签数
- 快照数
- 说明文字：资产与心愿记录保存在当前设备，备份后可随时恢复

数值与单位：

- 显示预览：根据当前草稿设置格式化 `12345.67`
- 货币单位：`¥`、`$`、`€`、`CNY`
- 小数位：0/1/2/3
- 使用千位分隔符
- 时长显示格式：天数 / 周 / 月

数据管理：

- 分类管理
- 标签管理
- 备份与恢复

显示与外观：

- 主题模式：自动 / 日间 / 夜间
- 首页风格：默认 / 列表 / 贴纸
- 已退役计入总资产

通用：

- 登录状态：本地模式
- 到期提醒：当前只是设置项，未接入系统通知

#### 设置自动保存机制

设置页维护一个 `draftSettings`：

```text
store.settings -> 同步到 draftSettings
用户修改 draftSettings
  -> saveState = saving
  -> 280ms debounce
  -> store.updateSettings(...)
  -> saveState = saved
```

主题修改会立即通过 store 的 `applyTheme` 写入 `document.documentElement.dataset.theme`，从而触发深色/浅色样式。

#### 分类管理交互

点击“分类管理”：

- 展开/收起分类管理面板
- 展开动画由 Vue Transition `manager-expand` 控制

展开后可以：

- 输入分类名称、图标、颜色
- 点击“添加”创建新分类
- 编辑已有分类名称、图标、颜色
- 点击“上移/下移”调整排序
- 点击“保存”写回分类
- 点击“删除”：
  - 弹出确认：删除后，相关资产会变成未分类
  - 确认后删除分类
  - 相关资产的 `categoryId` 会被置为 `null`

#### 标签管理交互

点击“标签管理”：

- 展开/收起标签管理面板

展开后可以：

- 输入标签名称、颜色
- 点击“添加”创建新标签
- 编辑已有标签名称、颜色
- 点击“上移/下移”调整排序
- 点击“保存”写回标签
- 点击“删除”：
  - 弹出确认：删除后会从所有资产上移除这个标签
  - 确认后删除标签
  - 当前实现会从所有资产的 `tagIds` 中移除该标签
  - 注意：`deleteTag` 当前只处理资产，没有同步处理心愿的 `tagIds`

#### 备份与恢复交互

点击“备份与恢复”：

- 展开/收起备份面板

展开后可以：

- 点击“导出 JSON”：
  - 调用 `exportDatabase()`
  - 生成 JSON Blob
  - 创建临时 `<a>` 下载
  - 文件名：`Valora-backup-YYYY-MM-DD.json`

- 点击“覆盖恢复”：
  - 触发隐藏文件 input
  - 选择 JSON 文件
  - 读取文件内容并 `JSON.parse`
  - 弹出确认：这会覆盖当前全部数据
  - 确认后调用 `restoreDatabase(payload)` 和 `store.reload()`

- 点击“创建快照”：
  - 调用 `store.snapshot(...)`
  - 快照 label 为 `快照 + 当前本地时间`
  - 快照内容是当前数据库导出的 JSON 字符串

- 点击某条快照的“恢复”：
  - 弹出确认
  - 确认后调用 `store.importSnapshot(snapshot)`
  - 覆盖当前数据库并 reload

## 通用组件与页面组件映射

### 页面组件

| 组件 | 用途 |
| --- | --- |
| `AppNav` | 底部主导航 Dock |
| `FloatingActionButton` | 右下新增按钮 |
| `AssetOverviewCard` | 资产首页顶部总览卡 |
| `AssetCard` | 资产网格卡 |
| `AssetListRow` | 资产列表行 |
| `AssetStickerItem` | 资产贴纸视图 |
| `WishCard` | 心愿列表卡片 |
| `ChartPanel` | ECharts 图表容器 |
| `TargetProgressBar` | 目标成本进度条 |
| `MoneyText` | 根据设置格式化金额 |
| `IconRenderer` | 根据 iconType 渲染 emoji/svg/image |
| `IconPickerSheet` | 图标选择底部弹窗 |

### 基础 UI 组件

| 组件 | 用途 |
| --- | --- |
| `BaseButton` | 通用按钮，支持 primary/secondary/ghost/danger |
| `BaseCard` | 通用卡片，支持 default/soft/accent |
| `BaseInput` | 输入框/textarea，支持数字、日期、搜索 |
| `BaseSegmented` | 分段选择器 |
| `BaseSheet` | Bottom Sheet |
| `BaseSwitch` | 开关 |
| `SwitchRow` | 带 label 的开关行 |
| `EmptyState` | 空状态 |
| `SettingSection` | 设置页分组 |
| `SettingRow` | 设置页行 |
| `IconGlyph` | 内置 SVG 图标库 |

## 全量数据模型与存储内容

当前 App 没有真实后端，也没有 IndexedDB。所有业务数据最终都序列化成一个 JSON 字符串，保存在浏览器 `localStorage` 的 `youshu-cleanroom-db-state` key 中。

整体存储形态：

```json
{
  "assets": [],
  "wishes": [],
  "categories": [],
  "tags": [],
  "settings": [
    {
      "key": "app",
      "value": "{...AppSettings JSON 字符串...}"
    }
  ],
  "snapshots": []
}
```

### Asset 资产字段

资产是一条“已经购买/拥有过的物品”记录。

```text
Asset
├── id: string
├── name: string                      资产名称
├── iconType: emoji | svg | image      图标类型
├── iconValue: string                  emoji 字符、svg key 或图片 data URL
├── iconImageUrl?: string              预留图片字段，当前主要使用 iconValue
├── price: number                      购买价格
├── purchaseDate: string               购买日期，YYYY-MM-DD
├── categoryId: string | null          分类 id，null 表示未分类
├── tagIds: string[]                   标签 id 数组
├── addons: AddonItem[]                附加物品
├── note: string                       备注
├── status: serving | retired | sold   服役中 / 已退役 / 已卖出
├── includeInTotal: boolean            是否计入总资产
├── includeInDailyCost: boolean        是否计入日均成本
├── retiredAt: string | null           退役日期
├── soldAt: string | null              卖出日期
├── soldPrice: number | null           卖出价格
├── targetMode: none | daily | date | custom
│                                      目标成本模式
├── targetDailyCost: number | null     目标日均成本
├── targetDate: string | null          目标日期
├── targetCustomDays: number | null    自定义目标总天数
├── expiresAt: string | null           到期时间，如保修/订阅到期
├── remindBeforeDays: number | null    提前提醒天数
├── createdAt: string                  创建时间 ISO
└── updatedAt: string                  更新时间 ISO
```

资产状态对页面的影响：

```text
serving:
  详情页显示“服役中”
  服役天数 = purchaseDate 到今天
  总资产默认计入

retired:
  详情页显示“已退役”
  需要 retiredAt
  服役天数 = purchaseDate 到 retiredAt
  是否计入总资产由 settings.includeRetiredInTotal 决定

sold:
  详情页显示“已卖出”
  需要 soldAt 和 soldPrice
  服役天数 = purchaseDate 到 soldAt
  总资产价值不计入
  净成本会扣除 soldPrice
```

### Wish 心愿字段

心愿是一条“想买但还没有变成资产”的记录。

```text
Wish
├── id: string
├── name: string
├── iconType: emoji | svg | image
├── iconValue: string
├── iconImageUrl?: string
├── expectedPrice: number              预期价格
├── note: string
├── categoryId: string | null
├── tagIds: string[]
├── archived: boolean                  是否归档
├── convertedAt: string | null         转资产时间
├── convertedAssetId: string | null    转成的资产 id
├── addons: AddonItem[]
├── createdAt: string
└── updatedAt: string
```

心愿状态由字段组合推导：

```text
convertedAt 有值:
  状态 = 已转资产
  点击心愿卡片会跳到对应资产详情

convertedAt 为空 && archived = true:
  状态 = 已归档
  点击心愿卡片进入心愿编辑页

convertedAt 为空 && archived = false:
  状态 = 在看
  点击心愿卡片进入心愿编辑页
```

### AddonItem 附加物品字段

附加物品可以挂在资产或心愿上。

```text
AddonItem
├── id: string
├── name: string
├── price: number
├── includeInTotal: boolean            是否计入总资产
└── includeInDailyCost: boolean        是否计入日均成本
```

资产计算中：

- `includeInDailyCost = true` 的 addon 会纳入净成本
- `includeInTotal = true` 或 `includeInDailyCost = true` 的 addon 会纳入资产价值

### Category 分类字段

```text
Category
├── id: string
├── name: string
├── icon: string                       emoji 图标
├── color: string                      颜色 hex
├── sortOrder: number                  排序
├── createdAt: string
└── updatedAt: string
```

分类用于：

- 资产首页分类筛选
- 资产/心愿编辑时选择分类
- 分析页类型分布
- 分析页各分类平均服役时长

### Tag 标签字段

```text
Tag
├── id: string
├── name: string
├── color: string
├── sortOrder: number
├── createdAt: string
└── updatedAt: string
```

标签用于：

- 资产首页搜索和“仅看有标签”
- 资产/心愿编辑时选择标签
- 资产卡片展示 tag chip
- 心愿搜索
- 分析页标签分布和标签覆盖率

### AppSettings 设置字段

```text
AppSettings
├── id: app
├── currencyUnit: string               金额前缀，如 ¥、$、€
├── decimalPlaces: number              金额小数位
├── useThousandsSeparator: boolean     是否千位分隔
├── durationMode: days | weeks | months
│                                      时长显示单位
├── theme: light | dark | system       主题模式
├── includeRetiredInTotal: boolean     退役资产是否计入总资产
├── reminderEnabled: boolean           到期提醒开关
└── defaultHomeViewMode: grid | list | sticker
                                       资产首页默认视图
```

设置影响范围：

```text
currencyUnit / decimalPlaces / useThousandsSeparator:
  所有 MoneyText 显示

durationMode:
  formatDuration 相关显示

theme:
  写入 document.documentElement.dataset.theme
  影响全局深色/浅色样式

includeRetiredInTotal:
  资产首页总值
  分析页资产总值
  状态拆分
  分类分布

reminderEnabled:
  当前只保存 UI 开关，没有实际通知逻辑

defaultHomeViewMode:
  资产首页默认视图
  在资产首页切换 viewMode 时会同步写回设置
```

### SnapshotRecord 快照字段

```text
SnapshotRecord
├── id: string
├── label: string                      例如：快照 2026/5/23 10:00:00
├── payload: string                    完整导出数据的 JSON 字符串
└── createdAt: string
```

快照是存在本机 localStorage 里的“数据库备份”。恢复快照会覆盖当前数据库。

### 首次启动种子数据

如果本地没有数据，`seedDatabaseIfNeeded()` 会自动创建：

```text
分类：
  手机、电脑、收藏

标签：
  高频使用、吃灰、出行

资产：
  iPhone 15
  富士 X-T30

心愿：
  降噪耳机
```

因此第一次打开 App 不是空白页，而是有示例数据。

## 完整用户操作链路

这一节用于从“用户点击”角度复原整个 App 能做什么。

### 新增资产链路

```text
/assets
  点击右下角 +
    -> /assets/new
       默认打开资产 tab
       填名称、价格、日期、分类、标签、目标、备注、附加物品
       点击保存
         -> 校验名称
         -> 如已卖出则校验卖出价格
         -> 写入 assets
         -> /assets/:id
```

保存后的结果：

- 资产首页出现新资产
- 分析页统计同步变化
- 分类/标签分布同步变化
- 如果设置了默认首页视图，首页按对应视图显示

### 编辑资产链路

```text
/assets
  点击某个资产卡片
    -> /assets/:id
       点击右上编辑
         -> /assets/:id/edit
            修改字段
            点击保存
              -> 写回 assets
              -> /assets/:id
```

### 删除资产链路

```text
/assets/:id
  点击右上删除
    -> confirm 删除「资产名」？
       取消：留在详情页
       确认：从 assets 删除
             -> /assets
```

### 新增心愿链路

```text
/wishes
  点击右下角 +
    -> /wishes/new
       默认打开心愿 tab
       填名称、预期价格、分类、标签、备注、附加物品
       点击保存
         -> 校验名称
         -> 写入 wishes
         -> /wishes
```

### 编辑心愿链路

```text
/wishes
  点击未转换的心愿卡片
    -> /wishes/:id
       修改名称、价格、分类、标签、归档、附加物品
       点击保存
         -> 写回 wishes
         -> /wishes
```

### 心愿转资产链路

有两个入口：

```text
入口 A：
/wishes
  点击心愿卡片里的“转资产”

入口 B：
/wishes/:id
  点击右上 ⇢
```

执行后：

```text
store.convertWishToAsset(wishId)
  -> 如果该心愿已经 convertedAssetId，且资产还存在：
       直接返回已有资产 id
  -> 否则创建新 Asset：
       名称、图标、价格、分类、标签、附加物品、备注从心愿复制
       purchaseDate = 今天
       status = serving
       targetMode = none
  -> 更新 Wish：
       archived = true
       convertedAt = 当前时间
       convertedAssetId = 新资产 id
  -> 跳 /assets/:assetId
```

### 搜索和筛选资产链路

```text
/assets
  点击搜索
    -> 打开搜索 Sheet
       输入关键词
       列表实时过滤

  点击状态 tab
    -> 全部 / 服役中 / 退役 / 卖出
       列表实时过滤

  点击分类 chip
    -> 全部 / 未分类 / 某分类
       列表实时过滤

  点击更多筛选
    -> 仅看有标签
    -> 仅看有目标

  点击排序
    -> 日均 / 价格 / 时长 / 最新
```

### 管理分类链路

```text
/settings
  点击 数据管理 > 分类管理
    -> 展开分类面板
       添加新分类
       编辑已有分类
       上移/下移排序
       保存
       删除
         -> confirm
         -> 相关资产 categoryId 置空
```

### 管理标签链路

```text
/settings
  点击 数据管理 > 标签管理
    -> 展开标签面板
       添加新标签
       编辑已有标签
       上移/下移排序
       保存
       删除
         -> confirm
         -> 从资产 tagIds 中移除
```

### 备份恢复链路

```text
/settings
  点击 数据管理 > 备份与恢复
    -> 导出 JSON
       生成 Valora-backup-YYYY-MM-DD.json

    -> 覆盖恢复
       选择 JSON 文件
       confirm 覆盖当前全部数据
       restoreDatabase

    -> 创建快照
       把当前完整数据库保存到 snapshots

    -> 恢复快照
       confirm
       用 snapshot.payload 覆盖当前数据库
```

## 空状态、错误状态和边界行为

### 资产首页空状态

触发条件：

```text
sortedAssets.length === 0
```

显示：

- 图标：📦
- 标题：还没有资产
- 描述：先记下一个正在陪你生活的物件吧。
- 按钮：新增资产

点击按钮跳 `/assets/new`。

注意：当前实现只判断筛选后的 `sortedAssets.length`。如果是因为筛选导致没有结果，也会显示“还没有资产”，不是单独的“无匹配结果”文案。

### 资产详情找不到资产

触发条件：

```text
store.assets.find(id) 找不到
```

显示：

- 图标：🫥
- 标题：找不到资产
- 描述：这条记录可能已经被删除。
- 按钮：返回资产页

点击按钮跳 `/assets`。

### 心愿首页空状态

触发条件：

```text
wishes.length === 0
```

显示：

- 图标：✨
- 标题：空空如也
- 描述：把暂时买不起、但很想要的东西先放进这里。
- 按钮：新增心愿

点击按钮跳 `/wishes/new`。

### 心愿筛选无结果

触发条件：

```text
wishes.length > 0 && filteredWishes.length === 0
```

显示：

- 图标：🔎
- 标题：没有找到匹配项
- 描述：换个关键词，或者把筛选切回全部。
- 按钮：重置筛选

点击按钮：

- 清空搜索
- 状态筛选切到全部
- 搜索框 focus

### 分析页空数据表现

分析页没有整体空状态，而是在各模块里显示空提示：

- 分类分布为空：`暂无分类数据`
- 标签分布为空：`暂无标签数据`
- 平均服役时长为空：`暂无可统计的分类`
- 日均成本排行为空：`暂无可排行资产`

### 设置页空数据表现

- 快照为空：`还没有快照`
- 分类/标签为空时，管理面板仍显示添加表单，只是没有已有项目列表

## 哪些内容是“展示”，哪些内容是真功能

真功能：

- 资产新增、编辑、删除、详情
- 心愿新增、编辑、归档、转资产
- 资产搜索、筛选、排序、视图切换
- 分析页全部本地统计
- 设置自动保存
- 分类/标签管理
- JSON 导出
- JSON 覆盖恢复
- 本机快照创建与恢复
- 深色/浅色主题切换

只是 UI 或预留字段：

- 到期提醒开关：只保存 `reminderEnabled`，没有系统通知
- 资产 `expiresAt` / `remindBeforeDays`：字段可编辑，但没有提醒调度
- 分析页右上“导出分析”图标：当前没有绑定导出逻辑
- `iconImageUrl`：模型字段存在，但当前图标图片主要用 `iconValue` 保存 data URL
- Capacitor 配置：存在配置文件，但当前本质仍是 Web App

## 逐屏完整可见内容清单

这一节用于确认“不运行网页也能知道屏幕上到底有什么字、什么控件、什么动态内容”。动态内容用 `{}` 表示。

### 全局 App 壳可见内容

主 Tab 页面底部 Dock：

```text
图标：home   sr-only 文案：资产
图标：heart  sr-only 文案：心愿
图标：pie    sr-only 文案：分析
图标：gear   sr-only 文案：设置
```

右下角 FAB：

```text
+
```

二级页左上返回按钮：

```text
‹
aria-label/title: 返回
```

### 资产首页 `/assets` 可见内容

固定文案：

```text
Valora
搜索
筛选
全部
服役中
退役
卖出
排序
更多筛选
未分类
新增资产
```

顶部总览卡固定文案：

```text
资产总值
资产数量
服役中
已退役
已卖出
总日均成本：
```

顶部总览卡动态内容：

```text
{totalValue}
{visibleCount}/{totalCount}
{servingCount}
{retiredCount}
{soldCount}
{averageDailyCost}
```

分类条内容：

```text
全部
未分类
{category.icon} {category.name}
```

搜索 Sheet：

```text
标题：搜索资产
描述：输入名称、标签或备注关键字来筛选。
输入框 placeholder：搜索资产、标签、备注
按钮：清空搜索
按钮：完成
```

筛选 Sheet：

```text
标题：筛选
描述：这里放一些不会打断浏览的补充过滤。
开关标题：仅看有标签
开关说明：排除掉还没整理过的条目
开关标题：仅看有目标
开关说明：只看已经设置目标成本的资产
按钮：重置筛选
```

排序 Sheet：

```text
标题：排序
描述：切换资产列表的默认排序方式。
分段项：日均
分段项：价格
分段项：时长
分段项：最新
按钮：完成
```

资产为空时：

```text
图标：📦
标题：还没有资产
描述：先记下一个正在陪你生活的物件吧。
按钮：新增资产
```

资产网格卡 `AssetCard` 每条显示：

```text
{asset.icon}
{statusLabel}                 服役中 / 已退役 / 已卖出
{asset.name}
{categoryName} · {asset.price} · {serviceDays} 天
{dailyCost}/天
如果有目标：目标已达成 / 还剩 {remainingDays} 天
如果有标签：{tag.name}
```

资产列表行 `AssetListRow` 每条显示：

```text
{asset.icon}
{asset.name}
{statusLabel}
{categoryName} · {serviceDays} 天
日均成本
{dailyCost}
价格
{asset.price}
如果有目标：目标已达成 / 还剩 {remainingDays} 天
如果有标签：{tag.name}
```

资产贴纸项 `AssetStickerItem` 每条显示：

```text
{asset.icon}
{asset.name}
{statusLabel}
{dailyCost} /天
```

### 资产详情 `/assets/:id` 可见内容

顶部：

```text
返回按钮：‹
编辑按钮：✎
删除按钮：🗑
```

摘要卡：

```text
{asset.icon}
{asset.name}
{categoryName} · {statusLabel}
{asset.price}
{serviceDays} 天
{dailyCost} /天
```

趋势图卡：

```text
标题：日均成本趋势
描述：随着使用天数增加，日均成本会逐步下降。
tooltip：第 {day} 天 / 日均成本 {value}
```

目标成本卡：

```text
标题：目标成本
无目标文案：还没有设置目标成本
按日均目标：目标日均成本 {targetDailyCost}
按日期目标：目标日期 {targetDate}
自定义目标：目标总天数 {targetCustomDays} 天
当前日均成本
目标达成天数
预计达成日期
剩余天数
进度条文案：目标进度 / 已达成
```

基础信息卡：

```text
标题：基础信息
价格
购买日期
分类
标签
标签为空显示：无
```

生命周期卡：

```text
标题：生命周期
当前状态
服役天数
实际损耗
如果 retired：退役日期
如果 sold：卖出日期
如果 sold：卖出价格
```

详情附加卡按条件显示：

```text
如果有 note：
  标题：备注
  {asset.note}

如果有 tags：
  标题：标签
  {tag.name}

如果有 addons：
  标题：附加物品
  {addon.name}
  {addon.price}
```

找不到资产时：

```text
图标：🫥
标题：找不到资产
描述：这条记录可能已经被删除。
按钮：返回资产页
```

### 编辑资产 `/assets/:id/edit` 可见内容

顶部：

```text
返回按钮：‹
重置按钮：↺
```

头部：

```text
图标按钮文字：图标
标题：编辑资产
说明：把买入、服役、退役和卖出都放进同一条时间线。
```

表单字段：

```text
名称
placeholder：例如：iPhone 15

价格
placeholder：6999

购买日期

分类
选项：未分类
选项：{category.icon} {category.name}

标签
按钮：{tag.name}

状态
选项：服役中
选项：已退役
选项：已卖出

计入总资产
计入日均

如果状态 = retired：
  退役日期

如果状态 = sold：
  卖出日期
  卖出价格
  placeholder：3200

目标模式
选项：无
选项：按日均
选项：按日期
选项：自定义

如果目标模式 = daily：
  目标日均成本
  placeholder：8

如果目标模式 = date：
  目标日期

如果目标模式 = custom：
  目标总天数
  placeholder：365

到期时间
提前提醒天数
placeholder：7

备注
placeholder：补充说明
```

附加物品区：

```text
标题：附加物品
说明：保护壳、镜头、支架这类额外投入也能一起记。
按钮：新增

每条 addon：
  名称
  价格
  计入总资产
  计入日均
  删除
```

底部固定按钮：

```text
保存
```

保存时可能弹出的提示：

```text
请先填写资产名称
已卖出资产需要填写卖出价格
```

### 统一新增 `/assets/new` 和 `/wishes/new` 可见内容

顶部：

```text
返回按钮：‹
分段项：资产
分段项：心愿
```

资产 tab 头部：

```text
图标
新增资产
把买入、服役、退役和卖出放进同一条时间线。
```

资产 tab 表单：

```text
名称
placeholder：请输入物品名称

价格
placeholder：6999

购买日期

分类
选项：全部
选项：{category.icon} {category.name}

标签
{tag.name}

目标模式
选项：不设定
选项：按价格
选项：按周期
选项：自定义

如果 daily：
  目标日均成本
  placeholder：8

如果 date：
  目标日期

如果 custom：
  目标总天数
  placeholder：365

附加物品
保护壳、镜头、支架这类额外投入也能一起记。
按钮：+ 添加物品

备注
placeholder：补充说明

不计入总资产
不计入日均
已退役
已卖出

如果已退役：
  退役日期

如果已卖出：
  卖出日期
  卖出价格
  placeholder：3200

到期时间
提前提醒天数
placeholder：7
```

心愿 tab 头部：

```text
图标
新增心愿
先记下想要的东西，合适的时候再转成资产。
```

心愿 tab 表单：

```text
名称
placeholder：请输入心愿名称

价格
placeholder：1299

分类
选项：全部
选项：{category.icon} {category.name}

标签
{tag.name}

附加物品
比如耳机保护套、扩展坞之类，也可以附着在心愿上。
按钮：+ 添加物品

每条 addon：
  名称
  价格
  删除

备注
placeholder：比如等降价、等活动
```

底部固定按钮：

```text
保存
```

保存时可能弹出的提示：

```text
请先填写资产名称
已卖出资产需要填写卖出价格
请先填写心愿名称
```

### 心愿首页 `/wishes` 可见内容

头部：

```text
心愿
先记下想要的东西，等合适的时候再把它带回资产列表。
```

心愿总值卡：

```text
心愿总值
{totalValue}
共 {filteredWishes.length}/{wishes.length} 个心愿
在看 {watchingCount}
归档 {archivedCount}
已转 {convertedCount}
```

工具栏：

```text
搜索输入 placeholder：搜索心愿、备注、标签
分段项：在看
分段项：归档
分段项：已转
分段项：全部
```

心愿卡片每条显示：

```text
{wish.icon}
{wish.name}
状态：在看 / 已归档 / 已转资产
{categoryName}
{expectedPrice}
如果有 note：{wish.note}
如果未转换：按钮 转资产
如果已转换：按钮 看资产
```

空状态：

```text
图标：✨
标题：空空如也
描述：把暂时买不起、但很想要的东西先放进这里。
按钮：新增心愿
```

筛选无结果：

```text
图标：🔎
标题：没有找到匹配项
描述：换个关键词，或者把筛选切回全部。
按钮：重置筛选
```

### 编辑心愿 `/wishes/:id` 可见内容

顶部：

```text
返回按钮：‹
转资产按钮：⇢
```

头部：

```text
图标
编辑心愿
把未来会买的东西先记录下来，后面更容易回头比对。
```

表单：

```text
名称
placeholder：例如：降噪耳机

预期价格
placeholder：1299

分类
选项：未分类
选项：{category.icon} {category.name}

标签
{tag.name}

备注
placeholder：比如等降价、等活动

已归档
```

附加物品区：

```text
标题：附加物品
说明：比如耳机保护套、扩展坞之类，也可以附着在心愿上。
按钮：新增

每条 addon：
  名称
  价格
  删除
```

底部固定按钮：

```text
保存
```

保存时可能弹出的提示：

```text
请先填写心愿名称
```

### 分析页 `/analytics` 可见内容

头部：

```text
分析
导出分析按钮图标：sparkles
```

时间范围：

```text
全部
最近一周
最近90天
最近180天
最近一年
```

资产总值 Hero：

```text
资产总值
{summary.totalValue}

服役中 {percent}%
{servingValue}

已退役 {percent}%
{retiredValue}

已卖出 {percent}%
{soldValue}
```

趋势图：

```text
标题：资产价值趋势
x 轴：日期标签
y 轴：资产价值
```

洞察卡：

```text
平均日耗
{averageDailyCost}
说明：每件资产的日均成本

趋势变化
{trendDelta}
说明：从第一笔资产至今 / 近{range}天累计变化

主力分类
{topCategoryName 或 暂无}
说明：{topCategoryText}

标签覆盖
{tagCoverage}%
说明：有标签的资产占比
```

类型分布：

```text
标题：类型分布
说明：{categoryTotal} 件资产，{topCategoryText}
右上：{categoryDistribution.length}
donut 中心：{categoryTotal} 件
如果为空：暂无分类数据
每行：{category.name} {ratio}% {count}件
```

标签分布：

```text
标题：标签分布
说明：用来判断资产是不是被认真整理过
如果为空：暂无标签数据
每个标签：{tag.name} {count}
```

平均服役时长：

```text
标题：各类型平均服役时长
说明：平均 {averageServiceDays} 天，越长越接近“买得值”
如果为空：暂无可统计的分类
每行：{category.name} {averageDays} 天
```

日均成本排行：

```text
标题：日均成本排行
说明：优先关注这些“每天都在花钱”的资产
如果为空：暂无可排行资产
每行：
  排名 {index}
  {asset.name}
  {days} 天 · {statusLabel}
  {dailyCost}/天
```

### 设置页 `/settings` 可见内容

顶部：

```text
设置
已自动保存 / 正在保存
```

本机数据 Hero：

```text
本机数据
{assets.length + wishes.length}
资产与心愿记录保存在当前设备，备份后可随时恢复。
{categories.length} 分类
{tags.length} 标签
{snapshots.length} 快照
```

数值与单位：

```text
分组标题：数值与单位
显示预览
{moneyPreview}
{durationPreview} · 千位分隔 / 无千位分隔

货币单位
说明：控制所有金额的前缀显示
选项：CNY / USD / EUR / CNY 文本

小数点设置
说明：金额计算仍保留原始精度
选项：保留 0 位 / 保留 1 位 / 保留 2 位 / 保留 3 位

使用千位分隔符
说明：大额资产会更容易扫读

时长显示格式
说明：影响资产卡片和分析里的使用时长
选项：天数 / 周 / 月
```

数据管理：

```text
分组标题：数据管理

分类管理
说明：影响首页筛选和分析分布
右侧：{categories.length} 类

展开后：
  分类会参与统计
  建议保留 6-10 个主分类，分析图会更清楚。
  分类名称
  图标
  #7cc6f2
  添加
  每个分类：
    {category.icon}
    {category.name 或 未命名分类}
    name 输入框
    icon 输入框
    color 输入框
    上移
    下移
    保存
    删除

标签管理
说明：用来做细粒度筛选和覆盖率分析
右侧：{tags.length} 个

展开后：
  标签适合描述场景
  例如通勤、收藏、办公、长期持有。
  标签名称
  #7cc6f2
  添加
  每个标签：
    {tag.name 或 未命名标签}
    name 输入框
    color 输入框
    上移
    下移
    保存
    删除

备份与恢复
说明：导出 JSON，或创建本机快照
右侧：{snapshots.length} 份

展开后：
  恢复会覆盖当前数据
  建议先创建快照，再导入外部备份。
  导出 JSON
  覆盖恢复
  创建快照
  如果无快照：还没有快照
  每条快照：
    {snapshot.label}
    {snapshot.createdAt}
    恢复
```

显示与外观：

```text
分组标题：显示与外观

主题模式
说明：默认跟随系统，也可固定日间或夜间
选项：自动 / 日间 / 夜间

首页风格
说明：决定资产页默认的浏览方式
选项：默认 / 列表 / 贴纸

已退役计入总资产
说明：关闭后，分析和首页总值会排除退役资产
```

通用：

```text
分组标题：通用

登录状态
说明：当前所有数据都在本地使用
右侧：本地模式

到期提醒
说明：后续接入 Android 本地通知
```

设置页确认框：

```text
删除分类：
删除后，相关资产会变成未分类。继续吗？

删除标签：
删除后会从所有资产上移除这个标签。继续吗？

导入覆盖恢复：
这会覆盖当前全部数据，继续吗？

恢复快照：
恢复「{snapshot.label}」？
```

### 图标选择 Sheet 可见内容

所有资产/心愿表单共用。

```text
取消
选择图标
确定

分段项：
相册
Emoji
3D 图标
```

Emoji 模式：

```text
分类：常用 / 生活 / 交通 / 收藏 / 心情

常用：📦 ✨ 💡 ⭐ 🎯 🪄 🌟 🔥 🔖 🧩
生活：🏠 🛋️ 🍽️ 🧴 🎒 📱 💻 ⌚ 📷 🪑
交通：🚗 🚲 ✈️ 🛵 🚌 🚆 🧭 🧳 ⛱️ 🗺️
收藏：🎮 🎧 📚 💎 🖼️ 🎬 🧵 🪙 🃏 🏆
心情：💙 💚 🧡 💜 🤍 🖤 💛 ❤️ 🍀 ☕
```

3D 图标模式：

```text
分类：热门 / 数码 / 出行 / 娱乐 / 生活 / 收藏
图标来自 src/domain/iconLibrary.ts
每格显示 svg 图形 + label
```

相册模式：

```text
上传本地图片
支持相册里的图标、截图或者物件照片。
文件 input：accept image/*
如果选择图片：显示预览图
```

## 复原验收清单

如果一个新开发者完全不运行网页，只看本文档，应该能回答下面所有问题：

- App 有哪些路由，每个路由打开哪个页面
- 哪些页面是主 Tab，哪些页面是二级页
- 主 Tab 底部 Dock 有几个入口，每个入口跳哪里
- FAB 在不同主页面点击后跳哪里
- 二级页返回按钮在有历史和无历史时分别怎么处理
- 资产首页顶部、筛选区、分类区、列表区分别长什么样
- 资产首页三种视图分别显示哪些字段
- 搜索、筛选、排序 Bottom Sheet 内有哪些文案和控件
- 资产详情页每张卡片显示什么
- 资产编辑页有哪些字段，哪些字段按条件出现
- 新增页的资产 tab 和心愿 tab 分别有什么
- 心愿首页的统计卡、工具栏、心愿卡片显示什么
- 心愿转资产会复制哪些字段，会写入哪些转换字段
- 分析页每个统计模块显示什么，空数据时显示什么
- 设置页每个分组有什么，展开面板里有什么
- 分类、标签、备份恢复点击后分别发生什么
- 所有核心数据字段是什么，存到 localStorage 的哪一层
- 哪些是真功能，哪些只是 UI/预留
- 首次启动会有哪些种子数据

只要上面任意一条不能从文档里找到答案，就说明交接文档还不完整，需要继续补。

## 关键设计与交互约定

### 主/次页面壳逻辑

- 主 Tab 页面：`/assets`、`/wishes`、`/analytics`、`/settings`
  - 显示底部 Dock（`AppNav`）和右下角 FAB（`FloatingActionButton`）
- 二级页面：详情/编辑/新增
  - 隐藏 Dock 和 FAB
  - 显示固定左上返回按钮（由 `App.vue` 统一渲染）

相关文件：

- `src/App.vue`：路由切换动画 `route-fade`、全局返回按钮、Shell 显示逻辑
- `src/styles/base.css`：`has-global-back` 时的页面顶部留白与底部 padding 修正

### 页面切换动效

`App.vue` 中的 `Transition name="route-fade"` 控制路由切换：

- 进入/离开时透明度变化
- 带轻微 blur
- 带轻微上移和缩放
- 使用 `mode="out-in"`，先离开再进入
- 如果系统设置减少动态效果，则关闭 transform 和 blur

### 卡片与按钮反馈

大部分可点击组件都有：

- `:active` 缩放
- 卡片阴影变化
- segmented active pop
- 资产卡片入场 rise animation
- 贴纸视图按 id hash 生成轻微旋转和偏移

### Bottom Sheet

`BaseSheet` 用于搜索、筛选、排序、图标选择：

```text
┌──────────────────────────────┐
│ 背景遮罩 + blur               │
│                              │
│                              │
│ ┌──────────────────────────┐ │
│ │  handle                  │ │
│ │  sheet 内容              │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

- 移动端从底部滑出
- 宽屏时居中显示为圆角弹层
- 点击遮罩空白处关闭

### 图标选择器

`IconPickerSheet` 里有三种模式：

```text
[ 相册 | Emoji | 3D 图标 ]
```

- 相册：选择本地图片，读取为 data URL 并预览
- Emoji：按常用/生活/交通/收藏/心情分类选择
- 3D 图标：实际是内置 SVG 图标库，按热门/数码/出行/娱乐/生活/收藏分类
- 点击“确定”后才写回表单
- 点击“取消”只关闭，不改表单

## 数据与计算（很重要）

### 本地存储

当前数据库是纯 `localStorage` 模拟表结构：

- 存储 key：`youshu-cleanroom-db-state`
- 注意：这个 key 不建议轻易改，否则会造成用户本地数据“丢失”（实际是换了 key）

相关文件：

- `src/services/db.ts`：TableStore + 导入导出 + seed
- `src/stores/ledger.ts`：Pinia store，所有增删改、快照、恢复都走这里

存储内容：

```text
youshu-cleanroom-db-state
├── assets
├── wishes
├── categories
├── tags
├── settings
└── snapshots
```

### Store 状态

`src/stores/ledger.ts` 中维护：

- `ready`
- `settings`
- `assets`
- `wishes`
- `categories`
- `tags`
- `snapshots`

主要方法：

- `hydrate()`
- `reload()`
- `updateSettings()`
- `upsertAsset()`
- `deleteAsset()`
- `upsertWish()`
- `deleteWish()`
- `convertWishToAsset()`
- `upsertCategory()`
- `deleteCategory()`
- `upsertTag()`
- `deleteTag()`
- `reorderCategories()`
- `reorderTags()`
- `snapshot()`
- `importSnapshot()`
- `clearAllAndReload()`
- `applyTheme()`

### 成本与指标

关键规则在：

- `src/domain/formulas.ts`：净成本、服役天数、日均成本、金额/时长格式化等
- `src/utils/assetMetrics.ts`：趋势、分布、排行、目标进度等

需要留意的点：

- 服役天数用“包含首尾日期”的天数（最少 1）
- 净成本会扣除已卖出资产的卖出价，并将“计入日均”的附加物品纳入成本
- 总资产价值会排除已卖出资产；退役是否计入由设置控制
- 如果资产关闭“计入日均”，排行和平均日耗会忽略该资产

基础公式：

```text
服役天数 = purchaseDate 到结束日期的包含首尾天数，最少 1

结束日期：
  sold    -> soldAt
  retired -> retiredAt
  serving -> today

净成本 = 购买价格 + 计入日均的附加物品价格 - 卖出价格

日均成本 = 净成本 / 服役天数

资产价值 = 购买价格 + 计入总资产或计入日均的附加物品价格
```

## 已知限制 / TODO

- 到期提醒目前只有设置项与字段，未接入系统通知（Android/iOS/Web Notification）
- 没有账号体系/云同步，只有本地 + JSON/快照备份
- ECharts 体积导致构建 chunk warning；可做路由懒加载与手动拆分
- Capacitor 配置存在（`capacitor.config.json`），但当前交互与数据都以 Web 为主
- `SettingsHome.deleteTag` 当前只清理资产上的标签引用，没有清理心愿上的标签引用
- 图标图片以 data URL 存入字段，长期大量图片可能导致 localStorage 体积膨胀

## 最近一次重构/改动摘要（供接手者对齐）

- 品牌名从“有数”替换为“Valora”
  - `index.html` title、`src/pages/AssetHome.vue` 标题、`capacitor.config.json` appName
- 页面切换使用淡入淡出过渡（`App.vue` 的 `route-fade`）
- 二级页返回按钮统一固定左上角（`App.vue` 渲染），页面内部旧返回按钮已移除
- 底部 Dock 做成半透明“液态玻璃”，可透出底下内容
- 首页信息密度提升，筛选/切换/按压反馈、卡片入场动效完善
- 设置页数据管理模块改为点击展开，使用 Vue Transition 做展开动画
- 平板适配：主壳宽度、首页/分析/设置布局在宽屏下自动切换
- 备份文件名调整为 `Valora-backup-YYYY-MM-DD.json`（不影响存储 key）

## 主要文件索引

- 入口/路由：`src/main.ts`、`src/router.ts`、`src/App.vue`
- 样式：`src/styles/tokens.css`、`src/styles/base.css`
- 数据：`src/services/db.ts`、`src/stores/ledger.ts`
- 模型/计算：`src/domain/models.ts`、`src/domain/formulas.ts`、`src/utils/assetMetrics.ts`
- 页面：`src/pages/*`
- 组件：`src/components/*`
