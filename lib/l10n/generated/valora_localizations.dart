import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'valora_localizations_en.dart';
import 'valora_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ValoraLocalizations
/// returned by `ValoraLocalizations.of(context)`.
///
/// Applications need to include `ValoraLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/valora_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ValoraLocalizations.localizationsDelegates,
///   supportedLocales: ValoraLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ValoraLocalizations.supportedLocales
/// property.
abstract class ValoraLocalizations {
  ValoraLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ValoraLocalizations of(BuildContext context) {
    return Localizations.of<ValoraLocalizations>(context, ValoraLocalizations)!;
  }

  static const LocalizationsDelegate<ValoraLocalizations> delegate =
      _ValoraLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @message_app_name.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱'**
  String get message_app_name;

  /// No description provided for @message_app_name_en.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Valora'**
  String get message_app_name_en;

  /// No description provided for @message_language_system.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统'**
  String get message_language_system;

  /// No description provided for @message_language_system_short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统'**
  String get message_language_system_short;

  /// No description provided for @message_language_zhHans.
  ///
  /// In zh_Hans, this message translates to:
  /// **'简体中文'**
  String get message_language_zhHans;

  /// No description provided for @message_language_zhHans_short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'简中'**
  String get message_language_zhHans_short;

  /// No description provided for @message_language_zhHant.
  ///
  /// In zh_Hans, this message translates to:
  /// **'繁体中文'**
  String get message_language_zhHant;

  /// No description provided for @message_language_zhHant_short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'繁中'**
  String get message_language_zhHant_short;

  /// No description provided for @message_language_en.
  ///
  /// In zh_Hans, this message translates to:
  /// **'English'**
  String get message_language_en;

  /// No description provided for @message_language_en_short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'EN'**
  String get message_language_en_short;

  /// No description provided for @message_settings_language.
  ///
  /// In zh_Hans, this message translates to:
  /// **'语言'**
  String get message_settings_language;

  /// No description provided for @message_settings_language_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统语言，也可在这里固定为简体中文、繁体中文或英文'**
  String get message_settings_language_desc;

  /// No description provided for @message_settings_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置'**
  String get message_settings_title;

  /// No description provided for @message_settings_localMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地模式'**
  String get message_settings_localMode;

  /// No description provided for @message_settings_menu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置菜单'**
  String get message_settings_menu;

  /// No description provided for @message_settings_quick.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快速入口'**
  String get message_settings_quick;

  /// No description provided for @message_settings_dataBackup.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数据与备份'**
  String get message_settings_dataBackup;

  /// No description provided for @message_settings_dataBackup_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类、标签、完整 ZIP、JSON、快照、云端同步'**
  String get message_settings_dataBackup_desc;

  /// No description provided for @message_settings_appearanceInteraction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'外观与交互'**
  String get message_settings_appearanceInteraction;

  /// No description provided for @message_settings_appearanceInteraction_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、首页样式、金额、时长、触感、提示条、贴纸引擎'**
  String get message_settings_appearanceInteraction_desc;

  /// No description provided for @message_settings_systemPermissions.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统与权限'**
  String get message_settings_systemPermissions;

  /// No description provided for @message_settings_systemPermissions_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生能力、小组件、通知、系统设置、云端快捷操作'**
  String get message_settings_systemPermissions_desc;

  /// No description provided for @message_settings_onboarding.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新手教程'**
  String get message_settings_onboarding;

  /// No description provided for @message_settings_onboarding_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重新查看完整使用教程和功能导览'**
  String get message_settings_onboarding_desc;

  /// No description provided for @message_settings_start.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开始'**
  String get message_settings_start;

  /// No description provided for @message_settings_categoryManage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类管理'**
  String get message_settings_categoryManage;

  /// No description provided for @message_settings_categoryManage_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'支持图标、颜色和推荐体系'**
  String get message_settings_categoryManage_desc;

  /// No description provided for @message_settings_backupRestore.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备份与恢复'**
  String get message_settings_backupRestore;

  /// No description provided for @message_settings_backupRestore_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完整资料包 ZIP、JSON、快照与恢复'**
  String get message_settings_backupRestore_desc;

  /// No description provided for @message_settings_tab_overview.
  ///
  /// In zh_Hans, this message translates to:
  /// **'总览'**
  String get message_settings_tab_overview;

  /// No description provided for @message_settings_tab_data.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数据与备份'**
  String get message_settings_tab_data;

  /// No description provided for @message_settings_tab_appearance.
  ///
  /// In zh_Hans, this message translates to:
  /// **'外观与交互'**
  String get message_settings_tab_appearance;

  /// No description provided for @message_settings_tab_system.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统与权限'**
  String get message_settings_tab_system;

  /// No description provided for @message_settings_tab_overview_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'常用管理、格式预览和高频入口'**
  String get message_settings_tab_overview_subtitle;

  /// No description provided for @message_settings_tab_data_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'整理分类、标签、备份、迁移和云端同步'**
  String get message_settings_tab_data_subtitle;

  /// No description provided for @message_settings_tab_appearance_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、语言、显示格式、触感反馈和贴纸效果'**
  String get message_settings_tab_appearance_subtitle;

  /// No description provided for @message_settings_tab_system_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 原生能力、权限、通知、小组件和快捷操作'**
  String get message_settings_tab_system_subtitle;

  /// No description provided for @message_settings_pill_submenu.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单'**
  String get message_settings_pill_submenu;

  /// No description provided for @message_settings_commonManagement.
  ///
  /// In zh_Hans, this message translates to:
  /// **'常用管理'**
  String get message_settings_commonManagement;

  /// No description provided for @message_settings_categoryTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类与标签'**
  String get message_settings_categoryTags;

  /// No description provided for @message_settings_manage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'管理'**
  String get message_settings_manage;

  /// No description provided for @message_settings_aggregate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'聚合'**
  String get message_settings_aggregate;

  /// No description provided for @message_settings_system.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统'**
  String get message_settings_system;

  /// No description provided for @message_settings_assetOrg.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产组织'**
  String get message_settings_assetOrg;

  /// No description provided for @message_settings_tagsManage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签管理'**
  String get message_settings_tagsManage;

  /// No description provided for @message_settings_backupMigration.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备份与迁移'**
  String get message_settings_backupMigration;

  /// No description provided for @message_settings_cloudSync.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端同步'**
  String get message_settings_cloudSync;

  /// No description provided for @message_settings_shareArchive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享完整资料包'**
  String get message_settings_shareArchive;

  /// No description provided for @message_settings_danger.
  ///
  /// In zh_Hans, this message translates to:
  /// **'危险操作'**
  String get message_settings_danger;

  /// No description provided for @message_settings_clearLocalData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清空本地数据'**
  String get message_settings_clearLocalData;

  /// No description provided for @message_settings_displayFormat.
  ///
  /// In zh_Hans, this message translates to:
  /// **'显示与格式'**
  String get message_settings_displayFormat;

  /// No description provided for @message_settings_themeMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题模式'**
  String get message_settings_themeMode;

  /// No description provided for @message_settings_themeMode_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随系统，也可固定日间或夜间'**
  String get message_settings_themeMode_desc;

  /// No description provided for @message_settings_glassEffect.
  ///
  /// In zh_Hans, this message translates to:
  /// **'玻璃效果'**
  String get message_settings_glassEffect;

  /// No description provided for @message_settings_glassSoftness.
  ///
  /// In zh_Hans, this message translates to:
  /// **'玻璃柔化'**
  String get message_settings_glassSoftness;

  /// No description provided for @message_settings_glassSoftness_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'同时调整通透度与背景模糊，让液态玻璃更柔和清晰'**
  String get message_settings_glassSoftness_desc;

  /// No description provided for @message_settings_glassSoftness_clear.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通透'**
  String get message_settings_glassSoftness_clear;

  /// No description provided for @message_settings_glassSoftness_soft.
  ///
  /// In zh_Hans, this message translates to:
  /// **'柔和'**
  String get message_settings_glassSoftness_soft;

  /// No description provided for @message_settings_glassSoftness_frosted.
  ///
  /// In zh_Hans, this message translates to:
  /// **'雾化'**
  String get message_settings_glassSoftness_frosted;

  /// No description provided for @message_settings_motionMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'动效强度'**
  String get message_settings_motionMode;

  /// No description provided for @message_settings_motionMode_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分级控制页面转场、按压反馈和液态玻璃刷新，系统减少动效时自动降级'**
  String get message_settings_motionMode_desc;

  /// No description provided for @message_settings_homeStyle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'首页风格'**
  String get message_settings_homeStyle;

  /// No description provided for @message_settings_includeRetired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役计入总资产'**
  String get message_settings_includeRetired;

  /// No description provided for @message_settings_includeRetired_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭后，分析和首页总值会排除退役资产'**
  String get message_settings_includeRetired_desc;

  /// No description provided for @message_settings_currencySymbol.
  ///
  /// In zh_Hans, this message translates to:
  /// **'货币符号'**
  String get message_settings_currencySymbol;

  /// No description provided for @message_settings_currencySymbol_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'控制所有金额的前缀显示'**
  String get message_settings_currencySymbol_desc;

  /// No description provided for @message_settings_decimalPlaces.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小数位数'**
  String get message_settings_decimalPlaces;

  /// No description provided for @message_settings_decimalPlaces_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'金额计算仍保留原始精度'**
  String get message_settings_decimalPlaces_desc;

  /// No description provided for @message_settings_thousands.
  ///
  /// In zh_Hans, this message translates to:
  /// **'千位分隔符'**
  String get message_settings_thousands;

  /// No description provided for @message_settings_thousands_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'大额资产会更容易扫读'**
  String get message_settings_thousands_desc;

  /// No description provided for @message_settings_durationDisplay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时长显示'**
  String get message_settings_durationDisplay;

  /// No description provided for @message_settings_durationDisplay_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影响资产卡片和分析里的使用时长'**
  String get message_settings_durationDisplay_desc;

  /// No description provided for @message_settings_homeMetaScale.
  ///
  /// In zh_Hans, this message translates to:
  /// **'首页副信息字号'**
  String get message_settings_homeMetaScale;

  /// No description provided for @message_settings_homeMetaScale_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调整首页资产卡片中“价格 / 已使用时间”等小字，避免持有时间被省略'**
  String get message_settings_homeMetaScale_desc;

  /// No description provided for @message_analytics_countUnit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'个'**
  String get message_analytics_countUnit;

  /// No description provided for @message_theme_light.
  ///
  /// In zh_Hans, this message translates to:
  /// **'浅色'**
  String get message_theme_light;

  /// No description provided for @message_theme_dark.
  ///
  /// In zh_Hans, this message translates to:
  /// **'深色'**
  String get message_theme_dark;

  /// No description provided for @message_theme_system.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统'**
  String get message_theme_system;

  /// No description provided for @message_duration_days.
  ///
  /// In zh_Hans, this message translates to:
  /// **'天'**
  String get message_duration_days;

  /// No description provided for @message_duration_weeks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周'**
  String get message_duration_weeks;

  /// No description provided for @message_duration_months.
  ///
  /// In zh_Hans, this message translates to:
  /// **'月'**
  String get message_duration_months;

  /// No description provided for @message_duration_years.
  ///
  /// In zh_Hans, this message translates to:
  /// **'年/月'**
  String get message_duration_years;

  /// No description provided for @message_boot_loading.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在打开值谱'**
  String get message_boot_loading;

  /// No description provided for @message_error_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'界面加载遇到问题'**
  String get message_error_title;

  /// No description provided for @message_error_description.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可以返回上一页或重启应用，再尝试刚才的操作'**
  String get message_error_description;

  /// No description provided for @message_store_recovery_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地数据需要恢复'**
  String get message_store_recovery_title;

  /// No description provided for @message_store_recovery_fatalTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地存储不可用'**
  String get message_store_recovery_fatalTitle;

  /// No description provided for @message_store_recovery_description.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱无法确认本地数据完整性，当前不会覆盖或清空已有数据'**
  String get message_store_recovery_description;

  /// No description provided for @message_store_recovery_readOnly.
  ///
  /// In zh_Hans, this message translates to:
  /// **'应用已进入只读恢复模式。请重试，或稍后使用备份恢复'**
  String get message_store_recovery_readOnly;

  /// No description provided for @message_store_recovery_snapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'最近一次校验成功的快照已保留'**
  String get message_store_recovery_snapshot;

  /// No description provided for @message_store_recovery_retry.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重试读取'**
  String get message_store_recovery_retry;

  /// No description provided for @message_store_recovery_code.
  ///
  /// In zh_Hans, this message translates to:
  /// **'错误代码'**
  String get message_store_recovery_code;

  /// No description provided for @message_dock_assets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产'**
  String get message_dock_assets;

  /// No description provided for @message_dock_wishes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿'**
  String get message_dock_wishes;

  /// No description provided for @message_dock_analytics.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析'**
  String get message_dock_analytics;

  /// No description provided for @message_dock_settings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置'**
  String get message_dock_settings;

  /// No description provided for @message_common_add.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加'**
  String get message_common_add;

  /// No description provided for @message_common_all.
  ///
  /// In zh_Hans, this message translates to:
  /// **'全部'**
  String get message_common_all;

  /// No description provided for @message_common_back.
  ///
  /// In zh_Hans, this message translates to:
  /// **'返回'**
  String get message_common_back;

  /// No description provided for @message_common_cancel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'取消'**
  String get message_common_cancel;

  /// No description provided for @message_common_clear.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清空'**
  String get message_common_clear;

  /// No description provided for @message_common_close.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭'**
  String get message_common_close;

  /// No description provided for @message_common_confirm.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确认'**
  String get message_common_confirm;

  /// No description provided for @message_common_delete.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除'**
  String get message_common_delete;

  /// No description provided for @message_common_done.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完成'**
  String get message_common_done;

  /// No description provided for @message_common_edit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑'**
  String get message_common_edit;

  /// No description provided for @message_common_undo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'撤销'**
  String get message_common_undo;

  /// No description provided for @message_common_undone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已撤销'**
  String get message_common_undone;

  /// No description provided for @message_common_undoUnavailable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这项操作已无法撤销'**
  String get message_common_undoUnavailable;

  /// No description provided for @message_common_no.
  ///
  /// In zh_Hans, this message translates to:
  /// **'否'**
  String get message_common_no;

  /// No description provided for @message_common_required.
  ///
  /// In zh_Hans, this message translates to:
  /// **'必填'**
  String get message_common_required;

  /// No description provided for @message_common_invalidNumber.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入有效数字'**
  String get message_common_invalidNumber;

  /// No description provided for @message_common_reset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重置'**
  String get message_common_reset;

  /// No description provided for @message_common_resetAll.
  ///
  /// In zh_Hans, this message translates to:
  /// **'全部重置'**
  String get message_common_resetAll;

  /// No description provided for @message_common_save.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存'**
  String get message_common_save;

  /// No description provided for @message_common_selectDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择日期'**
  String get message_common_selectDate;

  /// No description provided for @message_common_unset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未设置'**
  String get message_common_unset;

  /// No description provided for @message_common_yes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'是'**
  String get message_common_yes;

  /// No description provided for @message_common_uncategorized.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未分类'**
  String get message_common_uncategorized;

  /// No description provided for @message_delete_assetUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除资产后可撤销'**
  String get message_delete_assetUndo;

  /// No description provided for @message_delete_wishUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除心愿后可撤销'**
  String get message_delete_wishUndo;

  /// No description provided for @message_delete_categoryUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除分类后可撤销'**
  String get message_delete_categoryUndo;

  /// No description provided for @message_delete_tagUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除标签后可撤销'**
  String get message_delete_tagUndo;

  /// No description provided for @message_delete_snapshotUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除快照后可撤销'**
  String get message_delete_snapshotUndo;

  /// No description provided for @message_delete_resetUndo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清空数据后可撤销'**
  String get message_delete_resetUndo;

  /// No description provided for @message_destructive_impact.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影响摘要'**
  String get message_destructive_impact;

  /// No description provided for @message_destructive_cancelNoChange.
  ///
  /// In zh_Hans, this message translates to:
  /// **'取消不会改变任何数据'**
  String get message_destructive_cancelNoChange;

  /// No description provided for @message_destructive_target.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标 {count} 项'**
  String message_destructive_target({required Object count});

  /// No description provided for @message_destructive_assets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产 {count} 项'**
  String message_destructive_assets({required Object count});

  /// No description provided for @message_destructive_wishes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿 {count} 项'**
  String message_destructive_wishes({required Object count});

  /// No description provided for @message_destructive_categories.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类 {count} 项'**
  String message_destructive_categories({required Object count});

  /// No description provided for @message_destructive_tags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签 {count} 项'**
  String message_destructive_tags({required Object count});

  /// No description provided for @message_destructive_recoveryRecords.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收记录 {count} 条'**
  String message_destructive_recoveryRecords({required Object count});

  /// No description provided for @message_destructive_snapshots.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照 {count} 份'**
  String message_destructive_snapshots({required Object count});

  /// No description provided for @message_destructive_snapshotPreview.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照内容预览'**
  String get message_destructive_snapshotPreview;

  /// No description provided for @message_destructive_snapshotInvalid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这份快照无法读取，暂不能恢复'**
  String get message_destructive_snapshotInvalid;

  /// No description provided for @message_AssetStatus_serving.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役中'**
  String get message_AssetStatus_serving;

  /// No description provided for @message_AssetStatus_retired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役'**
  String get message_AssetStatus_retired;

  /// No description provided for @message_AssetStatus_sold.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出'**
  String get message_AssetStatus_sold;

  /// No description provided for @message_AssetValueMode_priced.
  ///
  /// In zh_Hans, this message translates to:
  /// **'普通资产'**
  String get message_AssetValueMode_priced;

  /// No description provided for @message_AssetValueMode_priceless.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝'**
  String get message_AssetValueMode_priceless;

  /// No description provided for @message_TargetMode_none.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无目标'**
  String get message_TargetMode_none;

  /// No description provided for @message_TargetMode_daily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均'**
  String get message_TargetMode_daily;

  /// No description provided for @message_TargetMode_date.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日期'**
  String get message_TargetMode_date;

  /// No description provided for @message_TargetMode_custom.
  ///
  /// In zh_Hans, this message translates to:
  /// **'天数'**
  String get message_TargetMode_custom;

  /// No description provided for @message_HomeViewMode_grid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卡片'**
  String get message_HomeViewMode_grid;

  /// No description provided for @message_HomeViewMode_list.
  ///
  /// In zh_Hans, this message translates to:
  /// **'列表'**
  String get message_HomeViewMode_list;

  /// No description provided for @message_HomeViewMode_sticker.
  ///
  /// In zh_Hans, this message translates to:
  /// **'贴纸'**
  String get message_HomeViewMode_sticker;

  /// No description provided for @message_StickerEngineMode_compact.
  ///
  /// In zh_Hans, this message translates to:
  /// **'轻量'**
  String get message_StickerEngineMode_compact;

  /// No description provided for @message_StickerEngineMode_balanced.
  ///
  /// In zh_Hans, this message translates to:
  /// **'均衡'**
  String get message_StickerEngineMode_balanced;

  /// No description provided for @message_StickerEngineMode_quality.
  ///
  /// In zh_Hans, this message translates to:
  /// **'精细'**
  String get message_StickerEngineMode_quality;

  /// No description provided for @message_StickerEngineMode_hqExperimental.
  ///
  /// In zh_Hans, this message translates to:
  /// **'高质量实验'**
  String get message_StickerEngineMode_hqExperimental;

  /// No description provided for @message_StickerEngineMode_compact_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'输入更小、候选更少，速度快且更省体积'**
  String get message_StickerEngineMode_compact_desc;

  /// No description provided for @message_StickerEngineMode_balanced_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日常默认，速度与效果平衡'**
  String get message_StickerEngineMode_balanced_desc;

  /// No description provided for @message_StickerEngineMode_quality_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'输入更大、候选更多，效果更稳但更慢'**
  String get message_StickerEngineMode_quality_desc;

  /// No description provided for @message_StickerEngineMode_hqExperimental_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'更大的输入和更多候选，尽量提升抠图质量，但会更慢'**
  String get message_StickerEngineMode_hqExperimental_desc;

  /// No description provided for @message_GlassEffectMode_classic.
  ///
  /// In zh_Hans, this message translates to:
  /// **'经典毛玻璃'**
  String get message_GlassEffectMode_classic;

  /// No description provided for @message_GlassEffectMode_liquid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'液态玻璃'**
  String get message_GlassEffectMode_liquid;

  /// No description provided for @message_GlassEffectMode_classic_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用 0.79 风格的轻量高斯模糊，稳定、省电、清晰'**
  String get message_GlassEffectMode_classic_desc;

  /// No description provided for @message_GlassEffectMode_liquid_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用场景级液态玻璃折射效果，Dock、加号和保存按钮更有流动质感'**
  String get message_GlassEffectMode_liquid_desc;

  /// No description provided for @message_MotionMode_full.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完整动效'**
  String get message_MotionMode_full;

  /// No description provided for @message_MotionMode_reduced.
  ///
  /// In zh_Hans, this message translates to:
  /// **'减少动效'**
  String get message_MotionMode_reduced;

  /// No description provided for @message_MotionMode_off.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭动效'**
  String get message_MotionMode_off;

  /// No description provided for @message_MotionMode_full_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留完整转场、按压反馈和实时液态玻璃'**
  String get message_MotionMode_full_desc;

  /// No description provided for @message_MotionMode_reduced_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'缩短动画并降低液态玻璃刷新频率，优先保证滚动流畅'**
  String get message_MotionMode_reduced_desc;

  /// No description provided for @message_MotionMode_off_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'移除动画和实时捕获，改用静态轻量毛玻璃'**
  String get message_MotionMode_off_desc;

  /// No description provided for @message_SortMode_dailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均'**
  String get message_SortMode_dailyCost;

  /// No description provided for @message_SortMode_price.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格'**
  String get message_SortMode_price;

  /// No description provided for @message_SortMode_days.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时长'**
  String get message_SortMode_days;

  /// No description provided for @message_SortMode_recent.
  ///
  /// In zh_Hans, this message translates to:
  /// **'最新'**
  String get message_SortMode_recent;

  /// No description provided for @message_time_day.
  ///
  /// In zh_Hans, this message translates to:
  /// **'天'**
  String get message_time_day;

  /// No description provided for @message_time_week.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周'**
  String get message_time_week;

  /// No description provided for @message_time_month.
  ///
  /// In zh_Hans, this message translates to:
  /// **'月'**
  String get message_time_month;

  /// No description provided for @message_time_year.
  ///
  /// In zh_Hans, this message translates to:
  /// **'年'**
  String get message_time_year;

  /// No description provided for @message_time_perDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'/天'**
  String get message_time_perDay;

  /// No description provided for @message_asset_purchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期'**
  String get message_asset_purchaseDate;

  /// No description provided for @message_asset_recordDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期'**
  String get message_asset_recordDate;

  /// No description provided for @message_asset_dailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本'**
  String get message_asset_dailyCost;

  /// No description provided for @message_asset_sinceLast.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已记录'**
  String get message_asset_sinceLast;

  /// No description provided for @message_model_addonItem.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加项'**
  String get message_model_addonItem;

