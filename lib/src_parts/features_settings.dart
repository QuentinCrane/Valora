part of '../main.dart';

enum _SettingsTab { overview, data, appearance, system }

String _settingsTabLabel(_SettingsTab tab) {
  switch (tab) {
    case _SettingsTab.overview:
      return '总览';
    case _SettingsTab.data:
      return '数据与备份';
    case _SettingsTab.appearance:
      return '外观与交互';
    case _SettingsTab.system:
      return '系统与权限';
  }
}

String _settingsTabSubtitle(_SettingsTab tab) {
  switch (tab) {
    case _SettingsTab.overview:
      return '常用设置和状态概览。';
    case _SettingsTab.data:
      return '管理分类、标签、备份、恢复、云端同步和本地数据。';
    case _SettingsTab.appearance:
      return '调整主题、首页展示、金额格式、时长、触感、提示条和贴纸封面。';
    case _SettingsTab.system:
      return '管理 Android 原生能力、权限、小组件、通知和系统入口。';
  }
}

class SettingsHomePage extends StatefulWidget {
  final _SettingsTab initialTab;
  final bool asSubPage;
  const SettingsHomePage({
    super.key,
    this.initialTab = _SettingsTab.overview,
    this.asSubPage = false,
  });

  @override
  State<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  late _SettingsTab tab;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
  }

  void _openGroup(_SettingsTab next) {
    tapHaptic();
    Navigator.of(context).push(
      softRoute(
        SettingsHomePage(initialTab: next, asSubPage: true),
        style: ValoraRouteStyle.settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    if (widget.asSubPage) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            PageFrame(
              padding: EdgeInsets.fromLTRB(
                14,
                70 + MediaQuery.paddingOf(context).top,
                14,
                112 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _settingsTabLabel(tab),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.normal,
                              height: 1.0,
                              letterSpacing: -.35,
                            ),
                      ),
                    ),
                    const ValuePill('二级菜单'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _settingsTabSubtitle(tab),
                  style: const TextStyle(
                    color: kMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                TutorialTargetAnchor(
                  id: 'settings.subpage.content',
                  child: _tabContent(context, store),
                ),
              ],
            ),
            GlobalBackButton(onTap: () => Navigator.pop(context)),
          ],
        ),
      );
    }
    return PageFrame(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '设置',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  height: 1.0,
                  letterSpacing: -.35,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kBrand.withOpacity(.17),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kBrand.withOpacity(.16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 7,
                    height: 7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: kBrandStrong,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '本地模式',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: context.isDark
                          ? Colors.white.withOpacity(.82)
                          : const Color(0xFF17638F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsHeroCard(),
        const SizedBox(height: 12),
        const FormatPreviewCard(),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'settings.menu',
          child: SettingsSection(
            title: '设置菜单',
            children: [
              SettingRow(
                icon: Icons.storage_rounded,
                iconBg: const Color(0xFFC8EBFF),
                label: '数据与备份',
                description: '分类、标签、完整 ZIP、JSON、快照、云端同步',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openGroup(_SettingsTab.data),
              ),
              SettingRow(
                icon: Icons.palette_rounded,
                iconBg: const Color(0xFF8998F4),
                label: '外观与交互',
                description: '主题、首页样式、金额、时长、触感、提示条、贴纸引擎',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openGroup(_SettingsTab.appearance),
              ),
              SettingRow(
                icon: Icons.settings_applications_rounded,
                iconBg: const Color(0xFFFFE2D6),
                label: '系统与权限',
                description: '原生能力、小组件、通知、系统设置、云端快捷操作',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openGroup(_SettingsTab.system),
              ),
              SettingRow(
                icon: Icons.school_rounded,
                iconBg: const Color(0xFFBDEB7E),
                label: '新手教程',
                description: '重新查看完整使用教程和功能导览',
                trailing: const ValuePill('开始'),
                onTap: () => showOnboardingTutorial(context, markSeen: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'settings.quick',
          child: SettingsSection(
            title: '快速入口',
            children: [
              SettingRow(
                icon: Icons.category_rounded,
                iconBg: const Color(0xFFC8EBFF),
                label: '分类管理',
                description: '${store.categories.length} 个分类，支持图标、颜色和推荐体系',
                trailing: ValuePill('${store.categories.length} 类'),
                onTap: () => showCategoryManager(context),
              ),
              SettingRow(
                icon: Icons.backup_rounded,
                iconBg: const Color(0xFF8FD0F6),
                label: '备份与恢复',
                description: '完整资料包 ZIP、JSON、快照与恢复',
                trailing: ValuePill('${store.snapshots.length} 份'),
                onTap: () => showBackupManager(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabContent(BuildContext context, AppStore store) {
    Future<void> refreshWidgets() async {
      await NativeBridge.updateHomeWidget(
        assetCount: store.assets.length,
        wishCount: store.wishes.where((w) => !w.archived).length,
        totalAssetValue: store.getTotalAssetValue(),
        averageDailyCost: store.getAverageDailyCost(),
        currency: store.settings.currencyUnit,
        servingCount: store.statusCount(AssetStatus.serving),
        retiredCount: store.statusCount(AssetStatus.retired),
        soldCount: store.statusCount(AssetStatus.sold),
        dueSoonCount: store.dueSoonAssets().length,
        leakCount: store.walletLeaks(limit: 99).length,
        snapshotCount: store.snapshots.length,
      );
      if (context.mounted) showNativeSnack(context, '已刷新所有桌面小组件');
    }

    Widget stickerEngineSection() => SettingsSection(
      title: '贴纸与封面',
      children: [
        SettingRow(
          icon: Icons.auto_awesome_rounded,
          iconBg: const Color(0xFFAEE6FF),
          label: '本地贴纸模式',
          description: store.settings.stickerEngineMode.description,
          trailing: MiniChoiceBar<StickerEngineMode>(
            value: store.settings.stickerEngineMode,
            values: StickerEngineMode.values,
            labelOf: (v) => v.label,
            onChanged: (v) async {
              final next = store.settings.copyWith(stickerEngineMode: v);
              store.updateSettings(next);
              await NativeBridge.setStickerEngineConfig(
                mode: v.name,
                keepCandidates: next.keepStickerCandidates,
              );
            },
          ),
        ),
        SettingSwitchRow(
          icon: Icons.layers_clear_rounded,
          iconBg: const Color(0xFFBDEB7E),
          label: '保留未选候选图',
          description: '关闭后自动删除未选贴纸候选，避免缓存积累',
          value: store.settings.keepStickerCandidates,
          onChanged: (v) async {
            final next = store.settings.copyWith(keepStickerCandidates: v);
            store.updateSettings(next);
            await NativeBridge.setStickerEngineConfig(
              mode: next.stickerEngineMode.name,
              keepCandidates: v,
            );
          },
        ),
      ],
    );

    switch (tab) {
      case _SettingsTab.overview:
        return Column(
          children: [
            const FormatPreviewCard(),
            const SizedBox(height: 12),
            SettingsSection(
              title: '常用管理',
              children: [
                SettingRow(
                  icon: Icons.category_rounded,
                  iconBg: const Color(0xFFC8EBFF),
                  label: '分类与标签',
                  description:
                      '${store.categories.length} 个分类 · ${store.tags.length} 个标签',
                  trailing: const ValuePill('管理'),
                  onTap: () => setState(() => tab = _SettingsTab.data),
                ),
                SettingRow(
                  icon: Icons.backup_rounded,
                  iconBg: const Color(0xFF8FD0F6),
                  label: '备份与恢复',
                  description: '完整资料包、JSON、快照与恢复',
                  trailing: ValuePill('${store.snapshots.length} 份'),
                  onTap: () => showBackupManager(context),
                ),
                SettingRow(
                  icon: Icons.palette_rounded,
                  iconBg: const Color(0xFF8998F4),
                  label: '外观与交互',
                  description: '主题、首页、金额格式、触感和提示条',
                  trailing: const ValuePill('聚合'),
                  onTap: () => setState(() => tab = _SettingsTab.appearance),
                ),
                SettingRow(
                  icon: Icons.settings_applications_rounded,
                  iconBg: const Color(0xFFFFE2D6),
                  label: '系统能力',
                  description: '小组件、权限、通知、原生接口和同步',
                  trailing: const ValuePill('系统'),
                  onTap: () => setState(() => tab = _SettingsTab.system),
                ),
              ],
            ),
          ],
        );
      case _SettingsTab.data:
        return Column(
          children: [
            SettingsSection(
              title: '资产组织',
              children: [
                SettingRow(
                  icon: Icons.category_rounded,
                  iconBg: const Color(0xFFC8EBFF),
                  label: '分类管理',
                  description: '建议使用电子数码、学习办公等大类',
                  trailing: ValuePill('${store.categories.length} 类'),
                  onTap: () => showCategoryManager(context),
                ),
                SettingRow(
                  icon: Icons.sell_rounded,
                  iconBg: const Color(0xFF9FD8F8),
                  label: '标签管理',
                  description: '细分通勤、收藏、维修、吃灰等状态',
                  trailing: ValuePill('${store.tags.length} 个'),
                  onTap: () => showTagManager(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSection(
              title: '备份与迁移',
              children: [
                SettingRow(
                  icon: Icons.backup_rounded,
                  iconBg: const Color(0xFF8FD0F6),
                  label: '备份与恢复',
                  description: '完整 ZIP、JSON、快照、CSV 和 Markdown',
                  trailing: ValuePill('${store.snapshots.length} 份'),
                  onTap: () => showBackupManager(context),
                ),
                SettingRow(
                  icon: Icons.cloud_sync_rounded,
                  iconBg: const Color(0xFFC8EBFF),
                  label: '云端同步',
                  description: 'WebDAV、坚果云、Nextcloud 与手动文件备份',
                  trailing: ValuePill(store.settings.cloudSync.providerLabel),
                  onTap: () => showCloudSyncEditor(context),
                ),
                SettingRow(
                  icon: Icons.archive_rounded,
                  iconBg: const Color(0xFFD8E7FF),
                  label: '分享完整资料包',
                  description: '打包 SQLite、JSON、报告和封面/贴纸图片',
                  trailing: const ValuePill('ZIP'),
                  onTap: () => shareCompleteDataArchive(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSection(
              title: '危险操作',
              children: [
                SettingRow(
                  icon: Icons.restore_rounded,
                  iconBg: const Color(0xFFFF9F89),
                  label: '清空本地数据',
                  description: '删除资产、心愿、分类、标签和快照',
                  onTap: () => confirmReset(context),
                ),
              ],
            ),
          ],
        );
      case _SettingsTab.appearance:
        return Column(
          children: [
            SettingsSection(
              title: '显示与格式',
              children: [
                SettingRow(
                  icon: Icons.palette_rounded,
                  iconBg: const Color(0xFF8998F4),
                  label: '主题模式',
                  description: '跟随系统，也可固定日间或夜间',
                  trailing: MiniChoiceBar<ThemeSetting>(
                    value: store.settings.theme,
                    values: ThemeSetting.values,
                    labelOf: themeSettingLabel,
                    onChanged: (v) =>
                        store.updateSettings(store.settings.copyWith(theme: v)),
                  ),
                ),
                SettingRow(
                  icon: Icons.view_carousel_rounded,
                  iconBg: const Color(0xFFC8EBFF),
                  label: '首页风格',
                  description: '卡片、列表、便利贴',
                  trailing: MiniChoiceBar<HomeViewMode>(
                    value: store.settings.defaultHomeViewMode,
                    values: HomeViewMode.values,
                    labelOf: (v) => v.label,
                    onChanged: store.setViewMode,
                  ),
                ),
                SettingSwitchRow(
                  icon: Icons.pie_chart_rounded,
                  iconBg: const Color(0xFF7DB5FF),
                  label: '退役计入总资产',
                  description: '关闭后，分析和首页总值会排除退役资产',
                  value: store.settings.includeRetiredInTotal,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(includeRetiredInTotal: v),
                  ),
                ),
                SettingRow(
                  icon: Icons.wallet_rounded,
                  iconBg: const Color(0xFFFFDC65),
                  label: '货币符号',
                  description: '控制所有金额的前缀显示',
                  trailing: ValuePill(store.settings.currencyUnit),
                  onTap: () => showCurrencyDialog(context),
                ),
                SettingRow(
                  icon: Icons.numbers_rounded,
                  iconBg: const Color(0xFF98E0FF),
                  label: '小数位数',
                  description: '金额计算仍保留原始精度',
                  trailing: ValuePill('${store.settings.decimalPlaces} 位'),
                  onTap: () => showDecimalDialog(context),
                ),
                SettingSwitchRow(
                  icon: Icons.format_list_numbered_rounded,
                  iconBg: const Color(0xFFBCE9FF),
                  label: '千位分隔符',
                  description: '大额资产会更容易扫读',
                  value: store.settings.useThousandsSeparator,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(useThousandsSeparator: v),
                  ),
                ),
                SettingRow(
                  icon: Icons.timelapse_rounded,
                  iconBg: const Color(0xFF7CC6F2),
                  label: '时长显示',
                  description: '影响资产卡片和分析里的使用时长',
                  trailing: MiniChoiceBar<DurationMode>(
                    value: store.settings.durationMode,
                    values: DurationMode.values,
                    labelOf: durationModeLabel,
                    onChanged: (v) => store.updateSettings(
                      store.settings.copyWith(durationMode: v),
                    ),
                  ),
                ),
                SettingRow(
                  icon: Icons.text_fields_rounded,
                  iconBg: const Color(0xFFE8F7FE),
                  label: '首页副信息字号',
                  description: '调整首页资产卡片中“价格 / 已使用时间”等小字，避免持有时间被省略',
                  trailing: MiniChoiceBar<double>(
                    value: store.settings.homeMetaFontScale,
                    values: const [0.84, 0.92, 1.0, 1.08],
                    labelOf: (v) => v <= .86
                        ? '紧凑'
                        : v < .98
                        ? '小'
                        : v > 1.04
                        ? '大'
                        : '标准',
                    onChanged: (v) => store.updateSettings(
                      store.settings.copyWith(homeMetaFontScale: v),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSection(
              title: '交互反馈',
              children: [
                SettingSwitchRow(
                  icon: Icons.vibration_rounded,
                  iconBg: const Color(0xFFE6D7FF),
                  label: '触感反馈',
                  description: '控制 App 内点击、保存、切换等轻触感反馈',
                  value: store.settings.hapticsEnabled,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(hapticsEnabled: v),
                  ),
                ),
                SettingSwitchRow(
                  icon: Icons.phone_android_rounded,
                  iconBg: const Color(0xFFD8F5FF),
                  label: 'Android 原生震动',
                  description: '关闭后不再调用原生 Vibrator',
                  value: store.settings.nativeHapticsEnabled,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(nativeHapticsEnabled: v),
                  ),
                ),
                SettingSwitchRow(
                  icon: Icons.notifications_none_rounded,
                  iconBg: const Color(0xFFFFE6B8),
                  label: '紧凑提示条',
                  description: '提示条会上移并带关闭按钮，避免挡住底部操作',
                  value: store.settings.compactSnackbars,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(compactSnackbars: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            stickerEngineSection(),
          ],
        );
      case _SettingsTab.system:
        return Column(
          children: [
            const NativeFeaturePanel(),
            const SizedBox(height: 12),
            SettingsSection(
              title: '系统与返回',
              children: [
                SettingRow(
                  icon: Icons.arrow_back_rounded,
                  iconBg: const Color(0xFFE6F5FF),
                  label: '场景化返回动画',
                  description: '详情、编辑、设置、弹层、分析页采用不同入场和返回手势反馈',
                  trailing: const ValuePill('v54'),
                  onTap: () => showNativeSnack(
                    context,
                    '已按页面类型区分详情/编辑/设置/弹层/分析的过渡动画和边缘返回反馈',
                  ),
                ),
                SettingRow(
                  icon: Icons.security_rounded,
                  iconBg: const Color(0xFFFFE2D6),
                  label: '权限与系统设置',
                  description: '通知、相机、文件、分享入口',
                  trailing: const ValuePill('系统'),
                  onTap: () => NativeBridge.openAppSettings(),
                ),
                SettingRow(
                  icon: Icons.widgets_rounded,
                  iconBg: const Color(0xFF98E0FF),
                  label: '刷新桌面小组件',
                  description: '同步资产、心愿、日均和风险数据',
                  trailing: const ValuePill('Android'),
                  onTap: refreshWidgets,
                ),
                SettingSwitchRow(
                  icon: Icons.notifications_active_rounded,
                  iconBg: const Color(0xFFBDEB7E),
                  label: '到期提醒',
                  description: '使用 Android 本地通知能力',
                  value: store.settings.reminderEnabled,
                  onChanged: (v) => store.updateSettings(
                    store.settings.copyWith(reminderEnabled: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SettingsSection(
              title: '云端快速操作',
              children: [
                SettingRow(
                  icon: Icons.cloud_sync_rounded,
                  iconBg: const Color(0xFFC8EBFF),
                  label: '云端同步设置',
                  description: store.settings.cloudSync.enabled
                      ? '${store.settings.cloudSync.providerLabel} · ${store.settings.cloudSync.remotePath}'
                      : '可选择 WebDAV、坚果云、Nextcloud 或手动文件备份',
                  trailing: ValuePill(store.settings.cloudSync.providerLabel),
                  onTap: () => showCloudSyncEditor(context),
                ),
                SettingRow(
                  icon: Icons.upload_rounded,
                  iconBg: const Color(0xFFBDEB7E),
                  label: '立即上传备份',
                  description: '把当前数据保存到已配置云端',
                  onTap: () async {
                    final r = await store.uploadCloudBackup();
                    if (context.mounted) showNativeSnack(context, r.message);
                  },
                ),
                SettingRow(
                  icon: Icons.download_rounded,
                  iconBg: const Color(0xFFAEE6FF),
                  label: '从云端拉取',
                  description: '读取云端备份并覆盖本地数据',
                  onTap: () async {
                    final r = await store.downloadCloudBackup();
                    if (context.mounted) showNativeSnack(context, r.message);
                  },
                ),
              ],
            ),
          ],
        );
    }
  }
}

class CloudSyncPanel extends StatefulWidget {
  const CloudSyncPanel({super.key});

  @override
  State<CloudSyncPanel> createState() => _CloudSyncPanelState();
}

class _CloudSyncPanelState extends State<CloudSyncPanel> {
  bool busy = false;

  Future<void> _run(
    Future<CloudSyncResult> Function(AppStore store) task,
  ) async {
    final store = context.store;
    setState(() => busy = true);
    final result = await task(store);
    if (!mounted) return;
    setState(() => busy = false);
    showNativeSnack(context, result.message);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final cloud = store.settings.cloudSync;
    final enabled = cloud.enabled;
    return Column(
      children: [
        SettingsSection(
          title: '同步方式',
          children: [
            SettingRow(
              icon: Icons.cloud_sync_rounded,
              iconBg: const Color(0xFFC8EBFF),
              label: '云端方案',
              description: enabled
                  ? '${cloud.providerLabel} · ${cloud.remotePath}'
                  : '可选择 WebDAV、坚果云、Nextcloud 或手动文件备份',
              trailing: ValuePill(cloud.providerLabel),
              onTap: () => showCloudSyncEditor(context),
            ),
            SettingSwitchRow(
              icon: Icons.upload_rounded,
              iconBg: const Color(0xFFBDEB7E),
              label: '保存后自动上传',
              description: '适合稳定 WebDAV；网络较慢时可关闭，改用手动上传',
              value: cloud.autoUploadOnSave,
              onChanged: (v) => store.updateCloudSyncSettings(
                cloud.copyWith(autoUploadOnSave: v),
              ),
            ),
            SettingSwitchRow(
              icon: Icons.download_done_rounded,
              iconBg: const Color(0xFFAEE6FF),
              label: '启动时尝试拉取',
              description: '打开 App 后自动读取云端备份；建议单设备使用时关闭',
              value: cloud.syncOnLaunch,
              onChanged: (v) => store.updateCloudSyncSettings(
                cloud.copyWith(syncOnLaunch: v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsSection(
          title: '云端操作',
          children: [
            SettingRow(
              icon: Icons.wifi_tethering_rounded,
              iconBg: const Color(0xFF98E0FF),
              label: '测试连接',
              description: busy ? '正在连接云端…' : '使用 PROPFIND 检查 WebDAV 端点和账号',
              trailing: ValuePill(enabled ? '可测试' : '未启用'),
              onTap: busy ? null : () => _run((s) => s.testCloudConnection()),
            ),
            SettingRow(
              icon: Icons.cloud_upload_rounded,
              iconBg: const Color(0xFFBDEB7E),
              label: '上传当前备份',
              description: cloud.lastUploadAt == null
                  ? '把当前 JSON 备份写入云端路径'
                  : '上次上传：${dateLabel(cloud.lastUploadAt!)}',
              trailing: const ValuePill('PUT'),
              onTap: busy ? null : () => _run((s) => s.uploadCloudBackup()),
            ),
            SettingRow(
              icon: Icons.cloud_download_rounded,
              iconBg: const Color(0xFFFFDC65),
              label: '从云端恢复',
              description: cloud.lastDownloadAt == null
                  ? '读取云端 JSON，并覆盖当前本机数据'
                  : '上次读取：${dateLabel(cloud.lastDownloadAt!)}',
              trailing: const ValuePill('GET'),
              onTap: busy
                  ? null
                  : () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: '从云端恢复？',
                        message: '这会用云端备份覆盖当前本机数据。建议先导出一份本机 JSON。',
                      );
                      if (confirm == true) _run((s) => s.downloadCloudBackup());
                    },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsSection(
          title: '其他云端入口',
          children: [
            SettingRow(
              icon: Icons.folder_open_rounded,
              iconBg: const Color(0xFFE6F5FF),
              label: '系统文件备份',
              description: '导出到任意网盘同步文件夹，或从系统文件恢复',
              trailing: const ValuePill('SAF'),
              onTap: () => showBackupManager(context),
            ),
            SettingRow(
              icon: Icons.archive_rounded,
              iconBg: const Color(0xFFD8E7FF),
              label: '分享完整资料包',
              description: '打包 SQLite、JSON、CSV、报告和封面/贴纸图片',
              trailing: const ValuePill('ZIP'),
              onTap: () => shareCompleteDataArchive(context),
            ),
          ],
        ),
      ],
    );
  }
}

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('继续'),
        ),
      ],
    ),
  );
}

void showCloudSyncEditor(BuildContext context) {
  final store = context.store;
  final current = store.settings.cloudSync;
  var provider = current.provider;
  final urlCtl = TextEditingController(
    text: current.serverUrl.isEmpty
        ? defaultCloudServerUrl(provider)
        : current.serverUrl,
  );
  final userCtl = TextEditingController(text: current.username);
  final passCtl = TextEditingController(text: current.password);
  final pathCtl = TextEditingController(text: current.remotePath);
  appSheet(
    context,
    title: '云端同步',
    subtitle: 'WebDAV 已可直接上传/读取 JSON 备份；坚果云和 Nextcloud 本质也是 WebDAV 端点。',
    child: StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoundedSelectField<CloudSyncProvider>(
              label: '同步方案',
              value: provider,
              options: CloudSyncProvider.values
                  .map(
                    (e) => SelectOption(
                      value: e,
                      label: cloudSyncProviderLabel(e),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                provider = v;
                final preset = defaultCloudServerUrl(v);
                if (preset.isNotEmpty &&
                    (urlCtl.text.trim().isEmpty ||
                        urlCtl.text.contains('example.com') ||
                        urlCtl.text.contains('your-nextcloud')))
                  urlCtl.text = preset;
                setLocal(() {});
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: urlCtl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://dav.example.com/dav/',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: userCtl,
              decoration: const InputDecoration(labelText: '账号 / 用户名'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtl,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码 / 应用专用密码'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pathCtl,
              decoration: const InputDecoration(
                labelText: '云端文件路径',
                hintText: 'valora/valora_backup.json',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '提示：坚果云通常要使用“应用密码”；Nextcloud 地址一般类似 /remote.php/dav/files/用户名/。当前版本会把配置保存在本机 JSON 中，正式发布前建议再接入 Android Keystore 加密。',
              style: TextStyle(
                fontSize: 12,
                height: 1.38,
                color: kMuted.withOpacity(.95),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () async {
                final next = current.copyWith(
                  provider: provider,
                  serverUrl: urlCtl.text.trim(),
                  username: userCtl.text.trim(),
                  password: passCtl.text,
                  remotePath: pathCtl.text.trim().isEmpty
                      ? 'valora/valora_backup.json'
                      : pathCtl.text.trim(),
                );
                await store.updateCloudSyncSettings(next);
                if (context.mounted) {
                  Navigator.pop(context);
                  showNativeSnack(context, '云端同步设置已保存');
                }
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('保存云端设置'),
            ),
          ],
        );
      },
    ),
  );
}

class SettingsTabBar extends StatelessWidget {
  final _SettingsTab value;
  final ValueChanged<_SettingsTab> onChanged;
  const SettingsTabBar({
    super.key,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _SettingsTab.values.map((item) {
          final active = item == value;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onChanged(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minWidth: 58),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? (dark ? Colors.white.withOpacity(.16) : kText)
                      : (dark
                            ? Colors.white.withOpacity(.045)
                            : Colors.white.withOpacity(.78)),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? Colors.white.withOpacity(dark ? .12 : 0)
                        : Colors.white.withOpacity(dark ? .07 : .55),
                  ),
                  boxShadow: active && !dark
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(.10),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : const [],
                ),
                child: Text(
                  _settingsTabLabel(item),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: active ? Colors.white : kMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SettingsHeroCard extends StatelessWidget {
  const SettingsHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final dark = context.isDark;
    final total = store.assets.length + store.wishes.length;
    final primaryText = dark ? Colors.white.withOpacity(.94) : kText;
    final secondaryText = dark
        ? Colors.white.withOpacity(.62)
        : const Color(0x99141518);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F3650),
                  Color(0xFF0B2538),
                  Color(0xFF071A28),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7CC6F2),
                  Color(0xFFC8EBFF),
                  Color(0xFFFFFFFF),
                ],
              ),
        border: Border.all(color: Colors.white.withOpacity(dark ? .08 : .46)),
        boxShadow: [
          BoxShadow(
            color: kBrand.withOpacity(dark ? .055 : .22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本机数据',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 23,
              height: .92,
              fontWeight: FontWeight.normal,
              letterSpacing: -1.2,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '资产与心愿记录保存在当前设备，备份后可随时恢复。',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.38,
              color: secondaryText,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SettingsMetricPill(
                  value: '${store.categories.length}',
                  label: '分类',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SettingsMetricPill(
                  value: '${store.tags.length}',
                  label: '标签',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SettingsMetricPill(
                  value: '${store.snapshots.length}',
                  label: '快照',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsMetricPill extends StatelessWidget {
  final String value;
  final String label;
  const SettingsMetricPill({
    super.key,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(.055)
            : Colors.white.withOpacity(.54),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(dark ? .08 : .48)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.normal,
              color: dark ? Colors.white.withOpacity(.92) : kText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: dark
                  ? Colors.white.withOpacity(.56)
                  : const Color(0x99141518),
            ),
          ),
        ],
      ),
    );
  }
}

class FormatPreviewCard extends StatelessWidget {
  const FormatPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '显示预览',
                  style: TextStyle(
                    color: kMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  money(12345.67, store.settings),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${durationWithCalendarText(428, store.settings.durationMode)} · ${store.settings.useThousandsSeparator ? '千位分隔' : '无千位分隔'}',
                  style: const TextStyle(color: kMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: kBrand.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('🏷️', style: TextStyle(fontSize: 26)),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 7),
        child: Text(
          title,
          style: const TextStyle(
            color: kMuted,
            fontWeight: FontWeight.normal,
            fontSize: 12,
            letterSpacing: .3,
          ),
        ),
      ),
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        child: Column(children: children),
      ),
    ],
  );
}

class SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String description;
  final Widget? trailing;
  final VoidCallback? onTap;
  const SettingRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.description,
    this.trailing,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap == null
          ? null
          : () {
              lightHaptic();
              onTap!.call();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(context.isDark ? .18 : .35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: context.isDark
                    ? Colors.white.withOpacity(.86)
                    : (iconBg.computeLuminance() > .55
                          ? kText.withOpacity(.78)
                          : iconBg),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      letterSpacing: -.08,
                      color: context.isDark
                          ? Colors.white.withOpacity(.92)
                          : kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    softWrap: true,
                    style: const TextStyle(
                      color: kMuted,
                      fontSize: 12,
                      height: 1.32,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                (onTap == null
                    ? const SizedBox.shrink()
                    : const Icon(Icons.chevron_right_rounded, color: kMuted)),
          ],
        ),
      ),
    );
  }
}

class SettingSwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SettingSwitchRow({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return SettingRow(
      icon: icon,
      iconBg: iconBg,
      label: label,
      description: description,
      trailing: Switch(
        value: value,
        onChanged: (v) {
          tapHaptic();
          onChanged(v);
        },
      ),
    );
  }
}

class ValuePill extends StatelessWidget {
  final String text;
  const ValuePill(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: context.isDark
          ? Colors.white.withOpacity(.06)
          : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: kMuted,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

class MiniChoiceBar<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const MiniChoiceBar({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(.055) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((item) {
          final active = item == value;
          return GestureDetector(
            onTap: () {
              tapHaptic();
              onChanged(item);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: values.length >= 3 ? 46 : 56,
              padding: const EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? (dark ? Colors.white.withOpacity(.14) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active && !dark
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labelOf(item),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: active
                      ? (dark ? Colors.white.withOpacity(.92) : kText)
                      : kMuted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String themeSettingLabel(ThemeSetting value) {
  switch (value) {
    case ThemeSetting.light:
      return '浅色';
    case ThemeSetting.dark:
      return '深色';
    case ThemeSetting.system:
      return '系统';
  }
}

String durationModeLabel(DurationMode value) {
  switch (value) {
    case DurationMode.days:
      return '天';
    case DurationMode.weeks:
      return '周';
    case DurationMode.months:
      return '月';
    case DurationMode.years:
      return '年/月';
  }
}

void showCurrencyDialog(BuildContext context) {
  final ctl = TextEditingController(text: context.store.settings.currencyUnit);
  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('货币符号'),
      content: TextField(
        controller: ctl,
        decoration: const InputDecoration(labelText: '例如 ¥ / \$ / RMB'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            context.store.updateSettings(
              context.store.settings.copyWith(
                currencyUnit: ctl.text.trim().isEmpty ? '¥' : ctl.text.trim(),
              ),
            );
            Navigator.pop(d);
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

void showDecimalDialog(BuildContext context) {
  final ctl = TextEditingController(
    text: context.store.settings.decimalPlaces.toString(),
  );
  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('小数位数'),
      content: TextField(
        controller: ctl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: '0-3'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            context.store.updateSettings(
              context.store.settings.copyWith(
                decimalPlaces: asInt(ctl.text, fallback: 2).clamp(0, 3).toInt(),
              ),
            );
            Navigator.pop(d);
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

const List<String> _smartCategoryIcons = [
  '📦',
  '📱',
  '💻',
  '⌨️',
  '🖱️',
  '🖥️',
  '⌚',
  '🎧',
  '🎙️',
  '🔊',
  '📷',
  '🎥',
  '🎮',
  '🕹️',
  '💾',
  '🔌',
  '🔋',
  '🧲',
  '📡',
  '🚗',
  '🏍️',
  '🚲',
  '🛴',
  '🚇',
  '✈️',
  '🧳',
  '🏠',
  '🛋️',
  '🛏️',
  '🪑',
  '💡',
  '🧹',
  '🍳',
  '☕',
  '🍽️',
  '👕',
  '👖',
  '👟',
  '🧥',
  '🎒',
  '👜',
  '👓',
  '💄',
  '⌛',
  '💍',
  '📚',
  '✏️',
  '🗂️',
  '🎹',
  '🎸',
  '🎧',
  '🎨',
  '🧸',
  '🎁',
  '🛠️',
  '🧰',
  '🔧',
  '🏃',
  '🏀',
  '🏸',
  '🏕️',
  '🐱',
  '🐶',
  '🌿',
  '💊',
  '💳',
  '🧾',
  '💰',
  '⭐',
  '❤️',
  '🔥',
  '✨',
];

const List<String> _smartColorPalette = [
  '#7cc6f2',
  '#60A5FA',
  '#38BDF8',
  '#34D399',
  '#4ADE80',
  '#A3E635',
  '#FACC15',
  '#FDBA74',
  '#FB7185',
  '#F472B6',
  '#A78BFA',
  '#818CF8',
  '#94A3B8',
  '#111827',
];

const Map<String, String> _categoryIconKeywords = {
  '电子数码': '💻',
  '数码': '💻',
  '电子': '💻',
  '手机': '💻',
  '平板': '💻',
  '电脑': '💻',
  '笔记本': '💻',
  '键盘': '💻',
  '鼠标': '💻',
  '显示器': '💻',
  '硬盘': '💻',
  '充电': '💻',
  '影音娱乐': '🎧',
  '影音': '🎧',
  '耳机': '🎧',
  '音箱': '🎧',
  '麦克风': '🎧',
  '电视': '🎧',
  '影像创作': '📷',
  '摄影': '📷',
  '相机': '📷',
  '镜头': '📷',
  '摄像': '📷',
  '创作': '📷',
  '游戏兴趣': '🎮',
  '游戏': '🎮',
  '主机': '🎮',
  '掌机': '🎮',
  '兴趣': '🎮',
  '娱乐': '🎮',
  '学习办公': '📚',
  '学习': '📚',
  '办公': '📚',
  '书': '📚',
  '文具': '📚',
  '文件': '📚',
  '穿搭配饰': '👕',
  '穿搭': '👕',
  '服饰': '👕',
  '衣服': '👕',
  '鞋': '👕',
  '包': '👕',
  '眼镜': '👕',
  '饰品': '👕',
  '家居生活': '🏠',
  '家居': '🏠',
  '家电': '🏠',
  '家具': '🏠',
  '厨房': '🏠',
  '生活': '🏠',
  '清洁': '🏠',
  '出行交通': '🚗',
  '出行': '🚗',
  '交通': '🚗',
  '车': '🚗',
  '自行车': '🚗',
  '旅行': '🚗',
  '通勤': '🚗',
  '健康运动': '🏃',
  '健康': '🏃',
  '运动': '🏃',
  '户外': '🏃',
  '篮球': '🏃',
  '羽毛球': '🏃',
  '药': '🏃',
  '工具维修': '🧰',
  '工具': '🧰',
  '维修': '🧰',
  '五金': '🧰',
  '收藏纪念': '⭐',
  '收藏': '⭐',
  '纪念': '⭐',
  '礼物': '⭐',
  '玩具': '⭐',
  '软件服务': '💳',
  '软件': '💳',
  '订阅': '💳',
  '服务': '💳',
  '会员': '💳',
  '卡': '💳',
};

String _suggestCategoryIcon(String raw) {
  final name = raw.trim();
  if (name.isEmpty) return '📦';
  for (final entry in _categoryIconKeywords.entries) {
    if (name.contains(entry.key)) return entry.value;
  }
  return _smartCategoryIcons[name.codeUnits.fold<int>(0, (a, b) => a + b) %
      _smartCategoryIcons.length];
}

String _suggestColor(String raw) {
  final name = raw.trim();
  if (name.isEmpty) return '#7cc6f2';
  return _smartColorPalette[name.codeUnits.fold<int>(0, (a, b) => a + b * 7) %
      _smartColorPalette.length];
}

Widget _smartColorPicker({
  required BuildContext context,
  required String value,
  required ValueChanged<String> onChanged,
}) {
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: _smartColorPalette.map((hex) {
      final active = hex.toLowerCase() == value.toLowerCase();
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          tapHaptic();
          onChanged(hex);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: active ? 42 : 36,
          height: active ? 42 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: parseColor(hex),
            border: Border.all(
              color: active
                  ? (context.isDark ? Colors.white : kText)
                  : Colors.white.withOpacity(.92),
              width: active ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: parseColor(hex).withOpacity(.28),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: active
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      );
    }).toList(),
  );
}

Widget _smartIconPicker({
  required String value,
  required ValueChanged<String> onChanged,
}) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _smartCategoryIcons.map((item) {
      final active = item == value;
      return ChoiceChip(
        label: Text(item, style: const TextStyle(fontSize: 19)),
        selected: active,
        onSelected: (_) {
          tapHaptic();
          onChanged(item);
        },
      );
    }).toList(),
  );
}

Widget _customIconInput({
  required String value,
  required ValueChanged<String> onChanged,
}) {
  final ctl = TextEditingController(text: value);
  return TextField(
    controller: ctl,
    decoration: const InputDecoration(
      labelText: '自定义图标 / Emoji',
      hintText: '可以输入任意 Emoji，例如 🧪 / 🏎️ / 🪴',
      prefixIcon: Icon(Icons.edit_rounded),
    ),
    onChanged: (v) {
      final icon = v.trim();
      if (icon.isNotEmpty) onChanged(String.fromCharCode(icon.runes.first));
    },
  );
}

Widget _presetChip({
  required String icon,
  required String label,
  required VoidCallback onTap,
}) {
  return ActionChip(avatar: Text(icon), label: Text(label), onPressed: onTap);
}

void showSmartCategoryCreateSheet(
  BuildContext context, {
  String? initialName,
  ValueChanged<String>? onCreated,
}) {
  final ctl = TextEditingController(text: initialName?.trim() ?? '');
  var iconValue = _suggestCategoryIcon(ctl.text);
  var colorValue = _suggestColor(ctl.text);
  var manualIcon = false;
  var manualColor = false;

  void applyName(String value, void Function(void Function()) setLocal) {
    setLocal(() {
      if (!manualIcon) iconValue = _suggestCategoryIcon(value);
      if (!manualColor) colorValue = _suggestColor(value);
    });
  }

  void applyPreset(String label, void Function(void Function()) setLocal) {
    ctl.text = label;
    setLocal(() {
      iconValue = _suggestCategoryIcon(label);
      colorValue = _suggestColor(label);
      manualIcon = false;
      manualColor = false;
    });
  }

  appSheet(
    context,
    title: '新增分类',
    subtitle: '不用手动输入颜色或图标，直接点选即可。',
    child: StatefulBuilder(
      builder: (sheetContext, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: parseColor(colorValue),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(iconValue, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ctl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '分类名称，例如 电子数码 / 学习办公 / 家居生活',
                    ),
                    onChanged: (v) => applyName(v, setLocal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetChip(
                  icon: '💻',
                  label: '电子数码',
                  onTap: () => applyPreset('电子数码', setLocal),
                ),
                _presetChip(
                  icon: '🎧',
                  label: '影音娱乐',
                  onTap: () => applyPreset('影音娱乐', setLocal),
                ),
                _presetChip(
                  icon: '📷',
                  label: '影像创作',
                  onTap: () => applyPreset('影像创作', setLocal),
                ),
                _presetChip(
                  icon: '🎮',
                  label: '游戏兴趣',
                  onTap: () => applyPreset('游戏兴趣', setLocal),
                ),
                _presetChip(
                  icon: '📚',
                  label: '学习办公',
                  onTap: () => applyPreset('学习办公', setLocal),
                ),
                _presetChip(
                  icon: '👕',
                  label: '穿搭配饰',
                  onTap: () => applyPreset('穿搭配饰', setLocal),
                ),
                _presetChip(
                  icon: '🏠',
                  label: '家居生活',
                  onTap: () => applyPreset('家居生活', setLocal),
                ),
                _presetChip(
                  icon: '🚗',
                  label: '出行交通',
                  onTap: () => applyPreset('出行交通', setLocal),
                ),
                _presetChip(
                  icon: '🏃',
                  label: '健康运动',
                  onTap: () => applyPreset('健康运动', setLocal),
                ),
                _presetChip(
                  icon: '🧰',
                  label: '工具维修',
                  onTap: () => applyPreset('工具维修', setLocal),
                ),
                _presetChip(
                  icon: '⭐',
                  label: '收藏纪念',
                  onTap: () => applyPreset('收藏纪念', setLocal),
                ),
                _presetChip(
                  icon: '💳',
                  label: '软件服务',
                  onTap: () => applyPreset('软件服务', setLocal),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const SectionLabel('图标'),
            _smartIconPicker(
              value: iconValue,
              onChanged: (v) => setLocal(() {
                iconValue = v;
                manualIcon = true;
              }),
            ),
            const SizedBox(height: 10),
            _customIconInput(
              value: iconValue,
              onChanged: (v) => setLocal(() {
                iconValue = v;
                manualIcon = true;
              }),
            ),
            const SizedBox(height: 14),
            const SectionLabel('颜色'),
            _smartColorPicker(
              context: sheetContext,
              value: colorValue,
              onChanged: (v) => setLocal(() {
                colorValue = v;
                manualColor = true;
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final label = ctl.text.trim().isEmpty
                      ? '新分类'
                      : ctl.text.trim();
                  final now = DateTime.now().toIso8601String();
                  final id = newId('cat');
                  context.store.upsertCategory(
                    Category(
                      id: id,
                      name: label,
                      icon: iconValue,
                      color: colorValue,
                      sortOrder: context.store.categories.length,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
                  successHaptic();
                  Navigator.pop(sheetContext);
                  onCreated?.call(id);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('创建并选中'),
              ),
            ),
          ],
        );
      },
    ),
  );
}

void showSmartTagCreateSheet(
  BuildContext context, {
  String? initialName,
  ValueChanged<String>? onCreated,
}) {
  final ctl = TextEditingController(text: initialName?.trim() ?? '');
  var colorValue = _suggestColor(ctl.text);
  var manualColor = false;

  void applyPreset(String label, void Function(void Function()) setLocal) {
    ctl.text = label;
    setLocal(() {
      colorValue = _suggestColor(label);
      manualColor = false;
    });
  }

  appSheet(
    context,
    title: '新增标签',
    subtitle: '不用手动输入颜色，直接从色板选择。',
    child: StatefulBuilder(
      builder: (sheetContext, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: parseColor(colorValue),
                  child: const Icon(
                    Icons.sell_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: ctl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: '标签名称，例如 通勤 / 收藏 / 维修',
                    ),
                    onChanged: (v) => setLocal(() {
                      if (!manualColor) colorValue = _suggestColor(v);
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetChip(
                  icon: '🚇',
                  label: '通勤',
                  onTap: () => applyPreset('通勤', setLocal),
                ),
                _presetChip(
                  icon: '💼',
                  label: '办公',
                  onTap: () => applyPreset('办公', setLocal),
                ),
                _presetChip(
                  icon: '📚',
                  label: '学习',
                  onTap: () => applyPreset('学习', setLocal),
                ),
                _presetChip(
                  icon: '⭐',
                  label: '收藏',
                  onTap: () => applyPreset('收藏', setLocal),
                ),
                _presetChip(
                  icon: '🧰',
                  label: '维修',
                  onTap: () => applyPreset('维修', setLocal),
                ),
                _presetChip(
                  icon: '🕰️',
                  label: '长期持有',
                  onTap: () => applyPreset('长期持有', setLocal),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const SectionLabel('颜色'),
            _smartColorPicker(
              context: sheetContext,
              value: colorValue,
              onChanged: (v) => setLocal(() {
                colorValue = v;
                manualColor = true;
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final label = ctl.text.trim().isEmpty
                      ? '新标签'
                      : ctl.text.trim();
                  final now = DateTime.now().toIso8601String();
                  final id = newId('tag');
                  context.store.upsertTag(
                    Tag(
                      id: id,
                      name: label,
                      color: colorValue,
                      sortOrder: context.store.tags.length,
                      createdAt: now,
                      updatedAt: now,
                    ),
                  );
                  successHaptic();
                  Navigator.pop(sheetContext);
                  onCreated?.call(label);
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('创建并加入'),
              ),
            ),
          ],
        );
      },
    ),
  );
}

void showCategoryManager(BuildContext context) {
  appSheet(
    context,
    title: '分类管理',
    subtitle: '分类建议按大类管理，例如电子数码、影音娱乐、学习办公，而不是为每个手机/电脑单独建类。',
    child: const CategoryManager(),
  );
}

class CategoryManager extends StatefulWidget {
  const CategoryManager({super.key});
  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final name = TextEditingController();
  String selectedIcon = '📦';
  String selectedColor = '#7cc6f2';
  bool manualIcon = false;
  bool manualColor = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void applyNameSuggestion(String value) {
    if (!manualIcon) selectedIcon = _suggestCategoryIcon(value);
    if (!manualColor) selectedColor = _suggestColor(value);
  }

  void applyPreset(String label) {
    name.text = label;
    selectedIcon = _suggestCategoryIcon(label);
    selectedColor = _suggestColor(label);
    manualIcon = false;
    manualColor = false;
    setState(() {});
  }

  void addCategory() {
    final store = context.store;
    final now = DateTime.now().toIso8601String();
    final label = name.text.trim().isEmpty ? '新分类' : name.text.trim();
    store.upsertCategory(
      Category(
        id: newId('cat'),
        name: label,
        icon: selectedIcon,
        color: selectedColor,
        sortOrder: store.categories.length,
        createdAt: now,
        updatedAt: now,
      ),
    );
    name.clear();
    selectedIcon = '📦';
    selectedColor = '#7cc6f2';
    manualIcon = false;
    manualColor = false;
    successHaptic();
    setState(() {});
  }

  void editCategory(Category category) {
    final ctl = TextEditingController(text: category.name);
    var iconValue = category.icon;
    var colorValue = category.color;
    appSheet(
      context,
      title: '编辑分类',
      subtitle: '直接点选图标和颜色，不需要手动输入十六进制色值。',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: parseColor(colorValue),
                    child: Text(
                      iconValue,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: ctl,
                      decoration: const InputDecoration(labelText: '分类名称'),
                      onChanged: (v) => setLocal(() {
                        iconValue = _suggestCategoryIcon(v);
                        colorValue = _suggestColor(v);
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('图标'),
              _smartIconPicker(
                value: iconValue,
                onChanged: (v) => setLocal(() => iconValue = v),
              ),
              const SizedBox(height: 10),
              _customIconInput(
                value: iconValue,
                onChanged: (v) => setLocal(() => iconValue = v),
              ),
              const SizedBox(height: 14),
              const SectionLabel('颜色'),
              _smartColorPicker(
                context: context,
                value: colorValue,
                onChanged: (v) => setLocal(() => colorValue = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.store.upsertCategory(
                      category.copyWith(
                        name: ctl.text.trim().isEmpty
                            ? category.name
                            : ctl.text.trim(),
                        icon: iconValue,
                        color: colorValue,
                      ),
                    );
                    Navigator.pop(context);
                    setState(() {});
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('保存分类'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withOpacity(.05)
                : const Color(0xFFF6F9FC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.store.applyRecommendedCategorySystem();
                    successHaptic();
                    setState(() {});
                    showNativeSnack(context, '已应用推荐大类，并迁移手机/电脑等旧小类');
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('应用推荐分类体系'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: parseColor(selectedColor),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Text(
                      selectedIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: '分类名称，例如 电子数码 / 学习办公 / 家居生活',
                      ),
                      onChanged: (v) => setState(() => applyNameSuggestion(v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: addCategory, child: const Text('添加')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(
                    icon: '💻',
                    label: '电子数码',
                    onTap: () => applyPreset('电子数码'),
                  ),
                  _presetChip(
                    icon: '🎧',
                    label: '影音娱乐',
                    onTap: () => applyPreset('影音娱乐'),
                  ),
                  _presetChip(
                    icon: '📷',
                    label: '影像创作',
                    onTap: () => applyPreset('影像创作'),
                  ),
                  _presetChip(
                    icon: '🎮',
                    label: '游戏兴趣',
                    onTap: () => applyPreset('游戏兴趣'),
                  ),
                  _presetChip(
                    icon: '📚',
                    label: '学习办公',
                    onTap: () => applyPreset('学习办公'),
                  ),
                  _presetChip(
                    icon: '👕',
                    label: '穿搭配饰',
                    onTap: () => applyPreset('穿搭配饰'),
                  ),
                  _presetChip(
                    icon: '🏠',
                    label: '家居生活',
                    onTap: () => applyPreset('家居生活'),
                  ),
                  _presetChip(
                    icon: '🚗',
                    label: '出行交通',
                    onTap: () => applyPreset('出行交通'),
                  ),
                  _presetChip(
                    icon: '🏃',
                    label: '健康运动',
                    onTap: () => applyPreset('健康运动'),
                  ),
                  _presetChip(
                    icon: '🧰',
                    label: '工具维修',
                    onTap: () => applyPreset('工具维修'),
                  ),
                  _presetChip(
                    icon: '⭐',
                    label: '收藏纪念',
                    onTap: () => applyPreset('收藏纪念'),
                  ),
                  _presetChip(
                    icon: '💳',
                    label: '软件服务',
                    onTap: () => applyPreset('软件服务'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('直接选图标'),
              _smartIconPicker(
                value: selectedIcon,
                onChanged: (v) => setState(() {
                  selectedIcon = v;
                  manualIcon = true;
                }),
              ),
              const SizedBox(height: 10),
              _customIconInput(
                value: selectedIcon,
                onChanged: (v) => setState(() {
                  selectedIcon = v;
                  manualIcon = true;
                }),
              ),
              const SizedBox(height: 14),
              const SectionLabel('直接选颜色'),
              _smartColorPicker(
                context: context,
                value: selectedColor,
                onChanged: (v) => setState(() {
                  selectedColor = v;
                  manualColor = true;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('已有分类'),
        if (store.categories.isEmpty)
          const Text('还没有分类。', style: TextStyle(color: kMuted)),
        ...store.categories.map(
          (c) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: parseColor(c.color).withOpacity(.92),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(c.icon, style: const TextStyle(fontSize: 21)),
            ),
            title: Text(
              c.name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Text(c.color),
            onTap: () => editCategory(c),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => editCategory(c),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => setState(() => store.deleteCategory(c.id)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showTagManager(BuildContext context) {
  appSheet(
    context,
    title: '标签管理',
    subtitle: '标签适合描述场景，例如通勤、收藏、办公、长期持有。现在可以直接选颜色。',
    child: const TagManager(),
  );
}

class TagManager extends StatefulWidget {
  const TagManager({super.key});
  @override
  State<TagManager> createState() => _TagManagerState();
}

class _TagManagerState extends State<TagManager> {
  final name = TextEditingController();
  String selectedColor = '#7cc6f2';
  bool manualColor = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void applyPreset(String label) {
    name.text = label;
    selectedColor = _suggestColor(label);
    manualColor = false;
    setState(() {});
  }

  void addTag() {
    final store = context.store;
    final label = name.text.trim().isEmpty ? '新标签' : name.text.trim();
    final now = DateTime.now().toIso8601String();
    store.upsertTag(
      Tag(
        id: newId('tag'),
        name: label,
        color: selectedColor,
        sortOrder: store.tags.length,
        createdAt: now,
        updatedAt: now,
      ),
    );
    name.clear();
    selectedColor = '#7cc6f2';
    manualColor = false;
    successHaptic();
    setState(() {});
  }

  void editTag(Tag tag) {
    final ctl = TextEditingController(text: tag.name);
    var colorValue = tag.color;
    appSheet(
      context,
      title: '编辑标签',
      subtitle: '直接选择颜色即可。',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: parseColor(colorValue),
                    child: const Icon(
                      Icons.sell_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: ctl,
                      decoration: const InputDecoration(labelText: '标签名称'),
                      onChanged: (v) =>
                          setLocal(() => colorValue = _suggestColor(v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('颜色'),
              _smartColorPicker(
                context: context,
                value: colorValue,
                onChanged: (v) => setLocal(() => colorValue = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.store.upsertTag(
                      tag.copyWith(
                        name: ctl.text.trim().isEmpty
                            ? tag.name
                            : ctl.text.trim(),
                        color: colorValue,
                      ),
                    );
                    Navigator.pop(context);
                    setState(() {});
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('保存标签'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withOpacity(.05)
                : const Color(0xFFF6F9FC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: parseColor(selectedColor),
                    child: const Icon(
                      Icons.sell_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: '标签名称，例如 通勤 / 收藏 / 办公',
                      ),
                      onChanged: (v) => setState(() {
                        if (!manualColor) selectedColor = _suggestColor(v);
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: addTag, child: const Text('添加')),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(
                    icon: '🚇',
                    label: '通勤',
                    onTap: () => applyPreset('通勤'),
                  ),
                  _presetChip(
                    icon: '💼',
                    label: '办公',
                    onTap: () => applyPreset('办公'),
                  ),
                  _presetChip(
                    icon: '📚',
                    label: '学习',
                    onTap: () => applyPreset('学习'),
                  ),
                  _presetChip(
                    icon: '⭐',
                    label: '收藏',
                    onTap: () => applyPreset('收藏'),
                  ),
                  _presetChip(
                    icon: '🧰',
                    label: '维修',
                    onTap: () => applyPreset('维修'),
                  ),
                  _presetChip(
                    icon: '🕰️',
                    label: '长期持有',
                    onTap: () => applyPreset('长期持有'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const SectionLabel('直接选颜色'),
              _smartColorPicker(
                context: context,
                value: selectedColor,
                onChanged: (v) => setState(() {
                  selectedColor = v;
                  manualColor = true;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('已有标签'),
        if (store.tags.isEmpty)
          const Text('还没有标签。', style: TextStyle(color: kMuted)),
        ...store.tags.map(
          (t) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: parseColor(t.color),
              child: const Icon(
                Icons.sell_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            title: Text(
              t.name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Text(t.color),
            onTap: () => editTag(t),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => editTag(t),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => setState(() => store.deleteTag(t.id)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showBackupManager(BuildContext context) {
  appSheet(
    context,
    title: '备份与恢复',
    subtitle: '推荐使用完整资料包 ZIP 迁移；JSON 只包含文字数据，不包含封面/贴纸图片。',
    child: BackupManager(),
  );
}

class BackupManager extends StatefulWidget {
  const BackupManager({super.key});
  @override
  State<BackupManager> createState() => _BackupManagerState();
}

class _BackupManagerState extends State<BackupManager> {
  final importCtl = TextEditingController();

  @override
  void dispose() {
    importCtl.dispose();
    super.dispose();
  }

  void renameSnapshot(SnapshotRecord record) {
    final ctl = TextEditingController(text: record.label);
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('重命名快照'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(labelText: '快照名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              context.store.renameSnapshot(record.id, ctl.text);
              Navigator.pop(d);
              setState(() {});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void confirmDeleteSnapshot(SnapshotRecord record) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('删除快照'),
        content: Text('确定删除「${record.label}」吗？这个操作不会影响当前资产数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              context.store.deleteSnapshot(record.id);
              Navigator.pop(d);
              setState(() {});
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void restoreSnapshot(SnapshotRecord record) {
    final ok = context.store.restoreSnapshot(record);
    showNativeSnack(context, ok ? '已恢复快照' : '快照损坏');
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async => shareCompleteDataArchive(context),
            icon: const Icon(Icons.archive_rounded),
            label: const Text('分享完整资料包 ZIP'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async => restoreDataArchiveFromPicker(context),
            icon: const Icon(Icons.unarchive_rounded),
            label: const Text('从完整资料包 ZIP 恢复'),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await NativeBridge.writeClipboard(store.exportJson());
                  if (context.mounted) showNativeSnack(context, 'JSON 已复制到剪贴板');
                },
                child: const Text('复制 JSON'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  store.createSnapshot('本机快照 ${dateText(DateTime.now())}');
                  setState(() {});
                },
                child: const Text('创建快照'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final uri = await NativeBridge.exportTextFile(
                    fileName: 'valora_backup_${dateStamp()}.json',
                    text: store.exportJson(),
                    mimeType: 'application/json',
                  );
                  if (context.mounted)
                    showNativeSnack(
                      context,
                      uri == null ? '导出已取消或失败' : '已导出到系统文件',
                    );
                },
                child: const Text('保存 JSON'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await NativeBridge.shareText(
                    title: '值谱 JSON 备份',
                    text: store.exportJson(),
                  );
                },
                child: const Text('分享 JSON'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final text = await NativeBridge.importTextFile(
                mimeType: 'application/json',
              );
              if (text != null) setState(() => importCtl.text = text);
            },
            icon: const Icon(Icons.file_open_rounded),
            label: const Text('从系统文件选择 JSON（纯数据）'),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: importCtl,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: '粘贴 JSON 后覆盖恢复（不含图片）'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            final ok = store.restoreFromJson(importCtl.text);
            showNativeSnack(context, ok ? '恢复成功' : 'JSON 格式不正确');
            if (ok) Navigator.pop(context);
          },
          child: const Text('覆盖恢复'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: SectionLabel('本机快照')),
            if (store.snapshots.isNotEmpty)
              Text(
                '${store.snapshots.length} 份',
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
          ],
        ),
        if (store.snapshots.isEmpty)
          const Text(
            '还没有快照。创建后可以在这里恢复、重命名或删除。',
            style: TextStyle(color: kMuted),
          ),
        ...store.snapshots.map(
          (s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBrand.withOpacity(.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.history_rounded, color: kBrandStrong),
            ),
            title: Text(
              s.label,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            subtitle: Text(
              '${dateText(s.createdAt)} · ${s.createdAt.hour.toString().padLeft(2, '0')}:${s.createdAt.minute.toString().padLeft(2, '0')}',
            ),
            onTap: () => restoreSnapshot(s),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'restore') restoreSnapshot(s);
                if (value == 'rename') renameSnapshot(s);
                if (value == 'delete') confirmDeleteSnapshot(s);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'restore', child: Text('恢复快照')),
                PopupMenuItem(value: 'rename', child: Text('重命名')),
                PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void confirmReset(BuildContext context) {
  showDialog(
    context: context,
    builder: (d) => AlertDialog(
      title: const Text('清空本地数据'),
      content: const Text('会删除当前资产、心愿、分类、标签和快照，保留一个完全空白的 App。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('取消')),
        FilledButton(
          onPressed: () {
            mediumHaptic();
            context.store.clearAllAndSeed();
            Navigator.pop(d);
          },
          child: const Text('清空'),
        ),
      ],
    ),
  );
}

class TutorialTargetAnchor extends StatefulWidget {
  final String id;
  final Widget child;
  const TutorialTargetAnchor({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  State<TutorialTargetAnchor> createState() => _TutorialTargetAnchorState();
}

class _TutorialTargetAnchorState extends State<TutorialTargetAnchor> {
  final Object _token = Object();

  @override
  void initState() {
    super.initState();
    _scheduleRegister();
  }

  @override
  void didUpdateWidget(covariant TutorialTargetAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _TutorialTargetRegistry.unregister(oldWidget.id, _token);
    }
    _scheduleRegister();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleRegister();
  }

  void _scheduleRegister() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _TutorialTargetRegistry.register(widget.id, _token, context);
    });
  }

  @override
  void dispose() {
    _TutorialTargetRegistry.unregister(widget.id, _token);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleRegister();
    return widget.child;
  }
}

class _TutorialTargetEntry {
  final Object token;
  final BuildContext context;
  final int seq;
  const _TutorialTargetEntry({
    required this.token,
    required this.context,
    required this.seq,
  });
}

class _TutorialTargetRegistry {
  static final Map<String, List<_TutorialTargetEntry>> _entries =
      <String, List<_TutorialTargetEntry>>{};
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static int _seq = 0;

  static void register(String id, Object token, BuildContext context) {
    final list = _entries.putIfAbsent(id, () => <_TutorialTargetEntry>[]);
    final existing = list.indexWhere((e) => identical(e.token, token));
    final entry = _TutorialTargetEntry(
      token: token,
      context: context,
      seq: ++_seq,
    );
    if (existing >= 0) {
      list[existing] = entry;
    } else {
      list.add(entry);
    }
    revision.value++;
  }

  static void unregister(String id, Object token) {
    final list = _entries[id];
    if (list == null) return;
    list.removeWhere((e) => identical(e.token, token));
    if (list.isEmpty) _entries.remove(id);
    revision.value++;
  }

  static _TutorialTargetEntry? _latestVisibleEntry(String id, Size screenSize) {
    final list = _entries[id];
    if (list == null || list.isEmpty) return null;
    final screen = Offset.zero & screenSize;
    final sorted = [...list]..sort((a, b) => b.seq.compareTo(a.seq));
    for (final entry in sorted) {
      final render = entry.context.findRenderObject();
      if (render is! RenderBox ||
          !render.attached ||
          !render.hasSize ||
          render.size.isEmpty)
        continue;
      final topLeft = render.localToGlobal(Offset.zero);
      final rect = topLeft & render.size;
      if (rect.overlaps(screen.inflate(80))) return entry;
    }
    for (final entry in sorted) {
      final render = entry.context.findRenderObject();
      if (render is RenderBox &&
          render.attached &&
          render.hasSize &&
          !render.size.isEmpty)
        return entry;
    }
    return null;
  }

  static Rect? rectFor(String id, Size screenSize) {
    final entry = _latestVisibleEntry(id, screenSize);
    if (entry == null) return null;
    final render = entry.context.findRenderObject();
    if (render is! RenderBox ||
        !render.attached ||
        !render.hasSize ||
        render.size.isEmpty)
      return null;
    return render.localToGlobal(Offset.zero) & render.size;
  }

  static Future<void> ensureVisible(String id, Size screenSize) async {
    final entry = _latestVisibleEntry(id, screenSize);
    if (entry == null) return;
    final render = entry.context.findRenderObject();
    if (render is! RenderBox || !render.attached) return;
    await Scrollable.ensureVisible(
      entry.context,
      duration: const Duration(milliseconds: 310),
      curve: Curves.easeOutCubic,
      alignment: .28,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }
}

enum _TutorialStage {
  shell,
  composeAsset,
  composeWish,
  assetDetail,
  settingsData,
  settingsAppearance,
  settingsSystem,
}

class _TutorialStepData {
  final String title;
  final String subtitle;
  final String hint;
  final IconData icon;
  final Color color;
  final _TutorialStage stage;
  final int tabIndex;
  final String targetId;
  const _TutorialStepData({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.color,
    required this.stage,
    required this.targetId,
    this.tabIndex = 0,
  });
}

Future<void> showOnboardingTutorial(
  BuildContext context, {
  bool markSeen = true,
}) async {
  await Navigator.of(context).push(
    softRoute(
      OnboardingTutorialPage(markSeen: markSeen),
      style: ValoraRouteStyle.plain,
    ),
  );
}

class OnboardingTutorialPage extends StatefulWidget {
  final bool markSeen;
  const OnboardingTutorialPage({super.key, this.markSeen = true});

  @override
  State<OnboardingTutorialPage> createState() => _OnboardingTutorialPageState();
}

class _OnboardingTutorialPageState extends State<OnboardingTutorialPage> {
  late final PageController _pageController;
  int index = 0;
  int activeTab = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: activeTab);
    WidgetsBinding.instance.addPostFrameCallback((_) => _settleCurrentTarget());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_TutorialStepData> _steps(AppStore store) {
    final hasAsset = store.assets.isNotEmpty;
    return <_TutorialStepData>[
      const _TutorialStepData(
        title: '首页总览：直接指向真实卡片',
        subtitle: '顶部资产总览会实时显示资产数量、总资产、日均成本和服役状态比例。',
        hint: '这一步不再使用估算坐标，而是绑定真实 AssetOverviewCard 的位置。',
        icon: Icons.inventory_2_rounded,
        color: Color(0xFF7CC6F2),
        stage: _TutorialStage.shell,
        targetId: 'home.overview',
        tabIndex: 0,
      ),
      const _TutorialStepData(
        title: '筛选、排序和首页视图',
        subtitle: '这里可以切换服役 / 退役 / 卖出，也可以进入排序、筛选和首页展示方式。',
        hint: '高亮框会跟着这一整行真实控件走，不会因为屏幕尺寸变化而偏移。',
        icon: Icons.tune_rounded,
        color: Color(0xFF8FD0F6),
        stage: _TutorialStage.shell,
        targetId: 'home.filters',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: hasAsset ? '资产卡片：点击进入详情' : '资产列表：空状态也是真实界面',
        subtitle: hasAsset
            ? '第一张真实资产卡片会展示名称、状态、总价值、已使用天数和日均成本。'
            : '如果当前还没有资产，教程会指向真实空状态，引导用户从底部加号开始添加。',
        hint: hasAsset
            ? '后续详情页教程会继续使用这条真实资产数据。'
            : '添加第一个资产后，首页卡片和详情页会自动变成可讲解的真实内容。',
        icon: Icons.view_agenda_rounded,
        color: const Color(0xFF9FD8F8),
        stage: _TutorialStage.shell,
        targetId: hasAsset ? 'home.assetCard' : 'home.empty',
        tabIndex: 0,
      ),
      const _TutorialStepData(
        title: '底部 Dock：四个一级页面',
        subtitle: '资产、心愿、分析、设置都从这里切换，Dock 的滑动和震动反馈也在真实组件里完成。',
        hint: '这里高亮的是 LiquidDock 本体，不是教程页临时画出来的导航栏。',
        icon: Icons.space_dashboard_rounded,
        color: Color(0xFFFFDC65),
        stage: _TutorialStage.shell,
        targetId: 'shell.dock',
        tabIndex: 0,
      ),
      const _TutorialStepData(
        title: '底部加号：新增资产 / 心愿',
        subtitle: '加号会根据当前页打开新增资产或新增心愿。教程下一步会进入真实新增页。',
        hint: '按钮位置也由真实 GlassAddButton 注册，不再手算。',
        icon: Icons.add_circle_rounded,
        color: Color(0xFFBDEB7E),
        stage: _TutorialStage.shell,
        targetId: 'shell.addButton',
        tabIndex: 0,
      ),
      const _TutorialStepData(
        title: '新增页：资产 / 心愿切换',
        subtitle: '这里是 ComposePage 的真实分段入口，可以在新增资产和新增心愿之间切换。',
        hint: '教程没有复制一个假表单，而是直接把新增页放到背景里。',
        icon: Icons.segment_rounded,
        color: Color(0xFF7CC6F2),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.tabs',
      ),
      const _TutorialStepData(
        title: '封面、条码、小票 OCR 与贴纸',
        subtitle: '资产新增页的导入栏支持选封面、裁切白框、手动勾勒、AI 贴纸、扫条码和小票 OCR。',
        hint: '这一步指向真实 SmartAssetImportBar，后续你扩展按钮时教程也能跟着组件位置走。',
        icon: Icons.auto_fix_high_rounded,
        color: Color(0xFFAEE6FF),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.import',
      ),
      const _TutorialStepData(
        title: '裁切白框：快速生成统一封面',
        subtitle: '适合商品图、票据图或背景比较干净的照片。用户裁好主体区域后，系统会生成统一白框封面，让首页卡片更整齐。',
        hint: '现在高亮的是“裁切白框”真实按钮，不再只笼统指向整条导入栏。',
        icon: Icons.crop_rounded,
        color: Color(0xFFE8F7FE),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.import.frame',
      ),
      const _TutorialStepData(
        title: '手动勾勒：自己圈出主体',
        subtitle: '适合自动识别不准、背景复杂或想保留特殊轮廓的图片。实时预览会跟着你的勾勒更新，最后生成贴纸感封面。',
        hint: '这一步绑定“手动勾勒”按钮，并说明它不是普通裁剪，而是按路径生成主体轮廓。',
        icon: Icons.gesture_rounded,
        color: Color(0xFFFFDC65),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.import.trace',
      ),
      const _TutorialStepData(
        title: 'AI 贴纸：候选图与实时调整',
        subtitle: 'AI 贴纸会从图片中生成更像贴纸的主体效果，并提供边缘、描边、阴影等预览调节，适合做更精致的资产图标。',
        hint: '这一步绑定“AI 贴纸”入口，用户能明确知道它和选封面、裁切白框、手动勾勒的区别。',
        icon: Icons.auto_awesome_rounded,
        color: Color(0xFFAEE6FF),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.import.ai',
      ),
      const _TutorialStepData(
        title: '价格、购买日期、分类和标签',
        subtitle: '价格会参与总价值和日均成本计算；购买日期支持自然语言输入和日期选择。',
        hint: '这类信息是后续分析页、详情页、日耗目标和资产复盘的基础。',
        icon: Icons.edit_note_rounded,
        color: Color(0xFF8FD0F6),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.meta',
      ),
      const _TutorialStepData(
        title: '附加项目：会影响总价值和日均成本',
        subtitle: '附加项目可以记录配件、维修、升级等费用，并支持购买时间跟随父资产。',
        hint: '这就是你之前强调的“附加项目不是只记录，而是要参与资产价值计算”。',
        icon: Icons.inventory_rounded,
        color: Color(0xFFBDEB7E),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.addons',
      ),
      const _TutorialStepData(
        title: '保存按钮：底部固定主操作',
        subtitle: '新增页的保存按钮固定在底部，方便单手操作。',
        hint: '用户完成录入后，从这里保存为真实资产或心愿。',
        icon: Icons.save_rounded,
        color: Color(0xFFFFDC65),
        stage: _TutorialStage.composeAsset,
        targetId: 'compose.save',
      ),
      const _TutorialStepData(
        title: '新增心愿：同一张真实新增页',
        subtitle: '切到心愿模式后，表单会变成心愿名称、预计价格、分类、标签、备注和封面。',
        hint: '心愿不是简单列表，也有归档、转资产和预算统计，所以教程单独覆盖。',
        icon: Icons.auto_awesome_rounded,
        color: Color(0xFFE8F7FE),
        stage: _TutorialStage.composeWish,
        targetId: 'compose.tabs',
      ),
      const _TutorialStepData(
        title: '心愿封面与贴纸入口',
        subtitle: '心愿模式也可以选择封面、裁切白框、手动勾勒或生成 AI 贴纸。',
        hint: '这一步仍然绑定真实 CoverImportBar。',
        icon: Icons.photo_library_rounded,
        color: Color(0xFFAEE6FF),
        stage: _TutorialStage.composeWish,
        targetId: 'compose.import',
      ),
      const _TutorialStepData(
        title: '心愿页：预算和待购清单',
        subtitle: '心愿页会统计未归档心愿的总预算，也可以从心愿转为资产。',
        hint: '这不是只展示一级页面，而是开始说明每个模块内部的功能块。',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE8F7FE),
        stage: _TutorialStage.shell,
        targetId: 'wish.summary',
        tabIndex: 1,
      ),
      const _TutorialStepData(
        title: '分析页：核心指标',
        subtitle: '分析页会汇总资产总值、平均日耗、累计投入和心愿预算。',
        hint: '点击核心指标可以进入更细的统计解释。',
        icon: Icons.analytics_rounded,
        color: Color(0xFF8998F4),
        stage: _TutorialStage.shell,
        targetId: 'analytics.core',
        tabIndex: 2,
      ),
      const _TutorialStepData(
        title: '分析页：健康度与生命周期',
        subtitle: '这里会基于目标、标签、闲置、二手流转等生成资产健康度和生命周期账本。',
        hint: '后续可以继续把每张分析卡片拆成单独的首次进入引导。',
        icon: Icons.health_and_safety_rounded,
        color: Color(0xFFC8EBFF),
        stage: _TutorialStage.shell,
        targetId: 'analytics.lifecycle',
        tabIndex: 2,
      ),
      if (hasAsset) ...[
        const _TutorialStepData(
          title: '详情页：资产概览',
          subtitle: '详情页顶部展示资产图标、分类、状态、当前总价值、持有时间和日均成本。',
          hint: '这里使用你的第一条真实资产数据，不再用一张教程卡片代替详情页。',
          icon: Icons.badge_rounded,
          color: Color(0xFF7CC6F2),
          stage: _TutorialStage.assetDetail,
          targetId: 'detail.summary',
        ),
        const _TutorialStepData(
          title: '详情页：快捷流转',
          subtitle: '资产可以在服役、退役、卖出之间流转，复盘、净值和日耗会跟着更新。',
          hint: '这一步指向 AssetLifecycleQuickActions 的真实位置。',
          icon: Icons.bolt_rounded,
          color: Color(0xFFFFDC65),
          stage: _TutorialStage.assetDetail,
          targetId: 'detail.flow',
        ),
        const _TutorialStepData(
          title: '详情页：日均成本趋势',
          subtitle: '趋势图会显示已发生摊薄和目标日耗预测，适合判断一件东西是否已经用值。',
          hint: '这类“页面内部功能”不应该被省略，所以现在也纳入教程链路。',
          icon: Icons.show_chart_rounded,
          color: Color(0xFF8998F4),
          stage: _TutorialStage.assetDetail,
          targetId: 'detail.trend',
        ),
      ],
      const _TutorialStepData(
        title: '设置首页：二级菜单入口',
        subtitle: '数据与备份、外观与交互、系统与权限被收束成三个二级菜单，避免一层堆满开关。',
        hint: '设置项小字会完整折行，不再强行省略。',
        icon: Icons.settings_rounded,
        color: Color(0xFFD8E7FF),
        stage: _TutorialStage.shell,
        targetId: 'settings.menu',
        tabIndex: 3,
      ),
      const _TutorialStepData(
        title: '设置首页：快速入口和教程重播',
        subtitle: '分类管理、备份恢复、新手教程等高频操作仍保留在设置首页。',
        hint: '“新手教程”入口会重新播放这一整套真实界面引导。',
        icon: Icons.school_rounded,
        color: Color(0xFFBDEB7E),
        stage: _TutorialStage.shell,
        targetId: 'settings.quick',
        tabIndex: 3,
      ),
      const _TutorialStepData(
        title: '二级菜单：数据与备份',
        subtitle: '这里管理分类、标签、备份恢复、云端同步和完整资料包导出。',
        hint: '二级菜单本身也进入教程，而不是只停留在一级设置页。',
        icon: Icons.storage_rounded,
        color: Color(0xFFC8EBFF),
        stage: _TutorialStage.settingsData,
        targetId: 'settings.subpage.content',
      ),
      const _TutorialStepData(
        title: '二级菜单：外观与交互',
        subtitle: '主题、首页风格、金额格式、时长显示、首页副信息字号、触感反馈和贴纸引擎都在这里。',
        hint: '你提到的小字完整显示、首页副信息字号，就属于这一组。',
        icon: Icons.palette_rounded,
        color: Color(0xFF8998F4),
        stage: _TutorialStage.settingsAppearance,
        targetId: 'settings.subpage.content',
      ),
      const _TutorialStepData(
        title: '二级菜单：系统与权限',
        subtitle: '这里管理 Android 原生能力、权限、通知、小组件、系统设置和云端快捷操作。',
        hint: '二级菜单进入时不会再触发行项目闪动，预测式返回只在真正返回时生效。',
        icon: Icons.settings_applications_rounded,
        color: Color(0xFFFFE2D6),
        stage: _TutorialStage.settingsSystem,
        targetId: 'settings.subpage.content',
      ),
    ];
  }

  Future<void> _close({required bool completed}) async {
    if (_closing) return;
    _closing = true;
    if (widget.markSeen) {
      final store = context.store;
      await store.updateSettings(
        store.settings.copyWith(onboardingCompleted: true),
      );
    }
    if (mounted && Navigator.of(context).canPop()) Navigator.pop(context);
  }

  Future<void> _settleCurrentTarget() async {
    if (!mounted) return;
    final steps = _steps(context.store);
    if (index >= steps.length) return;
    final step = steps[index];
    for (final delay in const [110, 260, 420]) {
      await Future<void>.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      final currentSteps = _steps(context.store);
      if (index >= currentSteps.length ||
          currentSteps[index].targetId != step.targetId ||
          currentSteps[index].stage != step.stage)
        return;
      await _TutorialTargetRegistry.ensureVisible(
        step.targetId,
        MediaQuery.sizeOf(context),
      );
      if (mounted) setState(() {});
    }
  }

  void _goToStep(int next) {
    final steps = _steps(context.store);
    if (next < 0) return;
    if (next >= steps.length) {
      _close(completed: true);
      return;
    }
    final nextStep = steps[next];
    selectionHaptic();
    setState(() {
      index = next;
      if (nextStep.stage == _TutorialStage.shell) {
        activeTab = nextStep.tabIndex.clamp(0, 3).toInt();
      }
    });
    if (nextStep.stage == _TutorialStage.shell) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        _pageController.animateToPage(
          activeTab,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _settleCurrentTarget();
    });
  }

  Widget _buildShellStage() {
    final pages = const [
      AssetHomePage(),
      WishHomePage(),
      AnalyticsHomePage(),
      SettingsHomePage(),
    ];
    return GradientScaffold(
      child: Stack(
        children: [
          if (activeTab == 0)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 380,
              child: HomeTopGradientWash(),
            ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  clipBehavior: Clip.hardEdge,
                  children: pages,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12 + MediaQuery.paddingOf(context).bottom,
                  child: LiquidDock(
                    index: activeTab,
                    onChanged: (_) {},
                    onAdd: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(_TutorialStepData step) {
    switch (step.stage) {
      case _TutorialStage.shell:
        return _buildShellStage();
      case _TutorialStage.composeAsset:
        return const ComposePage(
          initialTab: ComposeTab.asset,
          initialName: '示例资产',
        );
      case _TutorialStage.composeWish:
        return const ComposePage(
          initialTab: ComposeTab.wish,
          initialName: '示例心愿',
        );
      case _TutorialStage.assetDetail:
        final first = context.store.assets.isEmpty
            ? null
            : context.store.assets.first;
        if (first == null)
          return const ComposePage(
            initialTab: ComposeTab.asset,
            initialName: '先添加一个资产',
          );
        return AssetDetailPage(assetId: first.id);
      case _TutorialStage.settingsData:
        return const GradientScaffold(
          child: SettingsHomePage(
            initialTab: _SettingsTab.data,
            asSubPage: true,
          ),
        );
      case _TutorialStage.settingsAppearance:
        return const GradientScaffold(
          child: SettingsHomePage(
            initialTab: _SettingsTab.appearance,
            asSubPage: true,
          ),
        );
      case _TutorialStage.settingsSystem:
        return const GradientScaffold(
          child: SettingsHomePage(
            initialTab: _SettingsTab.system,
            asSubPage: true,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context.store);
    if (index >= steps.length) index = math.max(0, steps.length - 1);
    final step = steps[index];
    return WillPopScope(
      onWillPop: () async {
        await _close(completed: false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: KeyedSubtree(
                key: ValueKey(
                  '${step.stage.name}_${step.stage == _TutorialStage.shell ? activeTab : 0}',
                ),
                child: _buildStage(step),
              ),
            ),
            _MeasuredTutorialOverlay(
              step: step,
              index: index,
              total: steps.length,
              onPrevious: index == 0 ? null : () => _goToStep(index - 1),
              onNext: () => _goToStep(index + 1),
              onSkip: () => _close(completed: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasuredTutorialOverlay extends StatelessWidget {
  final _TutorialStepData step;
  final int index;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const _MeasuredTutorialOverlay({
    required this.step,
    required this.index,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
  });

  Rect _fallbackRect(Size size, EdgeInsets safe) {
    final top = safe.top + 90;
    return Rect.fromLTWH(
      22,
      top,
      size.width - 44,
      math.min(170.0, size.height * .26),
    );
  }

  Rect _targetRect(Size size, EdgeInsets safe) {
    final screen = Offset.zero & size;
    final measured = _TutorialTargetRegistry.rectFor(step.targetId, size);
    if (measured == null || !measured.overlaps(screen.inflate(36))) {
      return _fallbackRect(size, safe);
    }
    final insetScreen = Rect.fromLTWH(
      8,
      safe.top + 6,
      math.max(1.0, size.width - 16),
      math.max(1.0, size.height - safe.top - safe.bottom - 12),
    );
    final clipped = measured.intersect(insetScreen);
    if (clipped.width < 12 || clipped.height < 12)
      return _fallbackRect(size, safe);
    return clipped.inflate(7);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _TutorialTargetRegistry.revision,
      builder: (context, _, __) {
        final size = MediaQuery.sizeOf(context);
        final safe = MediaQuery.paddingOf(context);
        final target = _targetRect(size, safe);
        final bubbleHeight = math.min(286.0, size.height * .40);
        final belowTop = target.bottom + 18;
        final canPlaceBelow =
            belowTop + bubbleHeight < size.height - safe.bottom - 12;
        final bubbleTop = canPlaceBelow
            ? belowTop
            : math
                  .max(safe.top + 16, target.top - bubbleHeight - 18)
                  .toDouble();
        final bubbleBottomMode =
            !canPlaceBelow && target.top - bubbleHeight - 18 < safe.top + 16;
        final finalBubbleTop = bubbleBottomMode
            ? size.height - safe.bottom - bubbleHeight - 14
            : bubbleTop;
        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: CustomPaint(
                      painter: _TutorialScrimPainter(
                        target: target,
                        bubbleTop: finalBubbleTop,
                        color: Colors.black.withOpacity(
                          context.isDark ? .60 : .52,
                        ),
                        borderColor: step.color,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: target.left,
                  top: target.top,
                  width: target.width,
                  height: target.height,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: step.color.withOpacity(.96),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: step.color.withOpacity(.30),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  top: finalBubbleTop,
                  child: _TutorialBubble(
                    step: step,
                    index: index,
                    total: total,
                    onPrevious: onPrevious,
                    onNext: onNext,
                    onSkip: onSkip,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TutorialScrimPainter extends CustomPainter {
  final Rect target;
  final double bubbleTop;
  final Color color;
  final Color borderColor;
  const _TutorialScrimPainter({
    required this.target,
    required this.bubbleTop,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(target, const Radius.circular(24)));
    final overlay = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(overlay, Paint()..color = color);

    final targetCenter = target.center;
    final bubbleCenterY = bubbleTop + 18;
    final lineEnd = Offset(size.width / 2, bubbleCenterY);
    final paint = Paint()
      ..color = borderColor.withOpacity(.78)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final start = targetCenter.dy < bubbleTop
        ? Offset(targetCenter.dx, target.bottom + 3)
        : Offset(targetCenter.dx, target.top - 3);
    canvas.drawLine(start, lineEnd, paint);
    canvas.drawCircle(
      start,
      4.2,
      Paint()..color = borderColor.withOpacity(.95),
    );
  }

  @override
  bool shouldRepaint(covariant _TutorialScrimPainter oldDelegate) {
    return oldDelegate.target != target ||
        oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.bubbleTop != bubbleTop;
  }
}

class _TutorialBubble extends StatelessWidget {
  final _TutorialStepData step;
  final int index;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  const _TutorialBubble({
    required this.step,
    required this.index,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final isLast = index >= total - 1;
    final media = MediaQuery.of(context);
    final maxBubbleHeight = math.min(
      372.0,
      media.size.height - media.padding.top - media.padding.bottom - 36,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: math.max(220.0, maxBubbleHeight)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
              decoration: BoxDecoration(
                color: dark
                    ? kCardDark.withOpacity(.92)
                    : Colors.white.withOpacity(.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: dark
                      ? Colors.white.withOpacity(.10)
                      : Colors.white.withOpacity(.75),
                ),
                boxShadow: [softShadow(context)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: step.color.withOpacity(dark ? .22 : .28),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          step.icon,
                          color: dark
                              ? Colors.white.withOpacity(.92)
                              : kBrandInk,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '第 ${index + 1} / $total 步',
                              style: const TextStyle(
                                color: kMuted,
                                fontSize: 12,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.12,
                                fontWeight: FontWeight.normal,
                                letterSpacing: -.25,
                                color: dark
                                    ? Colors.white.withOpacity(.94)
                                    : kText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(onPressed: onSkip, child: const Text('跳过')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      color: dark
                          ? Colors.white.withOpacity(.79)
                          : kText.withOpacity(.77),
                      fontSize: 13.2,
                      height: 1.45,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(dark ? .13 : .15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      step.hint,
                      style: TextStyle(
                        color: dark
                            ? Colors.white.withOpacity(.79)
                            : const Color(0xFF315168),
                        fontSize: 12.2,
                        height: 1.42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: List.generate(total, (i) {
                      final active = i == index;
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: active
                                ? step.color
                                : (dark
                                      ? Colors.white12
                                      : const Color(0xFFE7EEF5)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('上一步'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onNext,
                          icon: Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.chevron_right_rounded,
                          ),
                          label: Text(isLast ? '完成教程' : '下一步'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
