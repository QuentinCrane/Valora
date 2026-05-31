# v66 蓝色 Material 日期选择与附加项目购买时间

## 1. 日期选择器核查与美化

v65 已经使用 Android Material Components 的 `MaterialDatePicker.Builder.datePicker()`，并依赖 `com.google.android.material:material:1.14.0`。

v66 在此基础上继续补齐：

- Flutter 调用原生日期选择器时会把当前字段名作为标题传给 Android，例如“购买日期”“到期日期”“购买时间”。
- 原生 Material DatePicker 的主题继续统一到Valora主色：`#7CC6F2` / `#113056`。
- 增加 `colorPrimaryContainer`、`colorSecondaryContainer`、`colorOutline`、`android:colorAccent` 等主题项，让日历选择状态、按钮和轮廓更接近 App 的蓝色体系。
- 日期输入框 helper 文案改为“Android Material 3 日期选择器”，避免误以为还是旧系统 DatePickerDialog。

## 2. 附加项目支持购买时间

`AddonItem` 新增：

- `purchaseDate: DateTime?`
- `purchaseDateLabel`
- JSON 持久化字段：
  - `purchaseDate`
  - `purchaseDateYmd`
  - `purchaseDateEpochDay`

## 3. 表单入口

资产编辑页的“添加附加项目”新增“购买时间”字段。

心愿/快速录入里的“添加附加物品”也同步新增“购买时间”字段，后续从心愿转资产时会保留该时间。

## 4. 显示入口

- 资产编辑页附加项目列表显示购买时间。
- 资产详情页附加项目明细显示购买时间。
- 心愿录入附加物品列表显示购买时间。

## 5. 兼容旧数据

旧备份或旧数据库中的附加项目没有购买时间时，会显示为“未设置购买时间”，不会影响原有导入和读取。