  /// No description provided for @message_model_localSnapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地快照'**
  String get message_model_localSnapshot;

  /// No description provided for @message_model_tag.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签'**
  String get message_model_tag;

  /// No description provided for @message_model_uncategorized.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未分类'**
  String get message_model_uncategorized;

  /// No description provided for @message_model_unnamedAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未命名资产'**
  String get message_model_unnamedAsset;

  /// No description provided for @message_model_unnamedWish.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未命名心愿'**
  String get message_model_unnamedWish;

  /// No description provided for @message_model_valueRecovery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收'**
  String get message_model_valueRecovery;

  /// No description provided for @message_cloud_off.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭'**
  String get message_cloud_off;

  /// No description provided for @message_cloud_jianguoyun.
  ///
  /// In zh_Hans, this message translates to:
  /// **'坚果云'**
  String get message_cloud_jianguoyun;

  /// No description provided for @message_cloud_customWebdav.
  ///
  /// In zh_Hans, this message translates to:
  /// **'自定义 WebDAV'**
  String get message_cloud_customWebdav;

  /// No description provided for @message_cloud_manualFile.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手动文件'**
  String get message_cloud_manualFile;

  /// No description provided for @message_validation_nameRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入名称'**
  String get message_validation_nameRequired;

  /// No description provided for @message_validation_moneyInvalid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'金额必须是有效数字'**
  String get message_validation_moneyInvalid;

  /// No description provided for @message_validation_moneyNegative.
  ///
  /// In zh_Hans, this message translates to:
  /// **'金额不能为负数'**
  String get message_validation_moneyNegative;

  /// No description provided for @message_validation_purchaseDateFuture.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期不能晚于今天'**
  String get message_validation_purchaseDateFuture;

  /// No description provided for @message_validation_dateBeforePurchase.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日期不能早于购买日期'**
  String get message_validation_dateBeforePurchase;

  /// No description provided for @message_validation_lifecycleDateFuture.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生命周期日期不能晚于今天'**
  String get message_validation_lifecycleDateFuture;

  /// No description provided for @message_validation_soldDateRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已售资产需要填写卖出日期'**
  String get message_validation_soldDateRequired;

  /// No description provided for @message_validation_soldPriceOnlyForSold.
  ///
  /// In zh_Hans, this message translates to:
  /// **'只有卖出状态的资产可以填写卖出价'**
  String get message_validation_soldPriceOnlyForSold;

  /// No description provided for @message_validation_retiredDateRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役资产需要填写退役日期'**
  String get message_validation_retiredDateRequired;

  /// No description provided for @message_validation_recoveryAssetRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请选择至少一项资产'**
  String get message_validation_recoveryAssetRequired;

  /// No description provided for @message_validation_recoveryAssetMissing.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收关联的资产不存在'**
  String get message_validation_recoveryAssetMissing;

  /// No description provided for @message_validation_recoveryDateOutsideLifecycle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收日期不在资产生命周期内'**
  String get message_validation_recoveryDateOutsideLifecycle;

  /// No description provided for @message_validation_addonNameRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入附加项名称'**
  String get message_validation_addonNameRequired;

  /// No description provided for @message_store_localWriteFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地写入失败'**
  String get message_store_localWriteFailed;

  /// No description provided for @message_store_localSnapshotFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地快照保存失败'**
  String get message_store_localSnapshotFailed;

  /// No description provided for @message_store_credentialsSaveFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'安全凭据保存失败'**
  String get message_store_credentialsSaveFailed;

  /// No description provided for @message_store_credentialsClearFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'安全凭据清除失败'**
  String get message_store_credentialsClearFailed;

  /// No description provided for @message_store_sqliteVerifyFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'SQLite 写入校验失败'**
  String get message_store_sqliteVerifyFailed;

  /// No description provided for @message_native_error_cancelled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'操作已取消'**
  String get message_native_error_cancelled;

  /// No description provided for @message_native_error_busy.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有一个原生操作正在进行'**
  String get message_native_error_busy;

  /// No description provided for @message_native_error_permissionDenied.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有获得所需权限'**
  String get message_native_error_permissionDenied;

  /// No description provided for @message_native_error_insufficientStorage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设备存储空间不足'**
  String get message_native_error_insufficientStorage;

  /// No description provided for @message_native_error_invalidFormat.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生返回格式无效'**
  String get message_native_error_invalidFormat;

  /// No description provided for @message_native_error_modelUnavailable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'模型暂不可用，请稍后重试'**
  String get message_native_error_modelUnavailable;

  /// No description provided for @message_native_error_timeout.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生操作超时'**
  String get message_native_error_timeout;

  /// No description provided for @message_native_error_unavailable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前设备不支持此操作'**
  String get message_native_error_unavailable;

  /// No description provided for @message_native_error_processingFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生处理失败'**
  String get message_native_error_processingFailed;

  /// No description provided for @message_native_error_notImplemented.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前版本不支持此操作'**
  String get message_native_error_notImplemented;

  /// No description provided for @message_native_error_unknown.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生操作失败'**
  String get message_native_error_unknown;

  /// No description provided for @message_store_persistence_saving.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在保存本地数据'**
  String get message_store_persistence_saving;

  /// No description provided for @message_store_persistence_failed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地保存失败'**
  String get message_store_persistence_failed;

  /// No description provided for @message_store_persistence_retry.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重试保存'**
  String get message_store_persistence_retry;

  /// No description provided for @message_store_persistence_retryDone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地数据已保存'**
  String get message_store_persistence_retryDone;

  /// No description provided for @message_store_persistence_retryFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重试保存仍然失败'**
  String get message_store_persistence_retryFailed;

  /// No description provided for @message_store_uncategorized.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未分类'**
  String get message_store_uncategorized;

  /// No description provided for @message_store_pricelessKeywords.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价 珍藏 纪念'**
  String get message_store_pricelessKeywords;

  /// No description provided for @message_store_tagIdle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'吃灰'**
  String get message_store_tagIdle;

  /// No description provided for @message_store_localSnapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地快照'**
  String get message_store_localSnapshot;

  /// No description provided for @message_analytics_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析'**
  String get message_analytics_title;

  /// No description provided for @message_analytics_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用聚合数据判断资产是否值得继续持有'**
  String get message_analytics_subtitle;

  /// No description provided for @message_analytics_coreMetrics.
  ///
  /// In zh_Hans, this message translates to:
  /// **'核心指标'**
  String get message_analytics_coreMetrics;

  /// No description provided for @message_analytics_totalAssetValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产总值'**
  String get message_analytics_totalAssetValue;

  /// No description provided for @message_analytics_avgDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'平均日耗'**
  String get message_analytics_avgDailyCost;

  /// No description provided for @message_analytics_totalInvested.
  ///
  /// In zh_Hans, this message translates to:
  /// **'累计投入'**
  String get message_analytics_totalInvested;

  /// No description provided for @message_analytics_wishBudget.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿预算'**
  String get message_analytics_wishBudget;

  /// No description provided for @message_analytics_valueTrend.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期价值地图'**
  String get message_analytics_valueTrend;

  /// No description provided for @message_analytics_valueTrendDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'蓝线代表估算净值，下方渐变面积代表历史价值沉淀，点击查看明细'**
  String get message_analytics_valueTrendDesc;

  /// No description provided for @message_analytics_dailyCostTrend.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日耗成本趋势'**
  String get message_analytics_dailyCostTrend;

  /// No description provided for @message_analytics_dailyCostTrendDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录平均日耗随时间被摊薄的变化，点击查看每个节点'**
  String get message_analytics_dailyCostTrendDesc;

  /// No description provided for @message_analytics_assetCheckup.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产体检'**
  String get message_analytics_assetCheckup;

  /// No description provided for @message_analytics_netCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'净成本合计'**
  String get message_analytics_netCost;

  /// No description provided for @message_analytics_valueRecovered.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收'**
  String get message_analytics_valueRecovered;

  /// No description provided for @message_analytics_categoryValuation.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类估值占比'**
  String get message_analytics_categoryValuation;

  /// No description provided for @message_analytics_categoryValuationDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按照分类汇总当前资产价值，点击查看分类明细'**
  String get message_analytics_categoryValuationDesc;

  /// No description provided for @message_analytics_noData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无数据'**
  String get message_analytics_noData;

  /// No description provided for @message_analytics_tagDistribution.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签分布'**
  String get message_analytics_tagDistribution;

  /// No description provided for @message_analytics_tagDistributionDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签更适合描述资产场景，点击查看标签明细'**
  String get message_analytics_tagDistributionDesc;

  /// No description provided for @message_analytics_noTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无标签'**
  String get message_analytics_noTags;

  /// No description provided for @message_analytics_dailyCostRanking.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本排行'**
  String get message_analytics_dailyCostRanking;

  /// No description provided for @message_analytics_noDailyCostAssets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无可计算日均成本的资产'**
  String get message_analytics_noDailyCostAssets;

  /// No description provided for @message_analytics_serviceDuration.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役时长分布'**
  String get message_analytics_serviceDuration;

  /// No description provided for @message_analytics_serviceDurationDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'观察哪些资产已经陪伴你很久，点击查看服役排行'**
  String get message_analytics_serviceDurationDesc;

  /// No description provided for @message_analytics_coreMetricsDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'核心指标明细'**
  String get message_analytics_coreMetricsDetail;

  /// No description provided for @message_analytics_coreMetricsDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里把首页看板之外的计算口径展开'**
  String get message_analytics_coreMetricsDetailDesc;

  /// No description provided for @message_analytics_assetCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产数量'**
  String get message_analytics_assetCount;

  /// No description provided for @message_analytics_statusBreakdown.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役 / 退役 / 卖出'**
  String get message_analytics_statusBreakdown;

  /// No description provided for @message_analytics_summaryNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'说明：总资产按当前估值与是否计入总资产计算；日均成本按仍计入日均的资产净消耗除以服役天数估算'**
  String get message_analytics_summaryNote;

  /// No description provided for @message_analytics_valueTrendDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期价值地图明细'**
  String get message_analytics_valueTrendDetail;

  /// No description provided for @message_analytics_valueTrendDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'每个节点代表一段时间内资产净值的估算'**
  String get message_analytics_valueTrendDetailDesc;

  /// No description provided for @message_analytics_dailyCostTrendDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日耗成本趋势记录'**
  String get message_analytics_dailyCostTrendDetail;

  /// No description provided for @message_analytics_dailyCostTrendDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'每个节点是当时可计算资产的平均日耗'**
  String get message_analytics_dailyCostTrendDetailDesc;

  /// No description provided for @message_analytics_noTrendData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无趋势数据'**
  String get message_analytics_noTrendData;

  /// No description provided for @message_analytics_categoryDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类估值明细'**
  String get message_analytics_categoryDetail;

  /// No description provided for @message_analytics_categoryDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用于判断钱主要压在哪类资产里'**
  String get message_analytics_categoryDetailDesc;

  /// No description provided for @message_analytics_noCategoryData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无分类数据'**
  String get message_analytics_noCategoryData;

  /// No description provided for @message_analytics_tagDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签明细'**
  String get message_analytics_tagDetail;

  /// No description provided for @message_analytics_tagDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签更适合描述使用场景、购买原因和复盘角度'**
  String get message_analytics_tagDetailDesc;

  /// No description provided for @message_analytics_serviceDurationRanking.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役时长排行'**
  String get message_analytics_serviceDurationRanking;

  /// No description provided for @message_analytics_serviceDurationRankingDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合找出真正长期陪伴你的资产'**
  String get message_analytics_serviceDurationRankingDesc;

  /// No description provided for @message_analytics_noAssets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无资产'**
  String get message_analytics_noAssets;

  /// No description provided for @message_analytics_dailyCostDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本排行明细'**
  String get message_analytics_dailyCostDetail;

  /// No description provided for @message_analytics_dailyCostDetailDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击任一资产进入详情页，查看购买价、服役天数、目标日均等'**
  String get message_analytics_dailyCostDetailDesc;

  /// No description provided for @message_analytics_purchased.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购入'**
  String get message_analytics_purchased;

  /// No description provided for @message_analytics_held.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有'**
  String get message_analytics_held;

  /// No description provided for @message_analytics_timeMachine.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产时光机'**
  String get message_analytics_timeMachine;

  /// No description provided for @message_analytics_timeMachineDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'最近的买入、退役、卖出都会在这里形成复盘线索'**
  String get message_analytics_timeMachineDesc;

  /// No description provided for @message_analytics_noEvents.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无事件'**
  String get message_analytics_noEvents;

  /// No description provided for @message_archive_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱完整资料包'**
  String get message_archive_title;

  /// No description provided for @message_archive_generated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成完整资料包：包含数据库、JSON、CSV 和报告'**
  String get message_archive_generated;

  /// No description provided for @message_archive_generatedWithMedia.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成完整资料包：包含数据库、JSON、CSV、报告和 {n} 个媒体文件'**
  String message_archive_generatedWithMedia({required Object n});

  /// No description provided for @message_auto_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提醒、通知与快捷方式'**
  String get message_auto_title;

  /// No description provided for @message_auto_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用 Android 通知、定时提醒和快捷方式增加系统级入口'**
  String get message_auto_subtitle;

  /// No description provided for @message_auto_notifTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱资产体检'**
  String get message_auto_notifTitle;

  /// No description provided for @message_auto_notifBody.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到时间复盘一下高日耗、临期和闲置资产了'**
  String get message_auto_notifBody;

  /// No description provided for @message_auto_testScheduled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已安排 1 分钟后的测试提醒'**
  String get message_auto_testScheduled;

  /// No description provided for @message_auto_testFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提醒安排失败'**
  String get message_auto_testFailed;

  /// No description provided for @message_auto_testReminder.
  ///
  /// In zh_Hans, this message translates to:
  /// **'1 分钟后测试提醒'**
  String get message_auto_testReminder;

  /// No description provided for @message_auto_shortcutCreated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已创建桌面长按快捷入口'**
  String get message_auto_shortcutCreated;

  /// No description provided for @message_auto_shortcutFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前系统不支持动态快捷方式'**
  String get message_auto_shortcutFailed;

  /// No description provided for @message_auto_createShortcut.
  ///
  /// In zh_Hans, this message translates to:
  /// **'创建长按快捷入口'**
  String get message_auto_createShortcut;

  /// No description provided for @message_auto_permRequested.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已请求通知权限'**
  String get message_auto_permRequested;

  /// No description provided for @message_auto_permNotNeeded.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前系统无需运行时通知权限'**
  String get message_auto_permNotNeeded;

  /// No description provided for @message_auto_requestPerm.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请求通知权限'**
  String get message_auto_requestPerm;

  /// No description provided for @message_auto_openNotifSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开通知设置'**
  String get message_auto_openNotifSettings;

  /// No description provided for @message_notification_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱到期提醒'**
  String get message_notification_title;

  /// No description provided for @message_notification_assetExpiry.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产「{name}」将在 {date} 到期，请提前检查'**
  String message_notification_assetExpiry(
      {required Object date, required Object name});

  /// No description provided for @message_notification_assetTarget.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产「{name}」的目标日期是 {date}'**
  String message_notification_assetTarget(
      {required Object date, required Object name});

  /// No description provided for @message_notification_statusScheduled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已安排 {n} 条提醒'**
  String message_notification_statusScheduled({required Object n});

  /// No description provided for @message_notification_statusPermissionDenied.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通知权限被拒绝，请在系统设置中允许通知'**
  String get message_notification_statusPermissionDenied;

  /// No description provided for @message_notification_statusDisabled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期提醒已关闭'**
  String get message_notification_statusDisabled;

  /// No description provided for @message_notification_statusPending.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在同步到期提醒'**
  String get message_notification_statusPending;

  /// No description provided for @message_notification_statusFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期提醒同步失败'**
  String get message_notification_statusFailed;

  /// No description provided for @message_clipboard_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'剪贴板读入'**
  String get message_clipboard_title;

  /// No description provided for @message_clipboard_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可以从剪贴板恢复值谱 JSON，或把普通文本作为资产名称草稿'**
  String get message_clipboard_subtitle;

  /// No description provided for @message_clipboard_empty.
  ///
  /// In zh_Hans, this message translates to:
  /// **'剪贴板为空'**
  String get message_clipboard_empty;

  /// No description provided for @message_clipboard_read.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取剪贴板'**
  String get message_clipboard_read;

  /// No description provided for @message_clipboard_copied.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已写入当前 JSON 到剪贴板'**
  String get message_clipboard_copied;

  /// No description provided for @message_clipboard_copyJson.
  ///
  /// In zh_Hans, this message translates to:
  /// **'复制当前 JSON'**
  String get message_clipboard_copyJson;

  /// No description provided for @message_common_pickDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择日期'**
  String get message_common_pickDate;

  /// No description provided for @message_common_noDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不计日均'**
  String get message_common_noDailyCost;

  /// No description provided for @message_common_scoreSuffix.
  ///
  /// In zh_Hans, this message translates to:
  /// **' 分'**
  String get message_common_scoreSuffix;

  /// No description provided for @message_common_exportCancelled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出已取消或失败'**
  String get message_common_exportCancelled;

  /// No description provided for @message_common_exportedToFile.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已导出到系统文件'**
  String get message_common_exportedToFile;

  /// No description provided for @message_common_csvExported.
  ///
  /// In zh_Hans, this message translates to:
  /// **'CSV 已导出'**
  String get message_common_csvExported;

  /// No description provided for @message_compose_pickCover.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选封面'**
  String get message_compose_pickCover;

  /// No description provided for @message_compose_frameCrop.
  ///
  /// In zh_Hans, this message translates to:
  /// **'裁切白框'**
  String get message_compose_frameCrop;

  /// No description provided for @message_compose_manualTrace.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手动勾勒'**
  String get message_compose_manualTrace;

  /// No description provided for @message_compose_aiSticker.
  ///
  /// In zh_Hans, this message translates to:
  /// **'AI 贴纸'**
  String get message_compose_aiSticker;

  /// No description provided for @message_compose_scanBarcode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'扫条码'**
  String get message_compose_scanBarcode;

  /// No description provided for @message_compose_receiptOcr.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小票 OCR'**
  String get message_compose_receiptOcr;

  /// No description provided for @message_compose_asset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产'**
  String get message_compose_asset;

  /// No description provided for @message_compose_wish.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿'**
  String get message_compose_wish;

  /// No description provided for @message_compose_nameRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请先填写名称'**
  String get message_compose_nameRequired;

  /// No description provided for @message_compose_assetNameHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如：iPad Pro、相机、键盘'**
  String get message_compose_assetNameHint;

  /// No description provided for @message_compose_wishNameHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如：下一台相机、显示器、旅行装备'**
  String get message_compose_wishNameHint;

  /// No description provided for @message_compose_valueMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值类型'**
  String get message_compose_valueMode;

  /// No description provided for @message_compose_value.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值'**
  String get message_compose_value;

  /// No description provided for @message_compose_price.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格'**
  String get message_compose_price;

  /// No description provided for @message_compose_expectedPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'预计价格'**
  String get message_compose_expectedPrice;

  /// No description provided for @message_compose_required.
  ///
  /// In zh_Hans, this message translates to:
  /// **'必填'**
  String get message_compose_required;

  /// No description provided for @message_compose_recordDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期'**
  String get message_compose_recordDate;

  /// No description provided for @message_compose_purchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期'**
  String get message_compose_purchaseDate;

  /// No description provided for @message_compose_category.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类'**
  String get message_compose_category;

  /// No description provided for @message_compose_tags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签'**
  String get message_compose_tags;

  /// No description provided for @message_compose_recordGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录目标'**
  String get message_compose_recordGoal;

  /// No description provided for @message_compose_dailyCostGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均目标'**
  String get message_compose_dailyCostGoal;

  /// No description provided for @message_compose_addons.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品'**
  String get message_compose_addons;

  /// No description provided for @message_compose_addonPurchaseTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买时间'**
  String get message_compose_addonPurchaseTime;

  /// No description provided for @message_compose_addItem.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加一项'**
  String get message_compose_addItem;

  /// No description provided for @message_compose_note.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备注'**
  String get message_compose_note;

  /// No description provided for @message_compose_noteHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'输入备注，最多 200 字'**
  String get message_compose_noteHint;

  /// No description provided for @message_compose_pricelessHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝不会计入总资产或日均成本，更适合纪念物、收藏和不可量化的物品'**
  String get message_compose_pricelessHint;

  /// No description provided for @message_compose_excludeFromTotal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不计入总资产'**
  String get message_compose_excludeFromTotal;

  /// No description provided for @message_compose_excludeFromDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不计入日均成本'**
  String get message_compose_excludeFromDaily;

  /// No description provided for @message_compose_sold.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已卖出'**
  String get message_compose_sold;

  /// No description provided for @message_compose_paused.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已停用'**
  String get message_compose_paused;

  /// No description provided for @message_compose_retired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已退役'**
  String get message_compose_retired;

  /// No description provided for @message_compose_expiryTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期时间'**
  String get message_compose_expiryTime;

  /// No description provided for @message_compose_expiryReminder.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期提醒'**
  String get message_compose_expiryReminder;

  /// No description provided for @message_compose_noGoalHintPriceless.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝可以设置记录目标，帮助你回顾它陪伴了多久'**
  String get message_compose_noGoalHintPriceless;

  /// No description provided for @message_compose_noGoalHintNormal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置目标日均或目标日期，值谱会估算达成进度'**
  String get message_compose_noGoalHintNormal;

  /// No description provided for @message_compose_pricelessNoDailyGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝不支持日均目标'**
  String get message_compose_pricelessNoDailyGoal;

  /// No description provided for @message_compose_targetDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标日耗 / 天'**
  String get message_compose_targetDailyCost;

  /// No description provided for @message_compose_targetDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标达成日期'**
  String get message_compose_targetDate;

  /// No description provided for @message_compose_targetDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标使用天数'**
  String get message_compose_targetDays;

  /// No description provided for @message_compose_coverSet.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已设置真实封面'**
  String get message_compose_coverSet;

  /// No description provided for @message_compose_framedCoverGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成白框裁切封面'**
  String get message_compose_framedCoverGenerated;

  /// No description provided for @message_compose_traceCoverGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成手动勾勒贴纸'**
  String get message_compose_traceCoverGenerated;

  /// No description provided for @message_compose_noStickerGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有生成可用的贴纸封面'**
  String get message_compose_noStickerGenerated;

  /// No description provided for @message_compose_cutoutSelectedFromN.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从 {n} 个候选中选择贴纸'**
  String message_compose_cutoutSelectedFromN({required Object n});

  /// No description provided for @message_compose_aiStickerGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'AI 贴纸已生成'**
  String get message_compose_aiStickerGenerated;

  /// No description provided for @message_compose_barcodeNotFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未识别到条码或二维码'**
  String get message_compose_barcodeNotFound;

  /// No description provided for @message_compose_tagScan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'扫码'**
  String get message_compose_tagScan;

  /// No description provided for @message_compose_barcodeNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'条码/二维码：{value}'**
  String message_compose_barcodeNote({required Object value});

  /// No description provided for @message_compose_barcodeWritten.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已把扫码结果写入资产草稿'**
  String get message_compose_barcodeWritten;

  /// No description provided for @message_compose_ocrNoText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有识别到清晰文字'**
  String get message_compose_ocrNoText;

