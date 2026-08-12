# VALORA B12 到期提醒闭环验证

## 目标

让到期提醒从资产字段和设置开关进入持久化记录，由 Android 统一调度，并在应用启动、设备重启、时区变化、系统时间变化和应用更新后恢复。

## 已完成内容

- 增加 `ReminderRecord`，持久化 reminderId、来源资产、提醒类型、本地日期、UTC 触发时间、启用状态和最近调度结果
- 资产到期/保修提醒按 `expiresAt - remindBeforeDays` 生成；资产自定义目标日期生成独立提醒
- 每个提醒使用稳定 ID 和独立通知 ID；资产新增、修改、删除和全局开关变化都会触发同步
- 增加 Android `ReminderScheduler`，先取消旧集合再按当前数据重排，避免修改后残留旧闹钟
- 使用 `AlarmManager.set()` 的日期级不精确调度，不申请 exact alarm 权限
- `BootReceiver` 处理 boot、locked boot、timezone/time change 和 package replaced 广播
- 时区重排优先使用持久化的本地 `triggerDate`，在当前时区重新计算 09:00；旧记录可从 `triggerAt` 兼容回填
- Android 13+ 通知权限拒绝会记录 `permission_denied`，主界面设置页展示 scheduled/pending/disabled/failed 状态
- 设置页状态查询做了 Future 缓存，只在提醒开关或持久化 revision 变化时刷新

## 关键边界

- 提醒正文只包含资产名称和日期，不写入账号、密码、服务器地址或本地路径
- 取消、修改和删除通过同一 `syncReminders` 路径撤销旧 PendingIntent
- `AlarmManager.set()` 保持日期级、不精确语义；产品不依赖分钟级精确触发
- 真机上通知权限弹窗、锁屏、重启、时区切换、电池限制和通知渠道仍需设备验收

## 验证记录

- Dart 提醒模型/持久化测试：3/3 通过
- Android 调度器与原生桥接单测：7/7 通过
- Flutter 全量测试：52/52 通过
- `flutter analyze --no-pub --fatal-warnings --no-fatal-infos`：退出码 0；仓库现有 492 条 info，无 warning/error
- `dart run tooling/format_check.dart`：检查 25 个 Dart 文件，0 个文件发生格式变化；排除 5 个基线文件
- `git diff --check`：通过，仅报告工作区已有的换行风格提示
- Debug APK：`build/app/outputs/flutter-apk/app-debug.apk`
  - 构建时间：2026-08-13 02:00:37
  - 文件大小：121,676,091 bytes
  - SHA256：`1D9EBCB8D83C57E6E3F344A166089B6E111E6E3B5AADDF545A60E011058FBE31`

## 未覆盖范围

本块完成了数据模型、调度恢复和自动化验证，未声称完成真机验收。后续设备测试需要覆盖 Android 7、10、13+ 的权限、重启、系统时间/时区变化、通知渠道关闭、后台限制和多条同日提醒。