  /// No description provided for @message_compose_tagReceiptOcr.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小票 OCR'**
  String get message_compose_tagReceiptOcr;

  /// No description provided for @message_compose_ocrNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小票识别内容'**
  String get message_compose_ocrNote;

  /// No description provided for @message_compose_ocrWrittenToNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'OCR 已写入备注'**
  String get message_compose_ocrWrittenToNote;

  /// No description provided for @message_compose_ocrFilledPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'OCR 已回填价格：{price}'**
  String message_compose_ocrFilledPrice({required Object price});

  /// No description provided for @message_compose_valueModeSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择这件物品是否需要进入金额统计'**
  String get message_compose_valueModeSubtitle;

  /// No description provided for @message_compose_valueModePricelessDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合纪念品、礼物、收藏和无法用价格衡量的物品'**
  String get message_compose_valueModePricelessDesc;

  /// No description provided for @message_compose_valueModePricedDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合会参与总资产、日均成本和价值回收计算的物品'**
  String get message_compose_valueModePricedDesc;

  /// No description provided for @message_compose_selectCategory.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择分类'**
  String get message_compose_selectCategory;

  /// No description provided for @message_compose_selectCategorySubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择已有分类，或让值谱按名称建议一个新分类'**
  String get message_compose_selectCategorySubtitle;

  /// No description provided for @message_compose_smartNewCategory.
  ///
  /// In zh_Hans, this message translates to:
  /// **'智能新增分类'**
  String get message_compose_smartNewCategory;

  /// No description provided for @message_compose_smartNewCategoryHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'根据名称自动推断图标、颜色和大类'**
  String get message_compose_smartNewCategoryHint;

  /// No description provided for @message_compose_tagsSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击即可选择或取消，也可以新增标签并自动加入'**
  String get message_compose_tagsSubtitle;

  /// No description provided for @message_compose_tagsHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如：生产力、通勤、吃灰'**
  String get message_compose_tagsHint;

  /// No description provided for @message_compose_commonTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'常用标签'**
  String get message_compose_commonTags;

  /// No description provided for @message_compose_existingTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有标签'**
  String get message_compose_existingTags;

  /// No description provided for @message_compose_newTag.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增标签'**
  String get message_compose_newTag;

  /// No description provided for @message_compose_addAddonTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加附加物品'**
  String get message_compose_addAddonTitle;

  /// No description provided for @message_compose_addAddonSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'比如保护壳、收纳包、维修费等'**
  String get message_compose_addAddonSubtitle;

  /// No description provided for @message_compose_addonName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'名称'**
  String get message_compose_addonName;

  /// No description provided for @message_compose_addonPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格'**
  String get message_compose_addonPrice;

  /// No description provided for @message_compose_addonDateInvalid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品购买时间格式不正确'**
  String get message_compose_addonDateInvalid;

  /// No description provided for @message_compose_addonDefaultName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品'**
  String get message_compose_addonDefaultName;

  /// No description provided for @message_compose_recordDateInvalid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期格式不正确'**
  String get message_compose_recordDateInvalid;

  /// No description provided for @message_compose_purchaseDateInvalid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期格式不正确'**
  String get message_compose_purchaseDateInvalid;

  /// No description provided for @message_compose_targetDailyCostRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标日耗需要大于 0'**
  String get message_compose_targetDailyCostRequired;

  /// No description provided for @message_compose_targetDateRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请为“按日期”选择目标达成日期'**
  String get message_compose_targetDateRequired;

  /// No description provided for @message_compose_targetCustomDaysRequired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请为“自定义”填写大于 0 的目标天数'**
  String get message_compose_targetCustomDaysRequired;

  /// No description provided for @message_compose_targetModeNone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不设目标'**
  String get message_compose_targetModeNone;

  /// No description provided for @message_compose_targetModeDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按日耗'**
  String get message_compose_targetModeDaily;

  /// No description provided for @message_compose_targetModeDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按日期'**
  String get message_compose_targetModeDate;

  /// No description provided for @message_compose_targetModeCustom.
  ///
  /// In zh_Hans, this message translates to:
  /// **'自定义天数'**
  String get message_compose_targetModeCustom;

  /// No description provided for @message_compose_selectExistingTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择已有标签'**
  String get message_compose_selectExistingTags;

  /// No description provided for @message_csv_name.
  ///
  /// In zh_Hans, this message translates to:
  /// **'名称'**
  String get message_csv_name;

  /// No description provided for @message_csv_category.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类'**
  String get message_csv_category;

  /// No description provided for @message_csv_price.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格'**
  String get message_csv_price;

  /// No description provided for @message_csv_currentValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前价值'**
  String get message_csv_currentValue;

  /// No description provided for @message_csv_date.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日期'**
  String get message_csv_date;

  /// No description provided for @message_csv_status.
  ///
  /// In zh_Hans, this message translates to:
  /// **'状态'**
  String get message_csv_status;

  /// No description provided for @message_csv_dailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本'**
  String get message_csv_dailyCost;

  /// No description provided for @message_csv_tags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签'**
  String get message_csv_tags;

  /// No description provided for @message_csv_note.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备注'**
  String get message_csv_note;

  /// No description provided for @message_date_selectOrEnter.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请选择或输入日期'**
  String get message_date_selectOrEnter;

  /// No description provided for @message_date_enterValid.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入有效日期'**
  String get message_date_enterValid;

  /// No description provided for @message_date_clear.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清除日期'**
  String get message_date_clear;

  /// No description provided for @message_date_openPicker.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开日期选择器'**
  String get message_date_openPicker;

  /// No description provided for @message_date_today.
  ///
  /// In zh_Hans, this message translates to:
  /// **'今天'**
  String get message_date_today;

  /// No description provided for @message_date_weekday1Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'一'**
  String get message_date_weekday1Short;

  /// No description provided for @message_date_weekday2Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二'**
  String get message_date_weekday2Short;

  /// No description provided for @message_date_weekday3Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'三'**
  String get message_date_weekday3Short;

  /// No description provided for @message_date_weekday4Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'四'**
  String get message_date_weekday4Short;

  /// No description provided for @message_date_weekday5Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'五'**
  String get message_date_weekday5Short;

  /// No description provided for @message_date_weekday6Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'六'**
  String get message_date_weekday6Short;

  /// No description provided for @message_date_weekday7Short.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日'**
  String get message_date_weekday7Short;

  /// No description provided for @message_date_wheelHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'滑动选择年份和月份，完成后会替换当前日历月份'**
  String get message_date_wheelHint;

  /// No description provided for @message_date_backToCalendar.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回到日历选择'**
  String get message_date_backToCalendar;

  /// No description provided for @message_date_tapToSwitchYearMonth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点此切换年月滚轮'**
  String get message_date_tapToSwitchYearMonth;

  /// No description provided for @message_date_prevMonth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上个月'**
  String get message_date_prevMonth;

  /// No description provided for @message_date_nextMonth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'下个月'**
  String get message_date_nextMonth;

  /// No description provided for @message_date_monday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周一'**
  String get message_date_monday;

  /// No description provided for @message_date_tuesday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周二'**
  String get message_date_tuesday;

  /// No description provided for @message_date_wednesday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周三'**
  String get message_date_wednesday;

  /// No description provided for @message_date_thursday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周四'**
  String get message_date_thursday;

  /// No description provided for @message_date_friday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周五'**
  String get message_date_friday;

  /// No description provided for @message_date_saturday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周六'**
  String get message_date_saturday;

  /// No description provided for @message_date_sunday.
  ///
  /// In zh_Hans, this message translates to:
  /// **'周日'**
  String get message_date_sunday;

  /// No description provided for @message_detail_assetNotFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产不存在'**
  String get message_detail_assetNotFound;

  /// No description provided for @message_detail_recordTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录时间'**
  String get message_detail_recordTime;

  /// No description provided for @message_detail_holdingTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有时间'**
  String get message_detail_holdingTime;

  /// No description provided for @message_detail_dailyCostTrend.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本趋势'**
  String get message_detail_dailyCostTrend;

  /// No description provided for @message_detail_dailyCostTrendDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'实线是已发生摊薄，虚线按日耗目标预测未来走势，横向虚线是目标日耗'**
  String get message_detail_dailyCostTrendDesc;

  /// No description provided for @message_detail_recordGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录目标'**
  String get message_detail_recordGoal;

  /// No description provided for @message_detail_dailyCostGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均目标'**
  String get message_detail_dailyCostGoal;

  /// No description provided for @message_detail_sinceLast.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已记录'**
  String get message_detail_sinceLast;

  /// No description provided for @message_detail_perDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'/天'**
  String get message_detail_perDay;

  /// No description provided for @message_detail_noRecordGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无记录目标'**
  String get message_detail_noRecordGoal;

  /// No description provided for @message_detail_noDailyCostGoal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无日均目标'**
  String get message_detail_noDailyCostGoal;

  /// No description provided for @message_detail_recordGoalUseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可设置目标日期或目标天数'**
  String get message_detail_recordGoalUseDate;

  /// No description provided for @message_detail_target.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标'**
  String get message_detail_target;

  /// No description provided for @message_detail_targetMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标模式'**
  String get message_detail_targetMode;

  /// No description provided for @message_detail_currentInterval.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前区间'**
  String get message_detail_currentInterval;

  /// No description provided for @message_detail_currentDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前日均'**
  String get message_detail_currentDailyCost;

  /// No description provided for @message_detail_targetDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标天数'**
  String get message_detail_targetDays;

  /// No description provided for @message_detail_estimatedTarget.
  ///
  /// In zh_Hans, this message translates to:
  /// **'预计达成'**
  String get message_detail_estimatedTarget;

  /// No description provided for @message_detail_remainingDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'剩余天数'**
  String get message_detail_remainingDays;

  /// No description provided for @message_detail_assetRecords.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产记录'**
  String get message_detail_assetRecords;

  /// No description provided for @message_detail_recordDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期'**
  String get message_detail_recordDate;

  /// No description provided for @message_detail_valueMark.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值标记'**
  String get message_detail_valueMark;

  /// No description provided for @message_detail_statBasis.
  ///
  /// In zh_Hans, this message translates to:
  /// **'统计口径'**
  String get message_detail_statBasis;

  /// No description provided for @message_detail_noAmountOrCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有金额或成本记录'**
  String get message_detail_noAmountOrCost;

  /// No description provided for @message_detail_purchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期'**
  String get message_detail_purchaseDate;

  /// No description provided for @message_detail_assetBody.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产主体'**
  String get message_detail_assetBody;

  /// No description provided for @message_detail_addonIncluded.
  ///
  /// In zh_Hans, this message translates to:
  /// **'包含附加物品'**
  String get message_detail_addonIncluded;

  /// No description provided for @message_detail_soldPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出价'**
  String get message_detail_soldPrice;

  /// No description provided for @message_detail_netCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'净成本'**
  String get message_detail_netCost;

  /// No description provided for @message_editor_editAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑资产'**
  String get message_editor_editAsset;

  /// No description provided for @message_editor_newAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增资产'**
  String get message_editor_newAsset;

  /// No description provided for @message_editor_assetName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产名称'**
  String get message_editor_assetName;

  /// No description provided for @message_editor_category.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类'**
  String get message_editor_category;

  /// No description provided for @message_editor_uncategorized.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未分类'**
  String get message_editor_uncategorized;

  /// No description provided for @message_editor_smartNewCategory.
  ///
  /// In zh_Hans, this message translates to:
  /// **'智能新增分类'**
  String get message_editor_smartNewCategory;

  /// No description provided for @message_editor_valueMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值类型'**
  String get message_editor_valueMode;

  /// No description provided for @message_editor_value.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值'**
  String get message_editor_value;

  /// No description provided for @message_editor_buyPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买价'**
  String get message_editor_buyPrice;

  /// No description provided for @message_editor_recordDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期'**
  String get message_editor_recordDate;

  /// No description provided for @message_editor_purchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期'**
  String get message_editor_purchaseDate;

  /// No description provided for @message_editor_status.
  ///
  /// In zh_Hans, this message translates to:
  /// **'状态'**
  String get message_editor_status;

  /// No description provided for @message_editor_retiredDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役日期'**
  String get message_editor_retiredDate;

  /// No description provided for @message_editor_soldDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出日期'**
  String get message_editor_soldDate;

  /// No description provided for @message_editor_soldPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出价'**
  String get message_editor_soldPrice;

  /// No description provided for @message_editor_tagsHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如：生产力、通勤、吃灰'**
  String get message_editor_tagsHint;

  /// No description provided for @message_editor_selectExistingTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择已有标签'**
  String get message_editor_selectExistingTags;

  /// No description provided for @message_editor_note.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备注'**
  String get message_editor_note;

  /// No description provided for @message_editor_targetsAndReminders.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标与提醒'**
  String get message_editor_targetsAndReminders;

  /// No description provided for @message_editor_targetMode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标模式'**
  String get message_editor_targetMode;

  /// No description provided for @message_editor_targetDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标日耗'**
  String get message_editor_targetDailyCost;

  /// No description provided for @message_editor_targetDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标日期'**
  String get message_editor_targetDate;

  /// No description provided for @message_editor_targetDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标天数'**
  String get message_editor_targetDays;

  /// No description provided for @message_editor_expiryDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期日期'**
  String get message_editor_expiryDate;

  /// No description provided for @message_editor_remindBeforeDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提前提醒天数'**
  String get message_editor_remindBeforeDays;

  /// No description provided for @message_editor_pricelessNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝不会进入金额统计，但可以保留时间、分类、标签和纪念记录'**
  String get message_editor_pricelessNote;

  /// No description provided for @message_editor_includeInTotal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'计入总资产'**
  String get message_editor_includeInTotal;

  /// No description provided for @message_editor_includeInDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'计入日均成本'**
  String get message_editor_includeInDailyCost;

  /// No description provided for @message_editor_addons.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品'**
  String get message_editor_addons;

  /// No description provided for @message_editor_addonHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把配件、维修费、保护壳等附加成本记在这里'**
  String get message_editor_addonHint;

  /// No description provided for @message_editor_addonPurchaseTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品购买时间'**
  String get message_editor_addonPurchaseTime;

  /// No description provided for @message_editor_saveChanges.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存修改'**
  String get message_editor_saveChanges;

  /// No description provided for @message_editor_addToAssets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加到资产清单'**
  String get message_editor_addToAssets;

  /// No description provided for @message_editor_coverSet.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已设置真实封面'**
  String get message_editor_coverSet;

  /// No description provided for @message_editor_framedCoverGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成白框裁切封面'**
  String get message_editor_framedCoverGenerated;

  /// No description provided for @message_editor_manualTraceGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已生成手动勾勒贴纸'**
  String get message_editor_manualTraceGenerated;

  /// No description provided for @message_editor_noStickerGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有生成可用的贴纸封面'**
  String get message_editor_noStickerGenerated;

  /// No description provided for @message_editor_stickerSelectedFrom.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从候选中选择'**
  String get message_editor_stickerSelectedFrom;

  /// No description provided for @message_editor_candidates.
  ///
  /// In zh_Hans, this message translates to:
  /// **'个候选'**
  String get message_editor_candidates;

  /// No description provided for @message_editor_aiStickerGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'AI 贴纸已生成'**
  String get message_editor_aiStickerGenerated;

  /// No description provided for @message_editor_barcodeNotFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未识别到条码或二维码'**
  String get message_editor_barcodeNotFound;

  /// No description provided for @message_editor_tagScanned.
  ///
  /// In zh_Hans, this message translates to:
  /// **'扫码'**
  String get message_editor_tagScanned;

  /// No description provided for @message_editor_barcodeLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'条码/二维码'**
  String get message_editor_barcodeLabel;

  /// No description provided for @message_editor_barcodeApplied.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已把扫码结果写入编辑器'**
  String get message_editor_barcodeApplied;

  /// No description provided for @message_editor_tagsTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签'**
  String get message_editor_tagsTitle;

  /// No description provided for @message_editor_tagsSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击即可选择或取消，也可以新增标签并自动加入'**
  String get message_editor_tagsSubtitle;

  /// No description provided for @message_editor_tagHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如：生产力、通勤、吃灰'**
  String get message_editor_tagHint;

  /// No description provided for @message_editor_presetTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'常用标签'**
  String get message_editor_presetTags;

  /// No description provided for @message_editor_existingTags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有标签'**
  String get message_editor_existingTags;

  /// No description provided for @message_editor_newTag.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增标签'**
  String get message_editor_newTag;

  /// No description provided for @message_editor_ocrNoText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有识别到清晰文字'**
  String get message_editor_ocrNoText;

  /// No description provided for @message_editor_tagReceiptOcr.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小票 OCR'**
  String get message_editor_tagReceiptOcr;

  /// No description provided for @message_editor_ocrLabel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小票识别内容'**
  String get message_editor_ocrLabel;

  /// No description provided for @message_editor_ocrWrittenToNote.
  ///
  /// In zh_Hans, this message translates to:
  /// **'OCR 已写入备注'**
  String get message_editor_ocrWrittenToNote;

  /// No description provided for @message_editor_ocrPriceFilled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'OCR 已回填价格'**
  String get message_editor_ocrPriceFilled;

  /// No description provided for @message_editor_addAddon.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加附加物品'**
  String get message_editor_addAddon;

  /// No description provided for @message_editor_editAddon.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑附加物品'**
  String get message_editor_editAddon;

  /// No description provided for @message_editor_addonName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'名称'**
  String get message_editor_addonName;

  /// No description provided for @message_editor_addonPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格'**
  String get message_editor_addonPrice;

  /// No description provided for @message_editor_followParentDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随主资产购买日期'**
  String get message_editor_followParentDate;

  /// No description provided for @message_editor_parentPurchaseTime.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主资产购买时间'**
  String get message_editor_parentPurchaseTime;

  /// No description provided for @message_editor_addonPurchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品购买日期'**
  String get message_editor_addonPurchaseDate;

  /// No description provided for @message_editor_invalidAddonDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品购买日期格式不正确'**
  String get message_editor_invalidAddonDate;

  /// No description provided for @message_editor_defaultAddonName.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加物品'**
  String get message_editor_defaultAddonName;

  /// No description provided for @message_editor_invalidRecordDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录日期格式不正确'**
  String get message_editor_invalidRecordDate;

  /// No description provided for @message_editor_invalidPurchaseDate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买日期格式不正确'**
  String get message_editor_invalidPurchaseDate;

  /// No description provided for @message_editor_dateBeforePurchase.
  ///
  /// In zh_Hans, this message translates to:
  /// **'状态或目标日期不能早于购买/记录日期'**
  String get message_editor_dateBeforePurchase;

  /// No description provided for @message_editor_unnamedAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未命名资产'**
  String get message_editor_unnamedAsset;

  /// No description provided for @message_home_durationDetail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有时长明细'**
  String get message_home_durationDetail;

  /// No description provided for @message_home_unifiedDisplay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'统一显示'**
  String get message_home_unifiedDisplay;

  /// No description provided for @message_home_yearMonthConversion.
  ///
  /// In zh_Hans, this message translates to:
  /// **'年/月换算'**
  String get message_home_yearMonthConversion;

  /// No description provided for @message_home_calcCutoff.
  ///
  /// In zh_Hans, this message translates to:
  /// **'计算截止'**
  String get message_home_calcCutoff;

  /// No description provided for @message_home_durationHintPriceless.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝按记录日期计算陪伴时长'**
  String get message_home_durationHintPriceless;

  /// No description provided for @message_home_durationHintNormal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'普通资产按购买日期计算使用时长'**
  String get message_home_durationHintNormal;

  /// No description provided for @message_home_sinceLast.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已记录'**
  String get message_home_sinceLast;

  /// No description provided for @message_home_usedFor.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已使用'**
  String get message_home_usedFor;

  /// No description provided for @message_home_emptyTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'空空如也'**
  String get message_home_emptyTitle;

  /// No description provided for @message_home_emptySubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从底部加号添加第一件资产'**
  String get message_home_emptySubtitle;

  /// No description provided for @message_home_addAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加资产'**
  String get message_home_addAsset;

  /// No description provided for @message_home_overviewTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产总览'**
  String get message_home_overviewTitle;

  /// No description provided for @message_home_totalAssets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'总资产'**
  String get message_home_totalAssets;

  /// No description provided for @message_home_avgDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本'**
  String get message_home_avgDailyCost;

  /// No description provided for @message_home_statusServing.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役中'**
  String get message_home_statusServing;

  /// No description provided for @message_home_statusRetired.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已退役'**
  String get message_home_statusRetired;

  /// No description provided for @message_home_statusSold.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已卖出'**
  String get message_home_statusSold;

  /// No description provided for @message_home_lifecycleLedger.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产生命周期账本'**
  String get message_home_lifecycleLedger;

  /// No description provided for @message_home_lifecycleLedgerDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把买入、服役、退役、卖出和回收放在同一条线上看'**
  String get message_home_lifecycleLedgerDesc;

  /// No description provided for @message_home_recordRecovery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录回收'**
  String get message_home_recordRecovery;

  /// No description provided for @message_home_totalInvested.
  ///
  /// In zh_Hans, this message translates to:
  /// **'累计投入'**
  String get message_home_totalInvested;

  /// No description provided for @message_home_currentNetValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前净值'**
  String get message_home_currentNetValue;

  /// No description provided for @message_home_valueRecovery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收'**
  String get message_home_valueRecovery;

  /// No description provided for @message_home_netConsumption.
  ///
  /// In zh_Hans, this message translates to:
  /// **'净消耗'**
  String get message_home_netConsumption;

  /// No description provided for @message_home_timeMachine.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产时光机'**
  String get message_home_timeMachine;

  /// No description provided for @message_home_timeMachineEmpty.
  ///
  /// In zh_Hans, this message translates to:
  /// **'创建快照后，这里会显示最近一次资产变化'**
  String get message_home_timeMachineEmpty;

  /// No description provided for @message_home_timeMachineHasSnapshots.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有 {n} 份快照，最近一次：{label}'**
  String message_home_timeMachineHasSnapshots(
      {required Object label, required Object n});

  /// No description provided for @message_home_walletLeakTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钱包漏洞雷达'**
  String get message_home_walletLeakTitle;

  /// No description provided for @message_home_walletLeakDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'优先关注超出预算、临近到期或长期闲置的资产'**
  String get message_home_walletLeakDesc;

  /// No description provided for @message_home_perDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'/天'**
  String get message_home_perDay;

  /// No description provided for @message_home_pricelessTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝'**
  String get message_home_pricelessTitle;

  /// No description provided for @message_home_pricelessDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不计入金额，但值得被认真记录的纪念物和收藏'**
  String get message_home_pricelessDesc;

  /// No description provided for @message_home_dueSoonTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'即将到期'**
  String get message_home_dueSoonTitle;

  /// No description provided for @message_home_dueSoonDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保修、会员、耗材或周期性服务即将到期时会出现在这里'**
  String get message_home_dueSoonDesc;

  /// No description provided for @message_home_expiresIn.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{n} 天后到期'**
  String message_home_expiresIn({required Object n});

  /// No description provided for @message_home_searchTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'搜索资产'**
  String get message_home_searchTitle;

  /// No description provided for @message_home_searchSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按名称、标签、分类或备注快速定位资产'**
  String get message_home_searchSubtitle;

  /// No description provided for @message_home_searchHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'搜索资产、标签或备注'**
  String get message_home_searchHint;

  /// No description provided for @message_home_clearSearch.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清除搜索'**
  String get message_home_clearSearch;

  /// No description provided for @message_home_filterTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'筛选'**
  String get message_home_filterTitle;

  /// No description provided for @message_home_filterSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'只看你当前最关心的那一部分资产'**
  String get message_home_filterSubtitle;

  /// No description provided for @message_home_filterTaggedOnly.
  ///
  /// In zh_Hans, this message translates to:
  /// **'仅看有标签'**
  String get message_home_filterTaggedOnly;

  /// No description provided for @message_home_filterTaggedOnlyDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'排除尚未添加标签的资产'**
  String get message_home_filterTaggedOnlyDesc;

  /// No description provided for @message_home_filterTargetedOnly.
  ///
  /// In zh_Hans, this message translates to:
  /// **'仅看有目标'**
  String get message_home_filterTargetedOnly;

  /// No description provided for @message_home_filterTargetedOnlyDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'只显示设置过日均或周期目标的资产'**
  String get message_home_filterTargetedOnlyDesc;

  /// No description provided for @message_home_resetFilters.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重置筛选'**
  String get message_home_resetFilters;

  /// No description provided for @message_home_sortAndDisplayStyle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'排序与视图'**
  String get message_home_sortAndDisplayStyle;

  /// No description provided for @message_home_sortAndDisplayDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'切换资产列表的默认排序方式和展示方式'**
  String get message_home_sortAndDisplayDesc;

  /// No description provided for @message_home_sort.
  ///
  /// In zh_Hans, this message translates to:
  /// **'排序'**
  String get message_home_sort;

  /// No description provided for @message_home_homeStyle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'首页风格'**
  String get message_home_homeStyle;

  /// No description provided for @message_iconPicker_fromGallery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从系统图库选择真实封面'**
  String get message_iconPicker_fromGallery;

  /// No description provided for @message_iconPicker_galleryHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'也可以继续选择字符图标。真实图片会复制到 App 私有目录，随资产一起保存'**
  String get message_iconPicker_galleryHint;

  /// No description provided for @message_iconPicker_album.
  ///
  /// In zh_Hans, this message translates to:
  /// **'相册'**
  String get message_iconPicker_album;

  /// No description provided for @message_iconPicker_threeDIcon.
  ///
  /// In zh_Hans, this message translates to:
  /// **'3D 图标'**
  String get message_iconPicker_threeDIcon;

  /// No description provided for @message_media_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'媒体与识别'**
  String get message_media_title;

  /// No description provided for @message_media_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择封面、拍照、生成贴纸，或用条码和 OCR 辅助录入'**
  String get message_media_subtitle;

  /// No description provided for @message_media_noImage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有选择图片'**
  String get message_media_noImage;

  /// No description provided for @message_media_savedCover.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已保存封面：'**
  String get message_media_savedCover;

  /// No description provided for @message_media_openGallery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开图库'**
  String get message_media_openGallery;

  /// No description provided for @message_media_photoCancelled.
  ///
  /// In zh_Hans, this message translates to:
  /// **'拍照已取消'**
  String get message_media_photoCancelled;

  /// No description provided for @message_media_photoSaved.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已保存照片：'**
  String get message_media_photoSaved;

  /// No description provided for @message_media_takePhoto.
  ///
  /// In zh_Hans, this message translates to:
  /// **'拍照'**
  String get message_media_takePhoto;

  /// No description provided for @message_media_noSticker.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有生成贴纸'**
  String get message_media_noSticker;

  /// No description provided for @message_media_stickerSelected.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已选择贴纸：'**
  String get message_media_stickerSelected;

  /// No description provided for @message_media_testSticker.
  ///
  /// In zh_Hans, this message translates to:
  /// **'测试贴纸'**
  String get message_media_testSticker;

  /// No description provided for @message_media_barcodeFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'识别到条码：'**
  String get message_media_barcodeFound;

  /// No description provided for @message_media_barcodeNotFound.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未识别到条码'**
  String get message_media_barcodeNotFound;

  /// No description provided for @message_media_scanBarcode.
  ///
  /// In zh_Hans, this message translates to:
  /// **'扫描条码'**
  String get message_media_scanBarcode;

  /// No description provided for @message_media_ocrNoPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有识别到价格'**
  String get message_media_ocrNoPrice;

  /// No description provided for @message_media_ocrPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'识别到价格：'**
  String get message_media_ocrPrice;

  /// No description provided for @message_media_ocrReceipt.
  ///
  /// In zh_Hans, this message translates to:
  /// **'识别小票'**
  String get message_media_ocrReceipt;

  /// No description provided for @message_media_ocrHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可以从小票或包装文字中提取名称、价格和备注线索'**
  String get message_media_ocrHint;

  /// No description provided for @message_native_capabilities.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 原生能力'**
  String get message_native_capabilities;

  /// No description provided for @message_native_hapticTest.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生触感测试'**
  String get message_native_hapticTest;

  /// No description provided for @message_native_hapticTestDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调用系统振动效果，检查轻点、确认和警示反馈'**
  String get message_native_hapticTestDesc;

  /// No description provided for @message_native_hapticTriggered.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已触发触感测试'**
  String get message_native_hapticTriggered;

  /// No description provided for @message_native_mediaAccess.
  ///
  /// In zh_Hans, this message translates to:
  /// **'图库 / 拍照接口'**
  String get message_native_mediaAccess;

  /// No description provided for @message_native_mediaAccessDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调用 Android Photo Picker 与系统相机 Intent'**
  String get message_native_mediaAccessDesc;

  /// No description provided for @message_native_notifications.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提醒、通知与快捷方式'**
  String get message_native_notifications;

  /// No description provided for @message_native_notificationsDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'测试通知、通知设置和桌面长按快捷入口'**
  String get message_native_notificationsDesc;

  /// No description provided for @message_native_widgetRefresh.
  ///
  /// In zh_Hans, this message translates to:
  /// **'刷新桌面小组件'**
  String get message_native_widgetRefresh;

  /// No description provided for @message_native_widgetRefreshDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把最新资产、心愿和快照数据推送到桌面小组件'**
  String get message_native_widgetRefreshDesc;

  /// No description provided for @message_native_widgetRefreshed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'桌面小组件已刷新'**
  String get message_native_widgetRefreshed;

  /// No description provided for @message_native_clipboard.
  ///
  /// In zh_Hans, this message translates to:
  /// **'剪贴板读入'**
  String get message_native_clipboard;

  /// No description provided for @message_native_clipboardDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取系统剪贴板，支持识别 JSON 或普通文本草稿'**
  String get message_native_clipboardDesc;

  /// No description provided for @message_native_clipboardPill.
  ///
  /// In zh_Hans, this message translates to:
  /// **'剪贴板'**
  String get message_native_clipboardPill;

  /// No description provided for @message_native_share.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统分享'**
  String get message_native_share;

  /// No description provided for @message_native_shareDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通过 Android 分享面板发送资产摘要或报告'**
  String get message_native_shareDesc;

  /// No description provided for @message_native_backup.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原生备份与报告'**
  String get message_native_backup;

  /// No description provided for @message_native_exportJson.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出 JSON 到系统文件'**
  String get message_native_exportJson;

  /// No description provided for @message_native_exportJsonDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用 Android 存储访问框架选择保存位置'**
  String get message_native_exportJsonDesc;

  /// No description provided for @message_native_restoreZip.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从 ZIP 资料包恢复'**
  String get message_native_restoreZip;

  /// No description provided for @message_native_restoreZipDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复完整数据和媒体文件'**
  String get message_native_restoreZipDesc;

  /// No description provided for @message_native_restoreJson.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从系统文件恢复 JSON'**
  String get message_native_restoreJson;

  /// No description provided for @message_native_restoreJsonDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'只恢复结构化数据，不包含封面或贴纸图片'**
  String get message_native_restoreJsonDesc;

  /// No description provided for @message_native_exportCsv.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出 CSV 资产表'**
  String get message_native_exportCsv;

  /// No description provided for @message_native_exportCsvDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'方便在 Excel、WPS 或 Numbers 中继续整理'**
  String get message_native_exportCsvDesc;

  /// No description provided for @message_native_exportMd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出 Markdown 报告'**
  String get message_native_exportMd;

  /// No description provided for @message_native_exportMdDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成可分享的资产复盘报告'**
  String get message_native_exportMdDesc;

  /// No description provided for @message_report_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱资产报告'**
  String get message_report_title;

  /// No description provided for @message_report_generatedAt.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成时间'**
  String get message_report_generatedAt;

  /// No description provided for @message_report_assetCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产数量'**
  String get message_report_assetCount;

  /// No description provided for @message_report_wishCount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿数量'**
  String get message_report_wishCount;

  /// No description provided for @message_report_totalValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'总资产'**
  String get message_report_totalValue;

  /// No description provided for @message_report_avgDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'平均日耗'**
  String get message_report_avgDailyCost;

  /// No description provided for @message_report_assetList.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产清单'**
  String get message_report_assetList;

  /// No description provided for @message_report_noAssets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无资产'**
  String get message_report_noAssets;

  /// No description provided for @message_report_walletLeaks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钱包漏洞'**
  String get message_report_walletLeaks;

  /// No description provided for @message_report_noLeaks.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无明显漏洞'**
  String get message_report_noLeaks;

  /// No description provided for @message_report_exportTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出资产报告'**
  String get message_report_exportTitle;

  /// No description provided for @message_report_exportSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存 Markdown 文件，或直接通过系统分享面板发送'**
  String get message_report_exportSubtitle;

  /// No description provided for @message_report_exported.
  ///
  /// In zh_Hans, this message translates to:
  /// **'报告已导出'**
  String get message_report_exported;

  /// No description provided for @message_report_saveFile.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存为文件'**
  String get message_report_saveFile;

  /// No description provided for @message_report_shareTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享值谱报告'**
  String get message_report_shareTitle;

  /// No description provided for @message_report_shareVia.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统分享'**
  String get message_report_shareVia;

  /// No description provided for @message_restore_noData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有可恢复的数据'**
  String get message_restore_noData;

  /// No description provided for @message_restore_nativeSuccess.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从系统文件恢复'**
  String get message_restore_nativeSuccess;

  /// No description provided for @message_restore_invalidJson.
  ///
  /// In zh_Hans, this message translates to:
  /// **'JSON 格式不正确'**
  String get message_restore_invalidJson;

  /// No description provided for @message_restore_noZip.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有选择 ZIP 资料包'**
  String get message_restore_noZip;

  /// No description provided for @message_restore_zipReadFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取 ZIP 失败'**
  String get message_restore_zipReadFailed;

  /// No description provided for @message_restore_zipNoJson.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资料包中没有找到可用 JSON'**
  String get message_restore_zipNoJson;

  /// No description provided for @message_restore_confirmTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确认恢复资料包'**
  String get message_restore_confirmTitle;

  /// No description provided for @message_restore_confirmContent.
  ///
  /// In zh_Hans, this message translates to:
  /// **'将导入 {assets} 个资产、{wishes} 个心愿、{categories} 个分类、{tags} 个标签、{media} 个媒体文件、{entries} 条记录和 {sqlite} 个数据库文件。恢复前会自动创建快照'**
  String message_restore_confirmContent(
      {required Object assets,
      required Object categories,
      required Object entries,
      required Object media,
      required Object sqlite,
      required Object tags,
      required Object wishes});

  /// No description provided for @message_restore_confirm.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确认恢复'**
  String get message_restore_confirm;

  /// No description provided for @message_restore_autoSnapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复前快照'**
  String get message_restore_autoSnapshot;

  /// No description provided for @message_restore_zipSuccess.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已恢复 {a} 个资产和 {m} 个媒体文件'**
  String message_restore_zipSuccess({required Object a, required Object m});

  /// No description provided for @message_restore_zipJsonFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资料包 JSON 恢复失败'**
  String get message_restore_zipJsonFailed;

  /// No description provided for @message_review_healthTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产健康度'**
  String get message_review_healthTitle;

  /// No description provided for @message_review_healthSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从目标、标签、风险和流转记录衡量资产管理状态'**
  String get message_review_healthSubtitle;

  /// No description provided for @message_review_targetCoverage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标覆盖率'**
  String get message_review_targetCoverage;

  /// No description provided for @message_review_tagCoverage.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签覆盖率'**
  String get message_review_tagCoverage;

  /// No description provided for @message_review_pendingRisk.
  ///
  /// In zh_Hans, this message translates to:
  /// **'待处理风险'**
  String get message_review_pendingRisk;

  /// No description provided for @message_review_items.
  ///
  /// In zh_Hans, this message translates to:
  /// **'项'**
  String get message_review_items;

  /// No description provided for @message_review_completedFlow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已完成流转'**
  String get message_review_completedFlow;

  /// No description provided for @message_review_suggestionHigh.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产结构很稳，继续保持复盘节奏'**
  String get message_review_suggestionHigh;

  /// No description provided for @message_review_suggestionRisk.
  ///
  /// In zh_Hans, this message translates to:
  /// **'先处理高日耗或闲置资产，能最快改善健康度'**
  String get message_review_suggestionRisk;

  /// No description provided for @message_review_suggestionTarget.
  ///
  /// In zh_Hans, this message translates to:
  /// **'为高价值资产补上目标，后续判断会更清晰'**
  String get message_review_suggestionTarget;

  /// No description provided for @message_review_suggestionBase.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从标签和目标开始补齐，值谱会更懂你的资产'**
  String get message_review_suggestionBase;

  /// No description provided for @message_review_quadrantTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产象限'**
  String get message_review_quadrantTitle;

  /// No description provided for @message_review_quadrantSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按服役时长和日均成本识别长期价值与高耗资产'**
  String get message_review_quadrantSubtitle;

  /// No description provided for @message_review_noServingAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无服役中资产'**
  String get message_review_noServingAsset;

  /// No description provided for @message_review_quadrantLongLow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期低耗'**
  String get message_review_quadrantLongLow;

  /// No description provided for @message_review_quadrantShortHigh.
  ///
  /// In zh_Hans, this message translates to:
  /// **'短期高耗'**
  String get message_review_quadrantShortHigh;

  /// No description provided for @message_review_axisServiceDays.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服役天数'**
  String get message_review_axisServiceDays;

  /// No description provided for @message_review_axisDailyCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本'**
  String get message_review_axisDailyCost;

  /// No description provided for @message_review_quadrantLongHigh.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期高耗'**
  String get message_review_quadrantLongHigh;

  /// No description provided for @message_review_quadrantShortLow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'短期低耗'**
  String get message_review_quadrantShortLow;

  /// No description provided for @message_review_quadrantDetailTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'象限明细'**
  String get message_review_quadrantDetailTitle;

  /// No description provided for @message_review_quadrantDetailSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'查看每个象限里对应的资产'**
  String get message_review_quadrantDetailSubtitle;

  /// No description provided for @message_review_noAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无资产'**
  String get message_review_noAsset;

  /// No description provided for @message_review_served.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已服役'**
  String get message_review_served;

  /// No description provided for @message_review_dailyAvg.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均'**
  String get message_review_dailyAvg;

  /// No description provided for @message_review_snapshotTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照复盘'**
  String get message_review_snapshotTitle;

  /// No description provided for @message_review_snapshotSubtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用最新快照观察资产数量、心愿和净值变化'**
  String get message_review_snapshotSubtitle;

  /// No description provided for @message_review_noSnapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无快照'**
  String get message_review_noSnapshot;

  /// No description provided for @message_review_latestSnapshot.
  ///
  /// In zh_Hans, this message translates to:
  /// **'最新快照：'**
  String get message_review_latestSnapshot;

  /// No description provided for @message_review_assetCountChange.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产数量变化'**
  String get message_review_assetCountChange;

  /// No description provided for @message_review_wishCountChange.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿数量变化'**
  String get message_review_wishCountChange;

  /// No description provided for @message_review_wishItems.
  ///
  /// In zh_Hans, this message translates to:
  /// **'个心愿'**
  String get message_review_wishItems;

  /// No description provided for @message_review_netValueChange.
  ///
  /// In zh_Hans, this message translates to:
  /// **'净值变化'**
  String get message_review_netValueChange;

  /// No description provided for @message_review_dailyCostChange.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均变化'**
  String get message_review_dailyCostChange;

  /// No description provided for @message_select_immediateApply.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择后立即应用'**
  String get message_select_immediateApply;

  /// No description provided for @message_shell_tutorial_promptTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'要先看一遍新手教程吗？'**
  String get message_shell_tutorial_promptTitle;

  /// No description provided for @message_shell_tutorial_promptDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'教程会直接在真实界面里指出首页、心愿、分析和设置的核心入口'**
  String get message_shell_tutorial_promptDesc;

  /// No description provided for @message_shell_tutorial_notNow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'稍后再说'**
  String get message_shell_tutorial_notNow;

  /// No description provided for @message_shell_tutorial_start.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开始教程'**
  String get message_shell_tutorial_start;

  /// No description provided for @message_shell_tutorial_step1Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'首页总览：资产状态一眼看清'**
  String get message_shell_tutorial_step1Title;

  /// No description provided for @message_shell_tutorial_step1Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里汇总总资产、日均成本、服役、退役和卖出数量'**
  String get message_shell_tutorial_step1Subtitle;

  /// No description provided for @message_shell_tutorial_step1Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'先看总览，再决定要新增、筛选还是复盘资产'**
  String get message_shell_tutorial_step1Hint;

  /// No description provided for @message_shell_tutorial_step2Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'筛选与搜索：快速缩小范围'**
  String get message_shell_tutorial_step2Title;

  /// No description provided for @message_shell_tutorial_step2Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可按状态、分类、标签和目标筛选资产'**
  String get message_shell_tutorial_step2Subtitle;

  /// No description provided for @message_shell_tutorial_step2Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产多起来以后，筛选会比翻列表快很多'**
  String get message_shell_tutorial_step2Hint;

  /// No description provided for @message_shell_tutorial_step3TitleA.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产卡片：看价值，也看消耗'**
  String get message_shell_tutorial_step3TitleA;

  /// No description provided for @message_shell_tutorial_step3TitleB.
  ///
  /// In zh_Hans, this message translates to:
  /// **'空状态：从第一件资产开始'**
  String get message_shell_tutorial_step3TitleB;

  /// No description provided for @message_shell_tutorial_step3SubtitleA.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卡片展示价格、持有时间、状态和日均成本'**
  String get message_shell_tutorial_step3SubtitleA;

  /// No description provided for @message_shell_tutorial_step3SubtitleB.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击加号就能新增资产或心愿'**
  String get message_shell_tutorial_step3SubtitleB;

  /// No description provided for @message_shell_tutorial_step3HintA.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点进卡片可以查看完整生命周期和趋势'**
  String get message_shell_tutorial_step3HintA;

  /// No description provided for @message_shell_tutorial_step3HintB.
  ///
  /// In zh_Hans, this message translates to:
  /// **'先录入一件常用物品，值谱就能开始计算'**
  String get message_shell_tutorial_step3HintB;

  /// No description provided for @message_shell_tutorial_step4Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'底部导航：四个核心工作区'**
  String get message_shell_tutorial_step4Title;

  /// No description provided for @message_shell_tutorial_step4Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产、心愿、分析、设置都在底部导航里'**
  String get message_shell_tutorial_step4Subtitle;

  /// No description provided for @message_shell_tutorial_step4Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长按或滑动时 Dock 会有液态玻璃反馈'**
  String get message_shell_tutorial_step4Hint;

  /// No description provided for @message_shell_tutorial_step5Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'加号：最快的记录入口'**
  String get message_shell_tutorial_step5Title;

  /// No description provided for @message_shell_tutorial_step5Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增资产、心愿和快速操作都从这里开始'**
  String get message_shell_tutorial_step5Subtitle;

  /// No description provided for @message_shell_tutorial_step5Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录越顺手，复盘越有价值'**
  String get message_shell_tutorial_step5Hint;

  /// No description provided for @message_shell_tutorial_step6Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿：先放进清单，再决定购买'**
  String get message_shell_tutorial_step6Title;

  /// No description provided for @message_shell_tutorial_step6Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿页可以记录预算、理由和封面'**
  String get message_shell_tutorial_step6Subtitle;

  /// No description provided for @message_shell_tutorial_step6Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'真正购买后可以一键转为资产'**
  String get message_shell_tutorial_step6Hint;

  /// No description provided for @message_shell_tutorial_step7Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析：看清资产结构'**
  String get message_shell_tutorial_step7Title;

  /// No description provided for @message_shell_tutorial_step7Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'图表会展示总值、日均、分类和标签分布'**
  String get message_shell_tutorial_step7Subtitle;

  /// No description provided for @message_shell_tutorial_step7Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析页适合定期复盘，而不是每天都盯着看'**
  String get message_shell_tutorial_step7Hint;

  /// No description provided for @message_shell_tutorial_step8Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生命周期：从买入到回收'**
  String get message_shell_tutorial_step8Title;

  /// No description provided for @message_shell_tutorial_step8Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱会把买入、退役、卖出和回收串起来'**
  String get message_shell_tutorial_step8Subtitle;

  /// No description provided for @message_shell_tutorial_step8Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'它能帮你判断一件东西是否真的值得留下'**
  String get message_shell_tutorial_step8Hint;

  /// No description provided for @message_shell_tutorial_step9Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置：调整你的记录方式'**
  String get message_shell_tutorial_step9Title;

  /// No description provided for @message_shell_tutorial_step9Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、语言、格式、触感、贴纸和备份都在这里'**
  String get message_shell_tutorial_step9Subtitle;

  /// No description provided for @message_shell_tutorial_step9Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'常用入口会按分组收纳，避免设置页太乱'**
  String get message_shell_tutorial_step9Hint;

  /// No description provided for @message_shell_tutorial_step10Title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快速入口：常用管理放在前面'**
  String get message_shell_tutorial_step10Title;

  /// No description provided for @message_shell_tutorial_step10Subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类、标签、备份和教程重播都能快速进入'**
  String get message_shell_tutorial_step10Subtitle;

  /// No description provided for @message_shell_tutorial_step10Hint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'以后想重看教程，也可以从这里启动'**
  String get message_shell_tutorial_step10Hint;

  /// No description provided for @message_onboarding_skip.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跳过'**
  String get message_onboarding_skip;

  /// No description provided for @message_onboarding_next.
  ///
  /// In zh_Hans, this message translates to:
  /// **'下一页'**
  String get message_onboarding_next;

  /// No description provided for @message_onboarding_back.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上一页'**
  String get message_onboarding_back;

  /// No description provided for @message_onboarding_start.
  ///
  /// In zh_Hans, this message translates to:
  /// **'开始使用'**
  String get message_onboarding_start;

  /// No description provided for @message_onboarding_pageIndicator.
  ///
  /// In zh_Hans, this message translates to:
  /// **'欢迎引导，共三页'**
  String get message_onboarding_pageIndicator;

  /// No description provided for @message_onboarding_welcome_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'欢迎来到值谱'**
  String get message_onboarding_welcome_title;

  /// No description provided for @message_onboarding_welcome_slogan.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把每一次购买，变成一条看得见的价值轨迹'**
  String get message_onboarding_welcome_slogan;

  /// No description provided for @message_onboarding_welcome_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱是本地优先的个人资产生命周期管理工具，所有数据都保存在你的设备上，不注册账号，也不上传云端。'**
  String get message_onboarding_welcome_desc;

  /// No description provided for @message_onboarding_pill_local.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地优先'**
  String get message_onboarding_pill_local;

  /// No description provided for @message_onboarding_pill_noAccount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无需注册'**
  String get message_onboarding_pill_noAccount;

  /// No description provided for @message_onboarding_pill_private.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数据不出设备'**
  String get message_onboarding_pill_private;

  /// No description provided for @message_onboarding_concept_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不是记账，而是看懂价值'**
  String get message_onboarding_concept_title;

  /// No description provided for @message_onboarding_concept_desc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'值谱把价格、使用时间和生命周期放进同一条时间线，帮你判断一件东西今天是否仍然值得。'**
  String get message_onboarding_concept_desc;

  /// No description provided for @message_onboarding_concept_chart.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本随使用时间下降'**
  String get message_onboarding_concept_chart;

  /// No description provided for @message_onboarding_concept_example.
  ///
  /// In zh_Hans, this message translates to:
  /// **'一件 8,000 元的手机用了四年，日均成本可能不到 6 元；一件 500 元的配件三天后闲置，反而值得重新审视。'**
  String get message_onboarding_concept_example;

  /// No description provided for @message_onboarding_features_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'四个工作区，各管一段'**
  String get message_onboarding_features_title;

  /// No description provided for @message_onboarding_features_assets.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产'**
  String get message_onboarding_features_assets;

  /// No description provided for @message_onboarding_features_assetsDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录买入、服役、退役与卖出'**
  String get message_onboarding_features_assetsDesc;

  /// No description provided for @message_onboarding_features_wishes.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿'**
  String get message_onboarding_features_wishes;

  /// No description provided for @message_onboarding_features_wishesDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'先放进清单，购买后一键转为资产'**
  String get message_onboarding_features_wishesDesc;

  /// No description provided for @message_onboarding_features_analytics.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析'**
  String get message_onboarding_features_analytics;

  /// No description provided for @message_onboarding_features_analyticsDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'总值、日均与结构，适合定期复盘'**
  String get message_onboarding_features_analyticsDesc;

  /// No description provided for @message_onboarding_features_settings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置'**
  String get message_onboarding_features_settings;

  /// No description provided for @message_onboarding_features_settingsDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、语言、格式与备份'**
  String get message_onboarding_features_settingsDesc;

  /// No description provided for @message_sticker_modelStatus.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主体分割模型'**
  String get message_sticker_modelStatus;

  /// No description provided for @message_sticker_modelDownloading.
  ///
  /// In zh_Hans, this message translates to:
  /// **'模型下载中，首次使用可能需要网络'**
  String get message_sticker_modelDownloading;

  /// No description provided for @message_sticker_modelReady.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主体模型已就绪'**
  String get message_sticker_modelReady;

  /// No description provided for @message_sticker_modelUnavailable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'模型不可用，将使用离线轮廓回退'**
  String get message_sticker_modelUnavailable;

  /// No description provided for @message_sticker_updating.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在更新预览'**
  String get message_sticker_updating;

  /// No description provided for @message_sticker_contain.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完整显示'**
  String get message_sticker_contain;

  /// No description provided for @message_sticker_fill.
  ///
  /// In zh_Hans, this message translates to:
  /// **'填满画面'**
  String get message_sticker_fill;

  /// No description provided for @message_sticker_livePreview.
  ///
  /// In zh_Hans, this message translates to:
  /// **'实时预览'**
  String get message_sticker_livePreview;

  /// No description provided for @message_sticker_eraseTrim.
  ///
  /// In zh_Hans, this message translates to:
  /// **'擦除裁切'**
  String get message_sticker_eraseTrim;

  /// No description provided for @message_sticker_restoreTrim.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复裁切'**
  String get message_sticker_restoreTrim;

  /// No description provided for @message_sticker_repairTitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'边缘修补'**
  String get message_sticker_repairTitle;

  /// No description provided for @message_sticker_repairDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用画笔修正自动抠图留下的边缘瑕疵'**
  String get message_sticker_repairDesc;

  /// No description provided for @message_sticker_tools.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具'**
  String get message_sticker_tools;

  /// No description provided for @message_sticker_move.
  ///
  /// In zh_Hans, this message translates to:
  /// **'移动'**
  String get message_sticker_move;

  /// No description provided for @message_sticker_eraser.
  ///
  /// In zh_Hans, this message translates to:
  /// **'橡皮擦'**
  String get message_sticker_eraser;

  /// No description provided for @message_sticker_restore.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复'**
  String get message_sticker_restore;

  /// No description provided for @message_sticker_brushSize.
  ///
  /// In zh_Hans, this message translates to:
  /// **'画笔大小'**
  String get message_sticker_brushSize;

  /// No description provided for @message_sticker_undoTrim.
  ///
  /// In zh_Hans, this message translates to:
  /// **'撤销裁切'**
  String get message_sticker_undoTrim;

  /// No description provided for @message_sticker_clearTrim.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清除裁切'**
  String get message_sticker_clearTrim;

  /// No description provided for @message_sticker_composition.
  ///
  /// In zh_Hans, this message translates to:
  /// **'构图'**
  String get message_sticker_composition;

  /// No description provided for @message_sticker_zoom.
  ///
  /// In zh_Hans, this message translates to:
  /// **'缩放'**
  String get message_sticker_zoom;

  /// No description provided for @message_sticker_moveHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'拖动主体，调整贴纸在画面中的位置'**
  String get message_sticker_moveHint;

  /// No description provided for @message_sticker_edgeOptimization.
  ///
  /// In zh_Hans, this message translates to:
  /// **'边缘优化'**
  String get message_sticker_edgeOptimization;

  /// No description provided for @message_sticker_modeBalanced.
  ///
  /// In zh_Hans, this message translates to:
  /// **'均衡'**
  String get message_sticker_modeBalanced;

  /// No description provided for @message_sticker_modeSubject.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保主体'**
  String get message_sticker_modeSubject;

  /// No description provided for @message_sticker_modeEdge.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保边缘'**
  String get message_sticker_modeEdge;

  /// No description provided for @message_sticker_modeAggressive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'强力清理'**
  String get message_sticker_modeAggressive;

  /// No description provided for @message_sticker_edgeOptimizationDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'根据图片内容调整抠图边缘的保留和清理强度'**
  String get message_sticker_edgeOptimizationDesc;

  /// No description provided for @message_sticker_edgePreserve.
  ///
  /// In zh_Hans, this message translates to:
  /// **'边缘保留'**
  String get message_sticker_edgePreserve;

  /// No description provided for @message_sticker_edgeMore.
  ///
  /// In zh_Hans, this message translates to:
  /// **'更多保留'**
  String get message_sticker_edgeMore;

  /// No description provided for @message_sticker_edgeCleaner.
  ///
  /// In zh_Hans, this message translates to:
  /// **'更干净'**
  String get message_sticker_edgeCleaner;

  /// No description provided for @message_sticker_edgeDefault.
  ///
  /// In zh_Hans, this message translates to:
  /// **'默认'**
  String get message_sticker_edgeDefault;

  /// No description provided for @message_sticker_edgePreserveHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留更多边缘可以减少误删；清理更强会让轮廓更利落'**
  String get message_sticker_edgePreserveHint;

  /// No description provided for @message_sticker_cleanupNone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不清理'**
  String get message_sticker_cleanupNone;

  /// No description provided for @message_sticker_cleanupWhite.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清白边'**
  String get message_sticker_cleanupWhite;

  /// No description provided for @message_sticker_cleanupBlack.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清黑边'**
  String get message_sticker_cleanupBlack;

  /// No description provided for @message_sticker_cleanupCorner.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清角落'**
  String get message_sticker_cleanupCorner;

  /// No description provided for @message_sticker_colorTolerance.
  ///
  /// In zh_Hans, this message translates to:
  /// **'颜色容差'**
  String get message_sticker_colorTolerance;

  /// No description provided for @message_sticker_colorToleranceHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'容差越高，越容易把相近颜色一起清理掉'**
  String get message_sticker_colorToleranceHint;

  /// No description provided for @message_sticker_useOriginal.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用原图'**
  String get message_sticker_useOriginal;

  /// No description provided for @message_sticker_applyAndGenerate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'应用并生成'**
  String get message_sticker_applyAndGenerate;

  /// No description provided for @message_sticker_chooseCover.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择封面'**
  String get message_sticker_chooseCover;

  /// No description provided for @message_sticker_chooseCoverHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从候选结果中挑一张最适合作为贴纸或封面的图片'**
  String get message_sticker_chooseCoverHint;

  /// No description provided for @message_sticker_candidate.
  ///
  /// In zh_Hans, this message translates to:
  /// **'候选 {n}'**
  String message_sticker_candidate({required Object n});

  /// No description provided for @message_sticker_localEngine.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地引擎'**
  String get message_sticker_localEngine;

  /// No description provided for @message_sticker_directCrop.
  ///
  /// In zh_Hans, this message translates to:
  /// **'直接裁切'**
  String get message_sticker_directCrop;

  /// No description provided for @message_sticker_frameCrop.
  ///
  /// In zh_Hans, this message translates to:
  /// **'白框裁切'**
  String get message_sticker_frameCrop;

  /// No description provided for @message_sticker_frameCropDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'为主体添加留白和圆角，让封面更像实体贴纸'**
  String get message_sticker_frameCropDesc;

  /// No description provided for @message_sticker_frameStyle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'边框样式'**
  String get message_sticker_frameStyle;

  /// No description provided for @message_sticker_frameThickness.
  ///
  /// In zh_Hans, this message translates to:
  /// **'边框厚度'**
  String get message_sticker_frameThickness;

  /// No description provided for @message_sticker_cornerRadius.
  ///
  /// In zh_Hans, this message translates to:
  /// **'圆角'**
  String get message_sticker_cornerRadius;

  /// No description provided for @message_sticker_outerMargin.
  ///
  /// In zh_Hans, this message translates to:
  /// **'外边距'**
  String get message_sticker_outerMargin;

  /// No description provided for @message_sticker_generateFrame.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成白框'**
  String get message_sticker_generateFrame;

  /// No description provided for @message_sticker_manualTrace.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手动勾勒'**
  String get message_sticker_manualTrace;

  /// No description provided for @message_sticker_manualTraceDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'沿主体边缘点按形成轮廓，适合自动抠图不够准确的图片'**
  String get message_sticker_manualTraceDesc;

  /// No description provided for @message_sticker_traceHint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'沿主体边缘依次点按，闭合后生成贴纸'**
  String get message_sticker_traceHint;

  /// No description provided for @message_sticker_traceSteps.
  ///
  /// In zh_Hans, this message translates to:
  /// **'至少需要 3 个点形成轮廓'**
  String get message_sticker_traceSteps;

  /// No description provided for @message_sticker_undoPoint.
  ///
  /// In zh_Hans, this message translates to:
  /// **'撤销一点'**
  String get message_sticker_undoPoint;

  /// No description provided for @message_sticker_clearRedraw.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清空重画'**
  String get message_sticker_clearRedraw;

  /// No description provided for @message_sticker_needMinPoints.
  ///
  /// In zh_Hans, this message translates to:
  /// **'至少需要 3 个点'**
  String get message_sticker_needMinPoints;

  /// No description provided for @message_sticker_generateAndAdjust.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生成并调整'**
  String get message_sticker_generateAndAdjust;

  /// No description provided for @message_store_cloudEnableFirst.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请先开启云端同步'**
  String get message_store_cloudEnableFirst;

  /// No description provided for @message_store_cloudTestOk.
  ///
  /// In zh_Hans, this message translates to:
  /// **'连接成功'**
  String get message_store_cloudTestOk;

  /// No description provided for @message_store_cloudTestFail.
  ///
  /// In zh_Hans, this message translates to:
  /// **'连接失败'**
  String get message_store_cloudTestFail;

  /// No description provided for @message_store_connectFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'连接失败'**
  String get message_store_connectFailed;

  /// No description provided for @message_store_cloudConfigFirst.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请先完成云端同步配置'**
  String get message_store_cloudConfigFirst;

  /// No description provided for @message_store_cloudUploaded.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已上传到云端'**
  String get message_store_cloudUploaded;

  /// No description provided for @message_store_cloudNoChanges.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端内容未变化，已跳过上传'**
  String get message_store_cloudNoChanges;

  /// No description provided for @message_store_cloudConflict.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端版本发生冲突，请先确认本机与云端数据'**
  String get message_store_cloudConflict;

  /// No description provided for @message_store_uploadFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上传失败'**
  String get message_store_uploadFailed;

  /// No description provided for @message_store_cloudDownloaded.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从云端下载'**
  String get message_store_cloudDownloaded;

  /// No description provided for @message_store_downloadFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'下载失败'**
  String get message_store_downloadFailed;

  /// No description provided for @message_store_leakIdle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'闲置/吃灰仍在摊销'**
  String get message_store_leakIdle;

  /// No description provided for @message_store_leakHighDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均成本偏高'**
  String get message_store_leakHighDaily;

  /// No description provided for @message_store_leakTargetSlow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标进度偏慢'**
  String get message_store_leakTargetSlow;

  /// No description provided for @message_store_leakExpiringSoon.
  ///
  /// In zh_Hans, this message translates to:
  /// **'即将到期'**
  String get message_store_leakExpiringSoon;

  /// No description provided for @message_store_leakSuggestIdle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'考虑转让、回收或重新启用，避免继续沉没成本'**
  String get message_store_leakSuggestIdle;

  /// No description provided for @message_store_leakSuggestHighDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'如果近期使用频率不高，可以设置卖出或退役计划'**
  String get message_store_leakSuggestHighDaily;

  /// No description provided for @message_store_leakSuggestTargetSlow.
  ///
  /// In zh_Hans, this message translates to:
  /// **'调低目标日耗、延长使用周期，或重新评估是否值得保留'**
  String get message_store_leakSuggestTargetSlow;

  /// No description provided for @message_store_leakSuggestExpiring.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提前续费、维修或处理，避免到期后被动补救'**
  String get message_store_leakSuggestExpiring;

  /// No description provided for @message_store_eventRecord.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录'**
  String get message_store_eventRecord;

  /// No description provided for @message_store_eventBuy.
  ///
  /// In zh_Hans, this message translates to:
  /// **'买入'**
  String get message_store_eventBuy;

  /// No description provided for @message_store_eventRetire.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役'**
  String get message_store_eventRetire;

  /// No description provided for @message_store_eventTotalRecord.
  ///
  /// In zh_Hans, this message translates to:
  /// **'累计记录'**
  String get message_store_eventTotalRecord;

  /// No description provided for @message_store_eventTotalServed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'累计服役'**
  String get message_store_eventTotalServed;

  /// No description provided for @message_store_eventFinalDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'，最终日均'**
  String get message_store_eventFinalDaily;

  /// No description provided for @message_store_perDay.
  ///
  /// In zh_Hans, this message translates to:
  /// **'/天'**
  String get message_store_perDay;

  /// No description provided for @message_store_eventSold.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出'**
  String get message_store_eventSold;

  /// No description provided for @message_store_eventRecovered.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收'**
  String get message_store_eventRecovered;

  /// No description provided for @message_store_eventNetCost.
  ///
  /// In zh_Hans, this message translates to:
  /// **'，净成本'**
  String get message_store_eventNetCost;

  /// No description provided for @message_store_assetDefault.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产'**
  String get message_store_assetDefault;

  /// No description provided for @message_store_listSep.
  ///
  /// In zh_Hans, this message translates to:
  /// **'、'**
  String get message_store_listSep;

  /// No description provided for @message_store_eventRecovery.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收'**
  String get message_store_eventRecovery;

  /// No description provided for @message_store_noAssetSelected.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未选择资产'**
  String get message_store_noAssetSelected;

  /// No description provided for @message_store_eventRecoveredAmount.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收金额'**
  String get message_store_eventRecoveredAmount;

  /// No description provided for @message_store_insightHighDaily.
  ///
  /// In zh_Hans, this message translates to:
  /// **'高日耗预警'**
  String get message_store_insightHighDaily;

  /// No description provided for @message_store_insightHighDailyDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前日均成本为'**
  String get message_store_insightHighDailyDesc;

  /// No description provided for @message_store_insightHighDailyAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'，建议尽快复盘使用频率'**
  String get message_store_insightHighDailyAction;

  /// No description provided for @message_store_insightTargetDone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标已达成'**
  String get message_store_insightTargetDone;

  /// No description provided for @message_store_insightTargetDoneDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已经达到设定目标，可以考虑继续服役或记录回收'**
  String get message_store_insightTargetDoneDesc;

  /// No description provided for @message_store_insightExpiring.
  ///
  /// In zh_Hans, this message translates to:
  /// **'即将到期'**
  String get message_store_insightExpiring;

  /// No description provided for @message_store_insightExpiringDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'将在'**
  String get message_store_insightExpiringDesc;

  /// No description provided for @message_store_insightExpiringAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期，请提前处理'**
  String get message_store_insightExpiringAction;

  /// No description provided for @message_store_insightIdle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'闲置资产偏多'**
  String get message_store_insightIdle;

  /// No description provided for @message_store_insightIdleDesc1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目前有'**
  String get message_store_insightIdleDesc1;

  /// No description provided for @message_store_insightIdleDesc2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'件疑似闲置资产，适合做一次整理'**
  String get message_store_insightIdleDesc2;

  /// No description provided for @message_store_insightWishBudget.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿预算偏高'**
  String get message_store_insightWishBudget;

  /// No description provided for @message_store_insightWishBudgetDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未完成心愿预算已达'**
  String get message_store_insightWishBudgetDesc;

  /// No description provided for @message_store_insightWishBudgetAction.
  ///
  /// In zh_Hans, this message translates to:
  /// **'，建议先排序优先级'**
  String get message_store_insightWishBudgetAction;

  /// No description provided for @message_store_insightStable.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产状态稳定'**
  String get message_store_insightStable;

  /// No description provided for @message_store_insightStableDesc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂未发现明显钱包漏洞，保持当前记录节奏即可'**
  String get message_store_insightStableDesc;

  /// No description provided for @message_store_catDigital.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电子数码'**
  String get message_store_catDigital;

  /// No description provided for @message_store_catAudioVideo.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影音设备'**
  String get message_store_catAudioVideo;

  /// No description provided for @message_store_catPhotoCreative.
  ///
  /// In zh_Hans, this message translates to:
  /// **'摄影创作'**
  String get message_store_catPhotoCreative;

  /// No description provided for @message_store_catGameHobby.
  ///
  /// In zh_Hans, this message translates to:
  /// **'游戏爱好'**
  String get message_store_catGameHobby;

  /// No description provided for @message_store_catWorkStudy.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学习办公'**
  String get message_store_catWorkStudy;

  /// No description provided for @message_store_catWearStyle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'穿戴风格'**
  String get message_store_catWearStyle;

  /// No description provided for @message_store_catHomeLife.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家居生活'**
  String get message_store_catHomeLife;

  /// No description provided for @message_store_catTransport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'交通出行'**
  String get message_store_catTransport;

  /// No description provided for @message_store_catSportHealth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'运动健康'**
  String get message_store_catSportHealth;

  /// No description provided for @message_store_catToolsRepair.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具维修'**
  String get message_store_catToolsRepair;

  /// No description provided for @message_store_catCollection.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收藏纪念'**
  String get message_store_catCollection;

  /// No description provided for @message_store_catService.
  ///
  /// In zh_Hans, this message translates to:
  /// **'订阅服务'**
  String get message_store_catService;

  /// No description provided for @message_store_aliasPhone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手机'**
  String get message_store_aliasPhone;

  /// No description provided for @message_store_aliasComputer.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电脑'**
  String get message_store_aliasComputer;

  /// No description provided for @message_store_aliasTablet.
  ///
  /// In zh_Hans, this message translates to:
  /// **'平板'**
  String get message_store_aliasTablet;

  /// No description provided for @message_store_aliasDigitalAccessories.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数码配件'**
  String get message_store_aliasDigitalAccessories;

  /// No description provided for @message_store_aliasDigital.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数码'**
  String get message_store_aliasDigital;

  /// No description provided for @message_store_aliasEarphone.
  ///
  /// In zh_Hans, this message translates to:
  /// **'耳机'**
  String get message_store_aliasEarphone;

  /// No description provided for @message_store_aliasAudio.
  ///
  /// In zh_Hans, this message translates to:
  /// **'音频'**
  String get message_store_aliasAudio;

  /// No description provided for @message_store_aliasAv.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影音'**
  String get message_store_aliasAv;

  /// No description provided for @message_store_aliasPhotography.
  ///
  /// In zh_Hans, this message translates to:
  /// **'摄影'**
  String get message_store_aliasPhotography;

  /// No description provided for @message_store_aliasCamera.
  ///
  /// In zh_Hans, this message translates to:
  /// **'相机'**
  String get message_store_aliasCamera;

  /// No description provided for @message_store_aliasLens.
  ///
  /// In zh_Hans, this message translates to:
  /// **'镜头'**
  String get message_store_aliasLens;

  /// No description provided for @message_store_aliasGame.
  ///
  /// In zh_Hans, this message translates to:
  /// **'游戏'**
  String get message_store_aliasGame;

  /// No description provided for @message_store_aliasEntertainment.
  ///
  /// In zh_Hans, this message translates to:
  /// **'娱乐'**
  String get message_store_aliasEntertainment;

  /// No description provided for @message_store_aliasHobby.
  ///
  /// In zh_Hans, this message translates to:
  /// **'爱好'**
  String get message_store_aliasHobby;

  /// No description provided for @message_store_aliasStudy.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学习'**
  String get message_store_aliasStudy;

  /// No description provided for @message_store_aliasOffice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'办公'**
  String get message_store_aliasOffice;

  /// No description provided for @message_store_aliasBook.
  ///
  /// In zh_Hans, this message translates to:
  /// **'书'**
  String get message_store_aliasBook;

  /// No description provided for @message_store_aliasClothing.
  ///
  /// In zh_Hans, this message translates to:
  /// **'衣物'**
  String get message_store_aliasClothing;

  /// No description provided for @message_store_aliasOutfit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'穿搭'**
  String get message_store_aliasOutfit;

  /// No description provided for @message_store_aliasShoesBags.
  ///
  /// In zh_Hans, this message translates to:
  /// **'鞋包'**
  String get message_store_aliasShoesBags;

  /// No description provided for @message_store_aliasHome.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家居'**
  String get message_store_aliasHome;

  /// No description provided for @message_store_aliasAppliance.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家电'**
  String get message_store_aliasAppliance;

  /// No description provided for @message_store_aliasLife.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生活'**
  String get message_store_aliasLife;

  /// No description provided for @message_store_aliasTransport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'交通'**
  String get message_store_aliasTransport;

  /// No description provided for @message_store_aliasTravel.
  ///
  /// In zh_Hans, this message translates to:
  /// **'旅行'**
  String get message_store_aliasTravel;

  /// No description provided for @message_store_aliasTrip.
  ///
  /// In zh_Hans, this message translates to:
  /// **'出行'**
  String get message_store_aliasTrip;

  /// No description provided for @message_store_aliasSport.
  ///
  /// In zh_Hans, this message translates to:
  /// **'运动'**
  String get message_store_aliasSport;

  /// No description provided for @message_store_aliasHealth.
  ///
  /// In zh_Hans, this message translates to:
  /// **'健康'**
  String get message_store_aliasHealth;

  /// No description provided for @message_store_aliasTool.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具'**
  String get message_store_aliasTool;

  /// No description provided for @message_store_aliasRepair.
  ///
  /// In zh_Hans, this message translates to:
  /// **'维修'**
  String get message_store_aliasRepair;

  /// No description provided for @message_store_aliasCollection.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收藏'**
  String get message_store_aliasCollection;

  /// No description provided for @message_store_aliasMemorial.
  ///
  /// In zh_Hans, this message translates to:
  /// **'纪念'**
  String get message_store_aliasMemorial;

  /// No description provided for @message_store_aliasSubscribe.
  ///
  /// In zh_Hans, this message translates to:
  /// **'订阅'**
  String get message_store_aliasSubscribe;

  /// No description provided for @message_store_aliasSoftware.
  ///
  /// In zh_Hans, this message translates to:
  /// **'软件'**
  String get message_store_aliasSoftware;

  /// No description provided for @message_store_aliasService.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服务'**
  String get message_store_aliasService;

  /// No description provided for @message_system_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统操作'**
  String get message_system_title;

  /// No description provided for @message_system_subtitle.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享、恢复、系统设置和外部意图读入'**
  String get message_system_subtitle;

  /// No description provided for @message_system_shareArchive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享完整资料包'**
  String get message_system_shareArchive;

  /// No description provided for @message_system_restoreArchive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复资料包'**
  String get message_system_restoreArchive;

  /// No description provided for @message_system_shareSummary.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享资产摘要'**
  String get message_system_shareSummary;

  /// No description provided for @message_system_shareText.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享文本报告'**
  String get message_system_shareText;

  /// No description provided for @message_system_noShareData.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有可读取的分享数据'**
  String get message_system_noShareData;

  /// No description provided for @message_system_readIntent.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取启动意图'**
  String get message_system_readIntent;

  /// No description provided for @message_system_openAppSettings.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开系统设置'**
  String get message_system_openAppSettings;

  /// No description provided for @message_tag_commute.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通勤'**
  String get message_tag_commute;

  /// No description provided for @message_tag_office.
  ///
  /// In zh_Hans, this message translates to:
  /// **'办公'**
  String get message_tag_office;

  /// No description provided for @message_tag_study.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学习'**
  String get message_tag_study;

  /// No description provided for @message_tag_collection.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收藏'**
  String get message_tag_collection;

  /// No description provided for @message_tag_dusty.
  ///
  /// In zh_Hans, this message translates to:
  /// **'吃灰'**
  String get message_tag_dusty;

  /// No description provided for @message_tag_repair.
  ///
  /// In zh_Hans, this message translates to:
  /// **'维修'**
  String get message_tag_repair;

  /// No description provided for @message_tag_accessory.
  ///
  /// In zh_Hans, this message translates to:
  /// **'配件'**
  String get message_tag_accessory;

  /// No description provided for @message_tag_longTerm.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期'**
  String get message_tag_longTerm;

  /// No description provided for @message_wish_title.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿'**
  String get message_wish_title;

  /// No description provided for @message_wish_totalValue.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿总额'**
  String get message_wish_totalValue;

  /// No description provided for @message_wish_count.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{n} 个心愿'**
  String message_wish_count({required Object n});

  /// No description provided for @message_wish_active.
  ///
  /// In zh_Hans, this message translates to:
  /// **'进行中'**
  String get message_wish_active;

  /// No description provided for @message_wish_archived.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已归档'**
  String get message_wish_archived;

  /// No description provided for @message_wish_empty.
  ///
  /// In zh_Hans, this message translates to:
  /// **'还没有心愿'**
  String get message_wish_empty;

  /// No description provided for @message_wish_emptyTapPrefix.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点按'**
  String get message_wish_emptyTapPrefix;

  /// No description provided for @message_wish_emptyTapSuffix.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加想买但还没决定的东西'**
  String get message_wish_emptyTapSuffix;

  /// No description provided for @message_wish_convertedToAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已转为资产'**
  String get message_wish_convertedToAsset;

  /// No description provided for @message_wish_convertFailed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'转换失败，原心愿数据未改变'**
  String get message_wish_convertFailed;

  /// No description provided for @message_wish_convertToAsset.
  ///
  /// In zh_Hans, this message translates to:
  /// **'转为资产'**
  String get message_wish_convertToAsset;

  /// No description provided for @message_wish_restore.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复心愿'**
  String get message_wish_restore;

  /// No description provided for @message_wish_archive.
  ///
  /// In zh_Hans, this message translates to:
  /// **'归档心愿'**
  String get message_wish_archive;

  /// No description provided for @message_wish_titleNew.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增心愿'**
  String get message_wish_titleNew;

  /// No description provided for @message_wish_titleEdit.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑心愿'**
  String get message_wish_titleEdit;

  /// No description provided for @message_wish_name.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿名称'**
  String get message_wish_name;

  /// No description provided for @message_wish_expectedPrice.
  ///
  /// In zh_Hans, this message translates to:
  /// **'预计价格'**
  String get message_wish_expectedPrice;

  /// No description provided for @message_wish_purchaseReason.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买理由'**
  String get message_wish_purchaseReason;

  /// No description provided for @message_wish_save.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存心愿'**
  String get message_wish_save;

  /// No description provided for @message_wish_coverSet.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已设置心愿封面'**
  String get message_wish_coverSet;

  /// No description provided for @message_wish_noStickerGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'没有生成可用贴纸'**
  String get message_wish_noStickerGenerated;

  /// No description provided for @message_wish_cutoutSelectedFromN.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已从 {n} 个候选中选择贴纸'**
  String message_wish_cutoutSelectedFromN({required Object n});

  /// No description provided for @message_wish_stickerCoverGenerated.
  ///
  /// In zh_Hans, this message translates to:
  /// **'贴纸封面已生成'**
  String get message_wish_stickerCoverGenerated;

  /// No description provided for @literal_ed7d6ce0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'AI 贴纸会从图片中生成更像贴纸的主体效果，并提供边缘、描边、阴影等预览调节，适合做更精致的资产图标。'**
  String get literal_ed7d6ce0;

  /// No description provided for @literal_7f8d272c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'AI 贴纸：候选图与实时调整'**
  String get literal_7f8d272c;

  /// No description provided for @literal_2eec59fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'Android 原生震动'**
  String get literal_2eec59fd;

  /// No description provided for @literal_74c47de1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'JSON 已复制到剪贴板'**
  String get literal_74c47de1;

  /// No description provided for @literal_542d0806.
  ///
  /// In zh_Hans, this message translates to:
  /// **'JSON 格式不正确'**
  String get literal_542d0806;

  /// No description provided for @literal_16c1a401.
  ///
  /// In zh_Hans, this message translates to:
  /// **'WebDAV 已可直接上传/读取 JSON 备份；坚果云和 Nextcloud 本质也是 WebDAV 端点。'**
  String get literal_16c1a401;

  /// No description provided for @literal_b608171b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'WebDAV、坚果云、Nextcloud 与手动文件备份'**
  String get literal_b608171b;

  /// No description provided for @literal_2afc5776.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{app} JSON 备份'**
  String literal_2afc5776({required Object app});

  /// No description provided for @literal_70b0f9ef.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{categories} 个分类 · {tags} 个标签'**
  String literal_70b0f9ef({required Object categories, required Object tags});

  /// No description provided for @literal_a071aad2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 个'**
  String literal_a071aad2({required Object count});

  /// No description provided for @literal_6b72ea63.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 份'**
  String literal_6b72ea63({required Object count});

  /// No description provided for @literal_bb704253.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 位'**
  String literal_bb704253({required Object count});

  /// No description provided for @literal_f129c055.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{count} 类'**
  String literal_f129c055({required Object count});

  /// No description provided for @literal_82f76a83.
  ///
  /// In zh_Hans, this message translates to:
  /// **'{name} 带来的收益'**
  String literal_82f76a83({required Object name});

  /// No description provided for @literal_eec10685.
  ///
  /// In zh_Hans, this message translates to:
  /// **'“新手教程”入口会重新播放这一整套真实界面引导。'**
  String get literal_eec10685;

  /// No description provided for @literal_435a3ca6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上一步'**
  String get literal_435a3ca6;

  /// No description provided for @literal_b0b90883.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上传当前备份'**
  String get literal_b0b90883;

  /// No description provided for @literal_c30fedac.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上次上传：{date}'**
  String literal_c30fedac({required Object date});

  /// No description provided for @literal_24a7ae95.
  ///
  /// In zh_Hans, this message translates to:
  /// **'上次读取：{date}'**
  String literal_24a7ae95({required Object date});

  /// No description provided for @literal_10c83c81.
  ///
  /// In zh_Hans, this message translates to:
  /// **'下一步'**
  String get literal_10c83c81;

  /// No description provided for @literal_dc7a5431.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不用手动输入颜色或图标，直接点选即可。'**
  String get literal_dc7a5431;

  /// No description provided for @literal_955a257b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不用手动输入颜色，直接从色板选择。'**
  String get literal_955a257b;

  /// No description provided for @literal_7abb0d05.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、首页、金额格式、触感和提示条'**
  String get literal_7abb0d05;

  /// No description provided for @literal_7aaf04af.
  ///
  /// In zh_Hans, this message translates to:
  /// **'主题、首页风格、金额格式、时长显示、首页副信息字号、触感反馈和贴纸引擎都在这里。'**
  String get literal_7aaf04af;

  /// No description provided for @literal_cf210aa5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'乐器'**
  String get literal_cf210aa5;

  /// No description provided for @literal_e3612999.
  ///
  /// In zh_Hans, this message translates to:
  /// **'书'**
  String get literal_e3612999;

  /// No description provided for @literal_c63a1cbc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'书籍'**
  String get literal_c63a1cbc;

  /// No description provided for @literal_d1d3553e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'买入'**
  String get literal_d1d3553e;

  /// No description provided for @literal_42d5bac4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二手回收'**
  String get literal_42d5bac4;

  /// No description provided for @literal_1b32a966.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单本身也进入教程，而不是只停留在一级设置页。'**
  String get literal_1b32a966;

  /// No description provided for @literal_f92fc8a0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单进入时不会再触发行项目闪动，预测式返回只在真正返回时生效。'**
  String get literal_f92fc8a0;

  /// No description provided for @literal_1a472551.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单：外观与交互'**
  String get literal_1a472551;

  /// No description provided for @literal_d7fcb469.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单：数据与备份'**
  String get literal_d7fcb469;

  /// No description provided for @literal_e8ee776e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'二级菜单：系统与权限'**
  String get literal_e8ee776e;

  /// No description provided for @literal_87004dfa.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端同步设置'**
  String get literal_87004dfa;

  /// No description provided for @literal_4c79a345.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端同步设置已保存'**
  String get literal_4c79a345;

  /// No description provided for @literal_88c1a695.
  ///
  /// In zh_Hans, this message translates to:
  /// **'留空以保留已保存凭据'**
  String get literal_88c1a695;

  /// No description provided for @literal_316c9718.
  ///
  /// In zh_Hans, this message translates to:
  /// **'不会回显；重新输入以替换'**
  String get literal_316c9718;

  /// No description provided for @literal_6fac2293.
  ///
  /// In zh_Hans, this message translates to:
  /// **'凭据已安全保存，不会回显密码；两项留空即可保留'**
  String get literal_6fac2293;

  /// No description provided for @literal_58c95b63.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提示：坚果云通常要使用“应用密码”；Nextcloud 地址一般类似 /remote.php/dav/files/用户名/。账号和密码使用 Android Keystore 保护，不会进入 JSON、剪贴板或云端备份。'**
  String get literal_58c95b63;

  /// No description provided for @literal_e6d79f62.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已清除安全凭据'**
  String get literal_e6d79f62;

  /// No description provided for @literal_832b8b90.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清除已保存凭据'**
  String get literal_832b8b90;

  /// No description provided for @literal_bda56d7a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端快速操作'**
  String get literal_bda56d7a;

  /// No description provided for @literal_73b1f310.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端操作'**
  String get literal_73b1f310;

  /// No description provided for @literal_23e24380.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端冲突'**
  String get literal_23e24380;

  /// No description provided for @literal_09733984.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端版本冲突'**
  String get literal_09733984;

  /// No description provided for @literal_bf357f70.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机和云端都发生过变化，未自动覆盖任何一方'**
  String get literal_bf357f70;

  /// No description provided for @literal_759608e0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'为避免静默覆盖，上传已停止。请明确选择保留本机或从云端恢复。'**
  String get literal_759608e0;

  /// No description provided for @literal_28a9ee20.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机摘要'**
  String get literal_28a9ee20;

  /// No description provided for @literal_1bff9546.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端摘要'**
  String get literal_1bff9546;

  /// No description provided for @literal_f1af9815.
  ///
  /// In zh_Hans, this message translates to:
  /// **'项资产'**
  String get literal_f1af9815;

  /// No description provided for @literal_df1a007f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'个心愿'**
  String get literal_df1a007f;

  /// No description provided for @literal_f48e7cf2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端 ETag'**
  String get literal_f48e7cf2;

  /// No description provided for @literal_7870ae85.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留本机'**
  String get literal_7870ae85;

  /// No description provided for @literal_27075c92.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确认从云端恢复'**
  String get literal_27075c92;

  /// No description provided for @literal_238507bf.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端文件路径'**
  String get literal_238507bf;

  /// No description provided for @literal_7c861868.
  ///
  /// In zh_Hans, this message translates to:
  /// **'云端方案'**
  String get literal_7c861868;

  /// No description provided for @literal_3b165556.
  ///
  /// In zh_Hans, this message translates to:
  /// **'交互反馈'**
  String get literal_3b165556;

  /// No description provided for @literal_b3a08d0b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'交通'**
  String get literal_b3a08d0b;

  /// No description provided for @literal_f4c8fe40.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从云端恢复'**
  String get literal_f4c8fe40;

  /// No description provided for @literal_b5da288d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从云端恢复？'**
  String get literal_b5da288d;

  /// No description provided for @literal_4988e03e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从云端拉取'**
  String get literal_4988e03e;

  /// No description provided for @literal_a3c00f0f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从完整资料包 ZIP 恢复'**
  String get literal_a3c00f0f;

  /// No description provided for @literal_035966e8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从系统文件选择 JSON（纯数据）'**
  String get literal_035966e8;

  /// No description provided for @literal_a626b12c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'从记录日期开始，已经过去 {duration}'**
  String literal_a626b12c({required Object duration});

  /// No description provided for @literal_726077b6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价'**
  String get literal_726077b6;

  /// No description provided for @literal_975e3e3e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值'**
  String get literal_975e3e3e;

  /// No description provided for @literal_1c12b322.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价值回收'**
  String get literal_1c12b322;

  /// No description provided for @literal_7fb138c1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格、购买日期、分类和标签'**
  String get literal_7fb138c1;

  /// No description provided for @literal_4301739b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除心愿'**
  String get literal_4301739b;

  /// No description provided for @literal_44e32f6b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'价格会参与总价值和日均成本计算；购买日期支持自然语言输入和日期选择。'**
  String get literal_44e32f6b;

  /// No description provided for @literal_48016623.
  ///
  /// In zh_Hans, this message translates to:
  /// **'会删除当前资产、心愿、分类、标签和快照，保留一个完全空白的 App。'**
  String get literal_48016623;

  /// No description provided for @literal_c7f30bf2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'你提到的小字完整显示、首页副信息字号，就属于这一组。'**
  String get literal_c7f30bf2;

  /// No description provided for @literal_e6fc5cf2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用 Android 本地通知能力'**
  String get literal_e6fc5cf2;

  /// No description provided for @literal_8b9b967f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用 PROPFIND 检查 WebDAV 端点和账号'**
  String get literal_8b9b967f;

  /// No description provided for @literal_df9e7892.
  ///
  /// In zh_Hans, this message translates to:
  /// **'使用收益'**
  String get literal_df9e7892;

  /// No description provided for @literal_41c899e2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'例如 ¥ / \$ / RMB'**
  String get literal_41c899e2;

  /// No description provided for @literal_f3396b02.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存 JSON'**
  String get literal_f3396b02;

  /// No description provided for @literal_b43c4dd0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存云端设置'**
  String get literal_b43c4dd0;

  /// No description provided for @literal_f9297dfb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存分类'**
  String get literal_f9297dfb;

  /// No description provided for @literal_36925f12.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存后自动上传'**
  String get literal_36925f12;

  /// No description provided for @literal_95feda26.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存按钮：底部固定主操作'**
  String get literal_95feda26;

  /// No description provided for @literal_3d3e8771.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保存标签'**
  String get literal_3d3e8771;

  /// No description provided for @literal_43f8d0d6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'保留未选候选图'**
  String get literal_43f8d0d6;

  /// No description provided for @literal_81690cf5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'健康'**
  String get literal_81690cf5;

  /// No description provided for @literal_388fe0b5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'健康运动'**
  String get literal_388fe0b5;

  /// No description provided for @literal_7bbf64ef.
  ///
  /// In zh_Hans, this message translates to:
  /// **'充电'**
  String get literal_7bbf64ef;

  /// No description provided for @literal_54fc8a85.
  ///
  /// In zh_Hans, this message translates to:
  /// **'充电器'**
  String get literal_54fc8a85;

  /// No description provided for @literal_b9bd8857.
  ///
  /// In zh_Hans, this message translates to:
  /// **'先添加一个资产'**
  String get literal_b9bd8857;

  /// No description provided for @literal_5e6558ad.
  ///
  /// In zh_Hans, this message translates to:
  /// **'全部'**
  String get literal_5e6558ad;

  /// No description provided for @literal_3033b2b3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'公文包'**
  String get literal_3033b2b3;

  /// No description provided for @literal_038bccaf.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭后不再调用原生 Vibrator'**
  String get literal_038bccaf;

  /// No description provided for @literal_cf790321.
  ///
  /// In zh_Hans, this message translates to:
  /// **'关闭后自动删除未选贴纸候选，避免缓存积累'**
  String get literal_cf790321;

  /// No description provided for @literal_e6fcb5fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'其他云端入口'**
  String get literal_e6fcb5fd;

  /// No description provided for @literal_13d6ddba.
  ///
  /// In zh_Hans, this message translates to:
  /// **'冰箱'**
  String get literal_13d6ddba;

  /// No description provided for @literal_9c5707ef.
  ///
  /// In zh_Hans, this message translates to:
  /// **'净消耗 {value}'**
  String literal_9c5707ef({required Object value});

  /// No description provided for @literal_d3e735b3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'出行'**
  String get literal_d3e735b3;

  /// No description provided for @literal_941818fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'出行交通'**
  String get literal_941818fd;

  /// No description provided for @literal_3522e89c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享 JSON'**
  String get literal_3522e89c;

  /// No description provided for @literal_988ccecf.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分享完整资料包 ZIP'**
  String get literal_988ccecf;

  /// No description provided for @literal_29129df4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分摊 {value}'**
  String literal_29129df4({required Object value});

  /// No description provided for @literal_c4f6cb29.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析页会汇总资产总值、平均日耗、累计投入和心愿预算。'**
  String get literal_c4f6cb29;

  /// No description provided for @literal_0bc75aa9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析页：健康度与生命周期'**
  String get literal_0bc75aa9;

  /// No description provided for @literal_ec51e81f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分析页：核心指标'**
  String get literal_ec51e81f;

  /// No description provided for @literal_caf6d5a6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类'**
  String get literal_caf6d5a6;

  /// No description provided for @literal_ae974ad3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类名称'**
  String get literal_ae974ad3;

  /// No description provided for @literal_204aa9b7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类名称，例如 电子数码 / 学习办公 / 家居生活'**
  String get literal_204aa9b7;

  /// No description provided for @literal_e3338e59.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类建议按大类管理，例如电子数码、影音娱乐、学习办公，而不是为每个手机/电脑单独建类。'**
  String get literal_e3338e59;

  /// No description provided for @literal_69ac580e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'分类管理、备份恢复、新手教程等高频操作仍保留在设置首页。'**
  String get literal_69ac580e;

  /// No description provided for @literal_6a4aaca6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'切到心愿模式后，表单会变成心愿名称、预计价格、分类、标签、备注和封面。'**
  String get literal_6a4aaca6;

  /// No description provided for @literal_4d7fec99.
  ///
  /// In zh_Hans, this message translates to:
  /// **'创建并加入'**
  String get literal_4d7fec99;

  /// No description provided for @literal_8bdc2274.
  ///
  /// In zh_Hans, this message translates to:
  /// **'创建并选中'**
  String get literal_8bdc2274;

  /// No description provided for @literal_21e0f7a2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'创建快照'**
  String get literal_21e0f7a2;

  /// No description provided for @literal_ec2710da.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除分类'**
  String get literal_ec2710da;

  /// No description provided for @literal_1c4a443b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除快照'**
  String get literal_1c4a443b;

  /// No description provided for @literal_7777b464.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除标签'**
  String get literal_7777b464;

  /// No description provided for @literal_655ffba8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除资产'**
  String get literal_655ffba8;

  /// No description provided for @literal_5bca2c67.
  ///
  /// In zh_Hans, this message translates to:
  /// **'删除资产、心愿、分类、标签和快照'**
  String get literal_5bca2c67;

  /// No description provided for @literal_52218de3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期/保修节点'**
  String get literal_52218de3;

  /// No description provided for @literal_4a22dc96.
  ///
  /// In zh_Hans, this message translates to:
  /// **'到期提醒'**
  String get literal_4a22dc96;

  /// No description provided for @literal_0a22905f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'刷新桌面小组件'**
  String get literal_0a22905f;

  /// No description provided for @literal_bc0e4dd7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'办公'**
  String get literal_bc0e4dd7;

  /// No description provided for @literal_ccc769a0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'加号会根据当前页打开新增资产或新增心愿。教程下一步会进入真实新增页。'**
  String get literal_ccc769a0;

  /// No description provided for @literal_dba9caef.
  ///
  /// In zh_Hans, this message translates to:
  /// **'医药'**
  String get literal_dba9caef;

  /// No description provided for @literal_77244fbf.
  ///
  /// In zh_Hans, this message translates to:
  /// **'千位分隔'**
  String get literal_77244fbf;

  /// No description provided for @literal_d31ce9e2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'单车'**
  String get literal_d31ce9e2;

  /// No description provided for @literal_103ce3ba.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出价'**
  String get literal_103ce3ba;

  /// No description provided for @literal_f2d960a1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出日期'**
  String get literal_f2d960a1;

  /// No description provided for @literal_d7b59a73.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出日期 YYYY-MM-DD'**
  String get literal_d7b59a73;

  /// No description provided for @literal_718fb97e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卖出日期格式不正确'**
  String get literal_718fb97e;

  /// No description provided for @literal_e4594c2c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卡'**
  String get literal_e4594c2c;

  /// No description provided for @literal_b6d1f15a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'卡片、列表、便利贴'**
  String get literal_b6d1f15a;

  /// No description provided for @literal_5ae6651a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'原始天数：{days} 天'**
  String literal_5ae6651a({required Object days});

  /// No description provided for @literal_0a8ee878.
  ///
  /// In zh_Hans, this message translates to:
  /// **'参与资产'**
  String get literal_0a8ee878;

  /// No description provided for @literal_b94cd935.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可以输入任意 Emoji，例如 🧪 / 🏎️ / 🪴'**
  String get literal_b94cd935;

  /// No description provided for @literal_52eebe0e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可在目标里设置日期或天数'**
  String get literal_52eebe0e;

  /// No description provided for @literal_a4ae71ee.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可测试'**
  String get literal_a4ae71ee;

  /// No description provided for @literal_cadc6eda.
  ///
  /// In zh_Hans, this message translates to:
  /// **'可选择 WebDAV、坚果云、Nextcloud 或手动文件备份'**
  String get literal_cadc6eda;

  /// No description provided for @literal_b4cec766.
  ///
  /// In zh_Hans, this message translates to:
  /// **'吃灰'**
  String get literal_b4cec766;

  /// No description provided for @literal_160f32b2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'同步方式'**
  String get literal_160f32b2;

  /// No description provided for @literal_d0cb1513.
  ///
  /// In zh_Hans, this message translates to:
  /// **'同步方案'**
  String get literal_d0cb1513;

  /// No description provided for @literal_5cb6ce52.
  ///
  /// In zh_Hans, this message translates to:
  /// **'同步资产、心愿、日均和风险数据'**
  String get literal_5cb6ce52;

  /// No description provided for @literal_eed82646.
  ///
  /// In zh_Hans, this message translates to:
  /// **'后续可以继续把每张分析卡片拆成单独的首次进入引导。'**
  String get literal_eed82646;

  /// No description provided for @literal_80515905.
  ///
  /// In zh_Hans, this message translates to:
  /// **'后续详情页教程会继续使用这条真实资产数据。'**
  String get literal_80515905;

  /// No description provided for @literal_df340095.
  ///
  /// In zh_Hans, this message translates to:
  /// **'启动时尝试拉取'**
  String get literal_df340095;

  /// No description provided for @literal_b012e2d8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'咖啡'**
  String get literal_b012e2d8;

  /// No description provided for @literal_ac385798.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收 {value}'**
  String literal_ac385798({required Object value});

  /// No description provided for @literal_4dd361a1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'回收后日耗'**
  String get literal_4dd361a1;

  /// No description provided for @literal_0a7bc912.
  ///
  /// In zh_Hans, this message translates to:
  /// **'图标'**
  String get literal_0a7bc912;

  /// No description provided for @literal_f877a573.
  ///
  /// In zh_Hans, this message translates to:
  /// **'场景化返回动画'**
  String get literal_f877a573;

  /// No description provided for @literal_2834e28a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'备注'**
  String get literal_2834e28a;

  /// No description provided for @literal_04f14c48.
  ///
  /// In zh_Hans, this message translates to:
  /// **'复制 JSON'**
  String get literal_04f14c48;

  /// No description provided for @literal_2249efc6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'大'**
  String get literal_2249efc6;

  /// No description provided for @literal_2c49ff84.
  ///
  /// In zh_Hans, this message translates to:
  /// **'天'**
  String get literal_2c49ff84;

  /// No description provided for @literal_a20a8572.
  ///
  /// In zh_Hans, this message translates to:
  /// **'奖杯'**
  String get literal_a20a8572;

  /// No description provided for @literal_8467a032.
  ///
  /// In zh_Hans, this message translates to:
  /// **'如果当前还没有资产，教程会指向真实空状态，引导用户从底部加号开始添加。'**
  String get literal_8467a032;

  /// No description provided for @literal_a3a548a4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'娱乐'**
  String get literal_a3a548a4;

  /// No description provided for @literal_cb323bfb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学习'**
  String get literal_cb323bfb;

  /// No description provided for @literal_c2638f69.
  ///
  /// In zh_Hans, this message translates to:
  /// **'学习办公'**
  String get literal_c2638f69;

  /// No description provided for @literal_47337f59.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完成教程'**
  String get literal_47337f59;

  /// No description provided for @literal_159896e6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'完整 ZIP、JSON、快照、CSV 和 Markdown'**
  String get literal_159896e6;

  /// No description provided for @literal_3b1ad2a1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'宝石'**
  String get literal_3b1ad2a1;

  /// No description provided for @literal_46fe03b7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'实验'**
  String get literal_46fe03b7;

  /// No description provided for @literal_ccda7222.
  ///
  /// In zh_Hans, this message translates to:
  /// **'宠物'**
  String get literal_ccda7222;

  /// No description provided for @literal_8d0158a4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家居'**
  String get literal_8d0158a4;

  /// No description provided for @literal_7b113dae.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家居生活'**
  String get literal_7b113dae;

  /// No description provided for @literal_7cc0b474.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家电'**
  String get literal_7cc0b474;

  /// No description provided for @literal_bef9c85a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'家具'**
  String get literal_bef9c85a;

  /// No description provided for @literal_81bbce49.
  ///
  /// In zh_Hans, this message translates to:
  /// **'密码 / 应用专用密码'**
  String get literal_81bbce49;

  /// No description provided for @literal_4a3a9b17.
  ///
  /// In zh_Hans, this message translates to:
  /// **'导出到任意网盘同步文件夹，或从系统文件恢复'**
  String get literal_4a3a9b17;

  /// No description provided for @literal_b6adfc3f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'封面、条码、小票 OCR 与贴纸'**
  String get literal_b6adfc3f;

  /// No description provided for @literal_0a4510fe.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小'**
  String get literal_0a4510fe;

  /// No description provided for @literal_4245191e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'小组件、权限、通知、原生接口和同步'**
  String get literal_4245191e;

  /// No description provided for @literal_9f1d3d35.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具'**
  String get literal_9f1d3d35;

  /// No description provided for @literal_ff1601cc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具箱'**
  String get literal_ff1601cc;

  /// No description provided for @literal_cd2f0507.
  ///
  /// In zh_Hans, this message translates to:
  /// **'工具维修'**
  String get literal_cd2f0507;

  /// No description provided for @literal_81d83a72.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已刷新所有桌面小组件'**
  String get literal_81d83a72;

  /// No description provided for @literal_decf2b28.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已回收 {value}'**
  String literal_decf2b28({required Object value});

  /// No description provided for @literal_bbb87cb6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已导出到系统文件'**
  String get literal_bbb87cb6;

  /// No description provided for @literal_b8402f89.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已应用推荐大类，并迁移手机/电脑等旧小类'**
  String get literal_b8402f89;

  /// No description provided for @literal_5f2bd67f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已恢复为服役中'**
  String get literal_5f2bd67f;

  /// No description provided for @literal_efbf2b9a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已恢复快照'**
  String get literal_efbf2b9a;

  /// No description provided for @literal_f012ae47.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已恢复记录'**
  String get literal_f012ae47;

  /// No description provided for @literal_cf58e981.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已按页面类型区分详情/编辑/设置/弹层/分析的过渡动画和边缘返回反馈'**
  String get literal_cf58e981;

  /// No description provided for @literal_d565489c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已暂停记录'**
  String get literal_d565489c;

  /// No description provided for @literal_63c21d57.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有分类'**
  String get literal_63c21d57;

  /// No description provided for @literal_bde90835.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已有标签'**
  String get literal_bde90835;

  /// No description provided for @literal_4ced5f43.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已标记为退役'**
  String get literal_4ced5f43;

  /// No description provided for @literal_f4c094fe.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已经达到记录周期'**
  String get literal_f4c094fe;

  /// No description provided for @literal_e56b1859.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已记录价值回收收益'**
  String get literal_e56b1859;

  /// No description provided for @literal_a8bbc160.
  ///
  /// In zh_Hans, this message translates to:
  /// **'已记录卖出，资产复盘已更新'**
  String get literal_a8bbc160;

  /// No description provided for @literal_b109de47.
  ///
  /// In zh_Hans, this message translates to:
  /// **'平板'**
  String get literal_b109de47;

  /// No description provided for @literal_8f47755d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'床'**
  String get literal_8f47755d;

  /// No description provided for @literal_8a3c61a0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'应用推荐分类体系'**
  String get literal_8a3c61a0;

  /// No description provided for @literal_d690baf8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'底部 Dock：四个一级页面'**
  String get literal_d690baf8;

  /// No description provided for @literal_46ec4d37.
  ///
  /// In zh_Hans, this message translates to:
  /// **'底部加号：新增资产 / 心愿'**
  String get literal_46ec4d37;

  /// No description provided for @literal_14993974.
  ///
  /// In zh_Hans, this message translates to:
  /// **'建议使用电子数码、学习办公等大类'**
  String get literal_14993974;

  /// No description provided for @literal_bf32aebd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前'**
  String get literal_bf32aebd;

  /// No description provided for @literal_5f36fb4d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前日耗'**
  String get literal_5f36fb4d;

  /// No description provided for @literal_8fbd2675.
  ///
  /// In zh_Hans, this message translates to:
  /// **'当前显示：{duration}'**
  String literal_8fbd2675({required Object duration});

  /// No description provided for @literal_8718be1e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影像创作'**
  String get literal_8718be1e;

  /// No description provided for @literal_3955b57d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影音'**
  String get literal_3955b57d;

  /// No description provided for @literal_ef500e1c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'影音娱乐'**
  String get literal_ef500e1c;

  /// No description provided for @literal_adb4b003.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿不是简单列表，也有归档、转资产和预算统计，所以教程单独覆盖。'**
  String get literal_adb4b003;

  /// No description provided for @literal_9dee0c2e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿封面与贴纸入口'**
  String get literal_9dee0c2e;

  /// No description provided for @literal_c43e33fe.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿模式也可以选择封面、裁切白框、手动勾勒或生成 AI 贴纸。'**
  String get literal_c43e33fe;

  /// No description provided for @literal_90ef2d5d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿页会统计未归档心愿的总预算，也可以从心愿转为资产。'**
  String get literal_90ef2d5d;

  /// No description provided for @literal_4e223e0f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'心愿页：预算和待购清单'**
  String get literal_4e223e0f;

  /// No description provided for @literal_50d7345a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快捷流转'**
  String get literal_50d7345a;

  /// No description provided for @literal_a4fe2177.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照'**
  String get literal_a4fe2177;

  /// No description provided for @literal_e6c3b1da.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照名称'**
  String get literal_e6c3b1da;

  /// No description provided for @literal_0b9c2915.
  ///
  /// In zh_Hans, this message translates to:
  /// **'快照损坏'**
  String get literal_0b9c2915;

  /// No description provided for @literal_491963fe.
  ///
  /// In zh_Hans, this message translates to:
  /// **'怎么看日均成本趋势'**
  String get literal_491963fe;

  /// No description provided for @literal_b2340328.
  ///
  /// In zh_Hans, this message translates to:
  /// **'总投入'**
  String get literal_b2340328;

  /// No description provided for @literal_86db27ca.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复快照'**
  String get literal_86db27ca;

  /// No description provided for @literal_03350925.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复成功'**
  String get literal_03350925;

  /// No description provided for @literal_2fbac8a2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复服役'**
  String get literal_2fbac8a2;

  /// No description provided for @literal_a44bf237.
  ///
  /// In zh_Hans, this message translates to:
  /// **'恢复记录'**
  String get literal_a44bf237;

  /// No description provided for @literal_78ab5cd9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'成本'**
  String get literal_78ab5cd9;

  /// No description provided for @literal_adad0776.
  ///
  /// In zh_Hans, this message translates to:
  /// **'戒指'**
  String get literal_adad0776;

  /// No description provided for @literal_7d73e88b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'房产'**
  String get literal_7d73e88b;

  /// No description provided for @literal_e67d0c99.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手动勾勒：自己圈出主体'**
  String get literal_e67d0c99;

  /// No description provided for @literal_ff96c610.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手机'**
  String get literal_ff96c610;

  /// No description provided for @literal_3287efc6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'手表'**
  String get literal_3287efc6;

  /// No description provided for @literal_ae47f280.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打包 SQLite、JSON、CSV、报告和封面/贴纸图片'**
  String get literal_ae47f280;

  /// No description provided for @literal_58ce465b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打包 SQLite、JSON、报告和封面/贴纸图片'**
  String get literal_58ce465b;

  /// No description provided for @literal_81d0cd44.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打印机'**
  String get literal_81d0cd44;

  /// No description provided for @literal_5d50f542.
  ///
  /// In zh_Hans, this message translates to:
  /// **'打开 App 后自动读取云端备份；建议单设备使用时关闭'**
  String get literal_5d50f542;

  /// No description provided for @literal_bfd72eea.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把当前 JSON 备份写入云端路径'**
  String get literal_bfd72eea;

  /// No description provided for @literal_bcb41723.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把当前数据保存到已配置云端'**
  String get literal_bcb41723;

  /// No description provided for @literal_24fdb999.
  ///
  /// In zh_Hans, this message translates to:
  /// **'把资产从“服役—退役—卖出”串成闭环，日耗和复盘会自动更新。'**
  String get literal_24fdb999;

  /// No description provided for @literal_d5651c5f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有'**
  String get literal_d5651c5f;

  /// No description provided for @literal_f8972019.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有 {duration}'**
  String literal_f8972019({required Object duration});

  /// No description provided for @literal_bc90e74f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'持有时间说明'**
  String get literal_bc90e74f;

  /// No description provided for @literal_22fb9bcb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'按钮位置也由真实 GlassAddButton 注册，不再手算。'**
  String get literal_22fb9bcb;

  /// No description provided for @literal_7e70fa03.
  ///
  /// In zh_Hans, this message translates to:
  /// **'掌机'**
  String get literal_7e70fa03;

  /// No description provided for @literal_c9532e7a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'控制 App 内点击、保存、切换等轻触感反馈'**
  String get literal_c9532e7a;

  /// No description provided for @literal_09ea8ae6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'推荐使用完整资料包 ZIP 迁移；JSON 只包含文字数据，不包含封面/贴纸图片。'**
  String get literal_09ea8ae6;

  /// No description provided for @literal_508662f6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提前 {days} 天提醒'**
  String literal_508662f6({required Object days});

  /// No description provided for @literal_76c5f0ec.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提示条会上移并带关闭按钮，避免挡住底部操作'**
  String get literal_76c5f0ec;

  /// No description provided for @literal_98b7d4d3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'提示：坚果云通常要使用“应用密码”；Nextcloud 地址一般类似 /remote.php/dav/files/用户名/。当前版本会把配置保存在本机 JSON 中，正式发布前建议再接入 Android Keystore 加密。'**
  String get literal_98b7d4d3;

  /// No description provided for @literal_4ce8a604.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收益名称'**
  String get literal_4ce8a604;

  /// No description provided for @literal_d98ba4d1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收益日期'**
  String get literal_d98ba4d1;

  /// No description provided for @literal_6bec98ae.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收益日期格式不正确'**
  String get literal_6bec98ae;

  /// No description provided for @literal_361c107f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收益金额'**
  String get literal_361c107f;

  /// No description provided for @literal_839d4732.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收藏'**
  String get literal_839d4732;

  /// No description provided for @literal_6195d887.
  ///
  /// In zh_Hans, this message translates to:
  /// **'收藏纪念'**
  String get literal_6195d887;

  /// No description provided for @literal_e8fcd2b0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'教程没有复制一个假表单，而是直接把新增页放到背景里。'**
  String get literal_e8fcd2b0;

  /// No description provided for @literal_40e319ff.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数据与备份、外观与交互、系统与权限被收束成三个二级菜单，避免一层堆满开关。'**
  String get literal_40e319ff;

  /// No description provided for @literal_928f2aaa.
  ///
  /// In zh_Hans, this message translates to:
  /// **'数码'**
  String get literal_928f2aaa;

  /// No description provided for @literal_f09b77d0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新分类'**
  String get literal_f09b77d0;

  /// No description provided for @literal_bcb2958c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增分类'**
  String get literal_bcb2958c;

  /// No description provided for @literal_270d6f3b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增心愿：同一张真实新增页'**
  String get literal_270d6f3b;

  /// No description provided for @literal_819b0e16.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增标签'**
  String get literal_819b0e16;

  /// No description provided for @literal_88eaee48.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增页的保存按钮固定在底部，方便单手操作。'**
  String get literal_88eaee48;

  /// No description provided for @literal_0c23925b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新增页：资产 / 心愿切换'**
  String get literal_0c23925b;

  /// No description provided for @literal_8bebe9f2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'新标签'**
  String get literal_8bebe9f2;

  /// No description provided for @literal_ffcf17a4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'旅行'**
  String get literal_ffcf17a4;

  /// No description provided for @literal_1e1554ff.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无人机'**
  String get literal_1e1554ff;

  /// No description provided for @literal_313c43f8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无价之宝用于记录对自己有价值的时间节点，不参与卖出和日耗复盘。'**
  String get literal_313c43f8;

  /// No description provided for @literal_1b3beba9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'无千位分隔'**
  String get literal_1b3beba9;

  /// No description provided for @literal_3ab0f465.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日均'**
  String get literal_3ab0f465;

  /// No description provided for @literal_92fd0eed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日期'**
  String get literal_92fd0eed;

  /// No description provided for @literal_8997a955.
  ///
  /// In zh_Hans, this message translates to:
  /// **'日耗'**
  String get literal_8997a955;

  /// No description provided for @literal_31b52c02.
  ///
  /// In zh_Hans, this message translates to:
  /// **'时长'**
  String get literal_31b52c02;

  /// No description provided for @literal_2e486bcb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'显示器'**
  String get literal_2e486bcb;

  /// No description provided for @literal_bea6ed35.
  ///
  /// In zh_Hans, this message translates to:
  /// **'显示预览'**
  String get literal_bea6ed35;

  /// No description provided for @literal_f1c89aac.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂停记录'**
  String get literal_f1c89aac;

  /// No description provided for @literal_a1a7c978.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无可参与价值回收的普通资产'**
  String get literal_a1a7c978;

  /// No description provided for @literal_9670e5e6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'暂无备注。'**
  String get literal_9670e5e6;

  /// No description provided for @literal_e2172be9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服务器'**
  String get literal_e2172be9;

  /// No description provided for @literal_5d59d2c1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'服务器地址'**
  String get literal_5d59d2c1;

  /// No description provided for @literal_edba8b5a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未启用'**
  String get literal_edba8b5a;

  /// No description provided for @literal_a7d9bc76.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未设目标'**
  String get literal_a7d9bc76;

  /// No description provided for @literal_55d26628.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未设置周期'**
  String get literal_55d26628;

  /// No description provided for @literal_69dd0a4a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'未设置购买时间'**
  String get literal_69dd0a4a;

  /// No description provided for @literal_8f37b229.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本地贴纸模式'**
  String get literal_8f37b229;

  /// No description provided for @literal_995581ed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机快照'**
  String get literal_995581ed;

  /// No description provided for @literal_bd18bd67.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机快照 {date}'**
  String literal_bd18bd67({required Object date});

  /// No description provided for @literal_58575585.
  ///
  /// In zh_Hans, this message translates to:
  /// **'本机数据'**
  String get literal_58575585;

  /// No description provided for @literal_4d32d07e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'权限与系统设置'**
  String get literal_4d32d07e;

  /// No description provided for @literal_b3399ee0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标准'**
  String get literal_b3399ee0;

  /// No description provided for @literal_2b1626c8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签'**
  String get literal_2b1626c8;

  /// No description provided for @literal_52b2c73d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签名称'**
  String get literal_52b2c73d;

  /// No description provided for @literal_4dca2c85.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签名称，例如 通勤 / 收藏 / 办公'**
  String get literal_4dca2c85;

  /// No description provided for @literal_1c4793d5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签名称，例如 通勤 / 收藏 / 维修'**
  String get literal_1c4793d5;

  /// No description provided for @literal_8337eb1d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标签适合描述场景，例如通勤、收藏、办公、长期持有。现在可以直接选颜色。'**
  String get literal_8337eb1d;

  /// No description provided for @literal_88e767ad.
  ///
  /// In zh_Hans, this message translates to:
  /// **'标记退役'**
  String get literal_88e767ad;

  /// No description provided for @literal_faa9dc30.
  ///
  /// In zh_Hans, this message translates to:
  /// **'椅子'**
  String get literal_faa9dc30;

  /// No description provided for @literal_9ca8910b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'正在连接云端…'**
  String get literal_9ca8910b;

  /// No description provided for @literal_18c2954a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'汽车'**
  String get literal_18c2954a;

  /// No description provided for @literal_7b18e7df.
  ///
  /// In zh_Hans, this message translates to:
  /// **'沙发'**
  String get literal_7b18e7df;

  /// No description provided for @literal_2d0457af.
  ///
  /// In zh_Hans, this message translates to:
  /// **'洗衣'**
  String get literal_2d0457af;

  /// No description provided for @literal_ba1a8fe4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'测试连接'**
  String get literal_ba1a8fe4;

  /// No description provided for @literal_5f1599bb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'添加第一个资产后，首页卡片和详情页会自动变成可讲解的真实内容。'**
  String get literal_5f1599bb;

  /// No description provided for @literal_29c09453.
  ///
  /// In zh_Hans, this message translates to:
  /// **'清洁'**
  String get literal_29c09453;

  /// No description provided for @literal_38b4a058.
  ///
  /// In zh_Hans, this message translates to:
  /// **'游戏'**
  String get literal_38b4a058;

  /// No description provided for @literal_89b0aaa5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'游戏兴趣'**
  String get literal_89b0aaa5;

  /// No description provided for @literal_a695df46.
  ///
  /// In zh_Hans, this message translates to:
  /// **'游戏机'**
  String get literal_a695df46;

  /// No description provided for @literal_b8388622.
  ///
  /// In zh_Hans, this message translates to:
  /// **'滑雪'**
  String get literal_b8388622;

  /// No description provided for @literal_20f477cb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'灯具'**
  String get literal_20f477cb;

  /// No description provided for @literal_07d9bf51.
  ///
  /// In zh_Hans, this message translates to:
  /// **'点击核心指标可以进入更细的统计解释。'**
  String get literal_07d9bf51;

  /// No description provided for @literal_11d99409.
  ///
  /// In zh_Hans, this message translates to:
  /// **'玩具'**
  String get literal_11d99409;

  /// No description provided for @literal_4fdc71e4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'现在 {value}/天'**
  String literal_4fdc71e4({required Object value});

  /// No description provided for @literal_0742ea92.
  ///
  /// In zh_Hans, this message translates to:
  /// **'现在高亮的是“裁切白框”真实按钮，不再只笼统指向整条导入栏。'**
  String get literal_0742ea92;

  /// No description provided for @literal_599c06e1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'理解方式：实线表示已经发生的摊薄，虚线会按目标日耗/目标天数推算未来趋势。横向绿色虚线是目标日耗，蓝线到达它时说明这件物品已经达到你设定的心理成本。'**
  String get literal_599c06e1;

  /// No description provided for @literal_d109e70f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'生活'**
  String get literal_d109e70f;

  /// No description provided for @literal_2898f9c2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'用户完成录入后，从这里保存为真实资产或心愿。'**
  String get literal_2898f9c2;

  /// No description provided for @literal_1612c6a8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电器'**
  String get literal_1612c6a8;

  /// No description provided for @literal_de172780.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电子'**
  String get literal_de172780;

  /// No description provided for @literal_53f8ae03.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电子数码'**
  String get literal_53f8ae03;

  /// No description provided for @literal_0e02fc10.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电池'**
  String get literal_0e02fc10;

  /// No description provided for @literal_1df2bfd3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电脑'**
  String get literal_1df2bfd3;

  /// No description provided for @literal_72fe4aa2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'电视'**
  String get literal_72fe4aa2;

  /// No description provided for @literal_fa83f282.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标'**
  String get literal_fa83f282;

  /// No description provided for @literal_5b94da74.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标 {days} 天'**
  String literal_5b94da74({required Object days});

  /// No description provided for @literal_2714bd1a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'目标 {days}天'**
  String literal_2714bd1a({required Object days});

  /// No description provided for @literal_0b945f39.
  ///
  /// In zh_Hans, this message translates to:
  /// **'直接点选图标和颜色，不需要手动输入十六进制色值。'**
  String get literal_0b945f39;

  /// No description provided for @literal_4dfbe4be.
  ///
  /// In zh_Hans, this message translates to:
  /// **'直接选图标'**
  String get literal_4dfbe4be;

  /// No description provided for @literal_199fa72a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'直接选择颜色即可。'**
  String get literal_199fa72a;

  /// No description provided for @literal_f9c724af.
  ///
  /// In zh_Hans, this message translates to:
  /// **'直接选颜色'**
  String get literal_f9c724af;

  /// No description provided for @literal_24f2dad1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'相册'**
  String get literal_24f2dad1;

  /// No description provided for @literal_d7476207.
  ///
  /// In zh_Hans, this message translates to:
  /// **'相机'**
  String get literal_d7476207;

  /// No description provided for @literal_341056e5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'眼镜'**
  String get literal_341056e5;

  /// No description provided for @literal_96547fdd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'知道了'**
  String get literal_96547fdd;

  /// No description provided for @literal_9b1984be.
  ///
  /// In zh_Hans, this message translates to:
  /// **'硬币'**
  String get literal_9b1984be;

  /// No description provided for @literal_c3669714.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确定删除「{label}」吗？这个操作不会影响当前资产数据。'**
  String literal_c3669714({required Object label});

  /// No description provided for @literal_3624e131.
  ///
  /// In zh_Hans, this message translates to:
  /// **'确认删除「{name}」吗？'**
  String literal_3624e131({required Object name});

  /// No description provided for @literal_60185374.
  ///
  /// In zh_Hans, this message translates to:
  /// **'示例心愿'**
  String get literal_60185374;

  /// No description provided for @literal_b837e61f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'示例资产'**
  String get literal_b837e61f;

  /// No description provided for @literal_103678d6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'礼物'**
  String get literal_103678d6;

  /// No description provided for @literal_48b398bd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'票券'**
  String get literal_48b398bd;

  /// No description provided for @literal_129ba6bb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'票据'**
  String get literal_129ba6bb;

  /// No description provided for @literal_3b91bc59.
  ///
  /// In zh_Hans, this message translates to:
  /// **'穿搭'**
  String get literal_3b91bc59;

  /// No description provided for @literal_7f59cfe4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'穿搭配饰'**
  String get literal_7f59cfe4;

  /// No description provided for @literal_46931565.
  ///
  /// In zh_Hans, this message translates to:
  /// **'立即上传备份'**
  String get literal_46931565;

  /// No description provided for @literal_9046d986.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 1 天 {value}/天'**
  String literal_9046d986({required Object value});

  /// No description provided for @literal_e0621067.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 1 天日耗'**
  String get literal_e0621067;

  /// No description provided for @literal_b8cb54b3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第 {index} / {total} 步'**
  String literal_b8cb54b3({required Object index, required Object total});

  /// No description provided for @literal_686e7671.
  ///
  /// In zh_Hans, this message translates to:
  /// **'第一张真实资产卡片会展示名称、状态、总价值、已使用天数和日均成本。'**
  String get literal_686e7671;

  /// No description provided for @literal_172c3600.
  ///
  /// In zh_Hans, this message translates to:
  /// **'筛选、排序和首页视图'**
  String get literal_172c3600;

  /// No description provided for @literal_e98f0b36.
  ///
  /// In zh_Hans, this message translates to:
  /// **'篮球'**
  String get literal_e98f0b36;

  /// No description provided for @literal_f8741818.
  ///
  /// In zh_Hans, this message translates to:
  /// **'粘贴 JSON 后覆盖恢复（不含图片）'**
  String get literal_f8741818;

  /// No description provided for @literal_0eda4c71.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统与返回'**
  String get literal_0eda4c71;

  /// No description provided for @literal_950b162e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'系统文件备份'**
  String get literal_950b162e;

  /// No description provided for @literal_57433a35.
  ///
  /// In zh_Hans, this message translates to:
  /// **'紧凑'**
  String get literal_57433a35;

  /// No description provided for @literal_cb19b6da.
  ///
  /// In zh_Hans, this message translates to:
  /// **'紧凑提示条'**
  String get literal_cb19b6da;

  /// No description provided for @literal_bdaf4bc2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'纸箱'**
  String get literal_bdaf4bc2;

  /// No description provided for @literal_030d956c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'细分通勤、收藏、维修、吃灰等状态'**
  String get literal_030d956c;

  /// No description provided for @literal_70f57871.
  ///
  /// In zh_Hans, this message translates to:
  /// **'继续'**
  String get literal_70f57871;

  /// No description provided for @literal_6feb0db7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'维修'**
  String get literal_6feb0db7;

  /// No description provided for @literal_10d75079.
  ///
  /// In zh_Hans, this message translates to:
  /// **'绿植'**
  String get literal_10d75079;

  /// No description provided for @literal_19851d43.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑分类'**
  String get literal_19851d43;

  /// No description provided for @literal_2d809cb9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'编辑标签'**
  String get literal_2d809cb9;

  /// No description provided for @literal_ec5b500d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'罐子'**
  String get literal_ec5b500d;

  /// No description provided for @literal_2587ecb5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'美妆'**
  String get literal_2587ecb5;

  /// No description provided for @literal_50f2f3e8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'耳机'**
  String get literal_50f2f3e8;

  /// No description provided for @literal_edbd5a6a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'背包'**
  String get literal_edbd5a6a;

  /// No description provided for @literal_7ebc7488.
  ///
  /// In zh_Hans, this message translates to:
  /// **'自定义图标 / Emoji'**
  String get literal_7ebc7488;

  /// No description provided for @literal_7471031c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'至少选择一件资产'**
  String get literal_7471031c;

  /// No description provided for @literal_c99886a6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'艺术'**
  String get literal_c99886a6;

  /// No description provided for @literal_207c5ada.
  ///
  /// In zh_Hans, this message translates to:
  /// **'茶具'**
  String get literal_207c5ada;

  /// No description provided for @literal_ede2444a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'行李箱'**
  String get literal_ede2444a;

  /// No description provided for @literal_33b79e8d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'衣服'**
  String get literal_33b79e8d;

  /// No description provided for @literal_db9965cd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'裁切白框：快速生成统一封面'**
  String get literal_db9965cd;

  /// No description provided for @literal_568bd540.
  ///
  /// In zh_Hans, this message translates to:
  /// **'覆盖恢复'**
  String get literal_568bd540;

  /// No description provided for @literal_7d6da53f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'触感反馈'**
  String get literal_7d6da53f;

  /// No description provided for @literal_25b2efb5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'计算方式：从记录日期到当前日期或退役日期，按包含首尾日期的方式统计。你可以在“设置 - 外观交互 - 时长显示”里切换天、周、月或年/月显示。'**
  String get literal_25b2efb5;

  /// No description provided for @literal_bf161b26.
  ///
  /// In zh_Hans, this message translates to:
  /// **'计算方式：从购买日期到当前日期、退役日期或卖出日期，按包含首尾日期的方式统计。你可以在“设置 - 外观交互 - 时长显示”里切换天、周、月或年/月显示。'**
  String get literal_bf161b26;

  /// No description provided for @literal_2c9d9f0e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录'**
  String get literal_2c9d9f0e;

  /// No description provided for @literal_7ab0cc95.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录价值回收'**
  String get literal_7ab0cc95;

  /// No description provided for @literal_134a2076.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录卖出'**
  String get literal_134a2076;

  /// No description provided for @literal_22ca3769.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录卖出：{name}'**
  String literal_22ca3769({required Object name});

  /// No description provided for @literal_93f413c6.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录收益'**
  String get literal_93f413c6;

  /// No description provided for @literal_013aca6a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录时间说明'**
  String get literal_013aca6a;

  /// No description provided for @literal_bcb2920b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'记录状态'**
  String get literal_bcb2920b;

  /// No description provided for @literal_824c2490.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置项小字会完整折行，不再强行省略。'**
  String get literal_824c2490;

  /// No description provided for @literal_397f6678.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置首页：二级菜单入口'**
  String get literal_397f6678;

  /// No description provided for @literal_8779dd3a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'设置首页：快速入口和教程重播'**
  String get literal_8779dd3a;

  /// No description provided for @literal_dbb69887.
  ///
  /// In zh_Hans, this message translates to:
  /// **'详情、编辑、设置、弹层、分析页采用不同入场和返回手势反馈'**
  String get literal_dbb69887;

  /// No description provided for @literal_240f4ff2.
  ///
  /// In zh_Hans, this message translates to:
  /// **'详情页顶部展示资产图标、分类、状态、当前总价值、持有时间和日均成本。'**
  String get literal_240f4ff2;

  /// No description provided for @literal_3b650cd0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'详情页：快捷流转'**
  String get literal_3b650cd0;

  /// No description provided for @literal_f389d06d.
  ///
  /// In zh_Hans, this message translates to:
  /// **'详情页：日均成本趋势'**
  String get literal_f389d06d;

  /// No description provided for @literal_f637cc04.
  ///
  /// In zh_Hans, this message translates to:
  /// **'详情页：资产概览'**
  String get literal_f637cc04;

  /// No description provided for @literal_9b618ee5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'请输入大于 0 的收益金额'**
  String get literal_9b618ee5;

  /// No description provided for @literal_86f3c9ec.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取云端 JSON，并覆盖当前本机数据'**
  String get literal_86f3c9ec;

  /// No description provided for @literal_81c08980.
  ///
  /// In zh_Hans, this message translates to:
  /// **'读取云端备份并覆盖本地数据'**
  String get literal_81c08980;

  /// No description provided for @literal_1f5de0e3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'账号 / 用户名'**
  String get literal_1f5de0e3;

  /// No description provided for @literal_959e9898.
  ///
  /// In zh_Hans, this message translates to:
  /// **'质感'**
  String get literal_959e9898;

  /// No description provided for @literal_d22ee500.
  ///
  /// In zh_Hans, this message translates to:
  /// **'购买时间：{date}'**
  String literal_d22ee500({required Object date});

  /// No description provided for @literal_25fba002.
  ///
  /// In zh_Hans, this message translates to:
  /// **'贴纸与封面'**
  String get literal_25fba002;

  /// No description provided for @literal_0cf0db30.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产、心愿、分析、设置都从这里切换，Dock 的滑动和震动反馈也在真实组件里完成。'**
  String get literal_0cf0db30;

  /// No description provided for @literal_218f1c82.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产与心愿记录保存在当前设备，备份后可随时恢复。'**
  String get literal_218f1c82;

  /// No description provided for @literal_0fd9587f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产列表：空状态也是真实界面'**
  String get literal_0fd9587f;

  /// No description provided for @literal_65f702db.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产卡片：点击进入详情'**
  String get literal_65f702db;

  /// No description provided for @literal_e19717b4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产可以在服役、退役、卖出之间流转，复盘、净值和日耗会跟着更新。'**
  String get literal_e19717b4;

  /// No description provided for @literal_861be9fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产新增页的导入栏支持选封面、裁切白框、手动勾勒、AI 贴纸、扫条码和小票 OCR。'**
  String get literal_861be9fd;

  /// No description provided for @literal_6eaca1b3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'资产时间线'**
  String get literal_6eaca1b3;

  /// No description provided for @literal_8c569a8b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'趋势图会显示已发生摊薄和目标日耗预测，适合判断一件东西是否已经用值。'**
  String get literal_8c569a8b;

  /// No description provided for @literal_307de938.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跟随父资产：{date}'**
  String literal_307de938({required Object date});

  /// No description provided for @literal_38ecb28f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'路由器'**
  String get literal_38ecb28f;

  /// No description provided for @literal_3ae7f41f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'跳过'**
  String get literal_3ae7f41f;

  /// No description provided for @literal_806da0b8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'软件'**
  String get literal_806da0b8;

  /// No description provided for @literal_ca53c3ca.
  ///
  /// In zh_Hans, this message translates to:
  /// **'软件服务'**
  String get literal_ca53c3ca;

  /// No description provided for @literal_ccdc45a3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'达成'**
  String get literal_ccdc45a3;

  /// No description provided for @literal_2ecb45e5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'运动'**
  String get literal_2ecb45e5;

  /// No description provided for @literal_9a237a9b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'还差 {days} 天'**
  String literal_9a237a9b({required Object days});

  /// No description provided for @literal_80e65da8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'还没有分类。'**
  String get literal_80e65da8;

  /// No description provided for @literal_04fb245c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'还没有快照。创建后可以在这里恢复、重命名或删除。'**
  String get literal_04fb245c;

  /// No description provided for @literal_e5118f32.
  ///
  /// In zh_Hans, this message translates to:
  /// **'还没有标签。'**
  String get literal_e5118f32;

  /// No description provided for @literal_2bd5ea5f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步不再使用估算坐标，而是绑定真实 AssetOverviewCard 的位置。'**
  String get literal_2bd5ea5f;

  /// No description provided for @literal_a8f5d1f9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步仍然绑定真实 CoverImportBar。'**
  String get literal_a8f5d1f9;

  /// No description provided for @literal_60303365.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步指向 AssetLifecycleQuickActions 的真实位置。'**
  String get literal_60303365;

  /// No description provided for @literal_903b7eb7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步指向真实 SmartAssetImportBar，后续你扩展按钮时教程也能跟着组件位置走。'**
  String get literal_903b7eb7;

  /// No description provided for @literal_18aa6e99.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步绑定“AI 贴纸”入口，用户能明确知道它和选封面、裁切白框、手动勾勒的区别。'**
  String get literal_18aa6e99;

  /// No description provided for @literal_5496b9ba.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这一步绑定“手动勾勒”按钮，并说明它不是普通裁剪，而是按路径生成主体轮廓。'**
  String get literal_5496b9ba;

  /// No description provided for @literal_34e92bdc.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这不是只展示一级页面，而是开始说明每个模块内部的功能块。'**
  String get literal_34e92bdc;

  /// No description provided for @literal_c5791e47.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这会用云端备份覆盖当前本机数据。建议先导出一份本机 JSON。'**
  String get literal_c5791e47;

  /// No description provided for @literal_dd5832d4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这就是你之前强调的“附加项目不是只记录，而是要参与资产价值计算”。'**
  String get literal_dd5832d4;

  /// No description provided for @literal_1c820fc5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这张图不是涨跌行情，而是“买入成本被使用天数摊薄”的过程。'**
  String get literal_1c820fc5;

  /// No description provided for @literal_77d9c13a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这类“页面内部功能”不应该被省略，所以现在也纳入教程链路。'**
  String get literal_77d9c13a;

  /// No description provided for @literal_222f7be9.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这类信息是后续分析页、详情页、日耗目标和资产复盘的基础。'**
  String get literal_222f7be9;

  /// No description provided for @literal_747b10d5.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里会基于目标、标签、闲置、二手流转等生成资产健康度和生命周期账本。'**
  String get literal_747b10d5;

  /// No description provided for @literal_66b0df6e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里使用你的第一条真实资产数据，不再用一张教程卡片代替详情页。'**
  String get literal_66b0df6e;

  /// No description provided for @literal_f0bb1ced.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里可以切换服役 / 退役 / 卖出，也可以进入排序、筛选和首页展示方式。'**
  String get literal_f0bb1ced;

  /// No description provided for @literal_c6ac8111.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里是 ComposePage 的真实分段入口，可以在新增资产和新增心愿之间切换。'**
  String get literal_c6ac8111;

  /// No description provided for @literal_3816dd3c.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里管理 Android 原生能力、权限、通知、小组件、系统设置和云端快捷操作。'**
  String get literal_3816dd3c;

  /// No description provided for @literal_17d3fcba.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里管理分类、标签、备份恢复、云端同步和完整资料包导出。'**
  String get literal_17d3fcba;

  /// No description provided for @literal_c3aa9545.
  ///
  /// In zh_Hans, this message translates to:
  /// **'这里高亮的是 LiquidDock 本体，不是教程页临时画出来的导航栏。'**
  String get literal_c3aa9545;

  /// No description provided for @literal_e16c8d7e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'退役日期'**
  String get literal_e16c8d7e;

  /// No description provided for @literal_41602535.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合商品图、票据图或背景比较干净的照片。用户裁好主体区域后，系统会生成统一白框封面，让首页卡片更整齐。'**
  String get literal_41602535;

  /// No description provided for @literal_00b70425.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合稳定 WebDAV；网络较慢时可关闭，改用手动上传'**
  String get literal_00b70425;

  /// No description provided for @literal_4200d832.
  ///
  /// In zh_Hans, this message translates to:
  /// **'适合自动识别不准、背景复杂或想保留特殊轮廓的图片。实时预览会跟着你的勾勒更新，最后生成贴纸感封面。'**
  String get literal_4200d832;

  /// No description provided for @literal_29731bb4.
  ///
  /// In zh_Hans, this message translates to:
  /// **'选择参与产生收益的资产，并记录它们实际赚回来的金额。多件资产会在详情页里均摊显示。'**
  String get literal_29731bb4;

  /// No description provided for @literal_645c3acb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通勤'**
  String get literal_645c3acb;

  /// No description provided for @literal_725ef06b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'通知、相机、文件、分享入口'**
  String get literal_725ef06b;

  /// No description provided for @literal_71e692aa.
  ///
  /// In zh_Hans, this message translates to:
  /// **'配件'**
  String get literal_71e692aa;

  /// No description provided for @literal_d47df376.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重命名'**
  String get literal_d47df376;

  /// No description provided for @literal_cc2062c0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'重命名快照'**
  String get literal_cc2062c0;

  /// No description provided for @literal_daeb7a0f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钓具'**
  String get literal_daeb7a0f;

  /// No description provided for @literal_b9a4cf23.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钢笔'**
  String get literal_b9a4cf23;

  /// No description provided for @literal_bc6a9cbb.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钥匙'**
  String get literal_bc6a9cbb;

  /// No description provided for @literal_989f26db.
  ///
  /// In zh_Hans, this message translates to:
  /// **'钱包'**
  String get literal_989f26db;

  /// No description provided for @literal_fb80241a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'银行卡'**
  String get literal_fb80241a;

  /// No description provided for @literal_e8ebb221.
  ///
  /// In zh_Hans, this message translates to:
  /// **'锁具'**
  String get literal_e8ebb221;

  /// No description provided for @literal_7d4e2d8b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'键盘'**
  String get literal_7d4e2d8b;

  /// No description provided for @literal_9394d4fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'长期持有'**
  String get literal_9394d4fd;

  /// No description provided for @literal_befbb7f1.
  ///
  /// In zh_Hans, this message translates to:
  /// **'闹钟'**
  String get literal_befbb7f1;

  /// No description provided for @literal_592acfda.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加项目'**
  String get literal_592acfda;

  /// No description provided for @literal_c8b58202.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加项目可以记录配件、维修、升级等费用，并支持购买时间跟随父资产。'**
  String get literal_c8b58202;

  /// No description provided for @literal_4473ef0a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'附加项目：会影响总价值和日均成本'**
  String get literal_4473ef0a;

  /// No description provided for @literal_883b63e3.
  ///
  /// In zh_Hans, this message translates to:
  /// **'除了二手卖出，也可以把一组资产实际带来的收入记入回收，例如拍摄接单、游戏设备直播收益、工具维修收入等。'**
  String get literal_883b63e3;

  /// No description provided for @literal_2d782bd0.
  ///
  /// In zh_Hans, this message translates to:
  /// **'露营'**
  String get literal_2d782bd0;

  /// No description provided for @literal_8d2438ca.
  ///
  /// In zh_Hans, this message translates to:
  /// **'鞋'**
  String get literal_8d2438ca;

  /// No description provided for @literal_ba3ee816.
  ///
  /// In zh_Hans, this message translates to:
  /// **'音乐'**
  String get literal_ba3ee816;

  /// No description provided for @literal_5065a9c7.
  ///
  /// In zh_Hans, this message translates to:
  /// **'顶部资产总览会实时显示资产数量、总资产、日均成本和服役状态比例。'**
  String get literal_5065a9c7;

  /// No description provided for @literal_bc285e0e.
  ///
  /// In zh_Hans, this message translates to:
  /// **'预测 {days} 天'**
  String literal_bc285e0e({required Object days});

  /// No description provided for @literal_300a703f.
  ///
  /// In zh_Hans, this message translates to:
  /// **'预计节点'**
  String get literal_300a703f;

  /// No description provided for @literal_de83704b.
  ///
  /// In zh_Hans, this message translates to:
  /// **'颜色'**
  String get literal_de83704b;

  /// No description provided for @literal_e76d839a.
  ///
  /// In zh_Hans, this message translates to:
  /// **'风景'**
  String get literal_e76d839a;

  /// No description provided for @literal_7696f2fd.
  ///
  /// In zh_Hans, this message translates to:
  /// **'食品'**
  String get literal_7696f2fd;

  /// No description provided for @literal_f462efed.
  ///
  /// In zh_Hans, this message translates to:
  /// **'首页总览：直接指向真实卡片'**
  String get literal_f462efed;

  /// No description provided for @literal_aa117820.
  ///
  /// In zh_Hans, this message translates to:
  /// **'高亮框会跟着这一整行真实控件走，不会因为屏幕尺寸变化而偏移。'**
  String get literal_aa117820;

  /// No description provided for @literal_35963a22.
  ///
  /// In zh_Hans, this message translates to:
  /// **'魔法'**
  String get literal_35963a22;

  /// No description provided for @literal_6169f9c8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'麦克风'**
  String get literal_6169f9c8;

  /// No description provided for @literal_4b32cee8.
  ///
  /// In zh_Hans, this message translates to:
  /// **'鼠标'**
  String get literal_4b32cee8;
}

class _ValoraLocalizationsDelegate
    extends LocalizationsDelegate<ValoraLocalizations> {
  const _ValoraLocalizationsDelegate();

  @override
  Future<ValoraLocalizations> load(Locale locale) {
    return SynchronousFuture<ValoraLocalizations>(
        lookupValoraLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_ValoraLocalizationsDelegate old) => false;
}

ValoraLocalizations lookupValoraLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return ValoraLocalizationsZhHans();
          case 'Hant':
            return ValoraLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return ValoraLocalizationsEn();
    case 'zh':
      return ValoraLocalizationsZh();
  }

  throw FlutterError(
      'ValoraLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
