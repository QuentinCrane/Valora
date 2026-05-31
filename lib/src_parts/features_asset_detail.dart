part of '../main.dart';

class AssetDetailPage extends StatelessWidget {
  final String assetId;
  const AssetDetailPage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final asset = store.assets
        .where((a) => a.id == assetId)
        .cast<Asset?>()
        .firstOrNull;
    if (asset == null) return const MissingPage(title: '资产不存在');
    final category = store.categoryById(asset.categoryId);
    return GradientScaffold(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PageFrame(
              padding: const EdgeInsets.fromLTRB(kPagePad, 72, kPagePad, 30),
              children: [
                TutorialTargetAnchor(
                  id: 'detail.summary',
                  child: AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AssetIcon(asset: asset, size: 78),
                        const SizedBox(height: 12),
                        Text(
                          asset.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${category?.name ?? '未分类'} · ${asset.status.label}',
                          style: const TextStyle(color: kMuted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          money(asset.totalDisplayValue, store.settings),
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DetailMini(
                                label: '持有时间',
                                value: durationWithCalendarText(
                                  asset.serviceDays,
                                  store.settings.durationMode,
                                ),
                                onTap: () => showHoldingTimeExplanation(
                                  context,
                                  asset,
                                  store,
                                ),
                              ),
                            ),
                            Expanded(
                              child: DetailMini(
                                label: '日均成本',
                                value:
                                    '${money(asset.dailyCost, store.settings)} /天',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TutorialTargetAnchor(
                  id: 'detail.flow',
                  child: AssetLifecycleQuickActions(asset: asset, store: store),
                ),
                const SizedBox(height: 12),
                TutorialTargetAnchor(
                  id: 'detail.trend',
                  child: ChartPanel(
                    title: '日均成本趋势',
                    subtitle: '实线是已发生摊薄，虚线按日耗目标预测未来走势；横向虚线是目标日耗。',
                    onTap: () => showAssetTrendGuide(context, asset, store),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 190,
                          child: DailyCostTrendChart(asset: asset),
                        ),
                        const SizedBox(height: 10),
                        TrendExplainRow(asset: asset),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TutorialTargetAnchor(
                  id: 'detail.replay',
                  child: AssetValueReplayCard(asset: asset, store: store),
                ),
                const SizedBox(height: 12),
                TutorialTargetAnchor(
                  id: 'detail.target',
                  child: AppCard(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '日耗目标',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '${money(asset.dailyCost, store.settings)}/天',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TargetProgressBar(
                          ratio: asset.targetRatio,
                          label: asset.targetMode == TargetMode.none
                              ? '还没有设置日耗目标'
                              : asset.targetMode == TargetMode.daily
                              ? '目标 ${money(asset.targetDailyCost ?? 0, store.settings)} /天'
                              : '目标模式：${asset.targetMode.label}',
                        ),
                        const SizedBox(height: 10),
                        GridWrap(
                          children: [
                            DetailCell(
                              label: '当前日耗',
                              value: money(asset.dailyCost, store.settings),
                            ),
                            DetailCell(
                              label: '目标天数',
                              value: asset.targetDays == null
                                  ? '—'
                                  : '${asset.targetDays} 天',
                            ),
                            DetailCell(
                              label: '预计达成',
                              value: asset.estimatedTargetDate == null
                                  ? '—'
                                  : dateText(asset.estimatedTargetDate!),
                            ),
                            DetailCell(
                              label: '剩余天数',
                              value: asset.remainingTargetDays == null
                                  ? '—'
                                  : '${asset.remainingTargetDays} 天',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TutorialTargetAnchor(
                  id: 'detail.records',
                  child: AppCard(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '资产记录',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GridWrap(
                          children: [
                            DetailCell(
                              label: '购买日期',
                              value: dateText(asset.purchaseDate),
                            ),
                            DetailCell(
                              label: '资产本体',
                              value: money(asset.price, store.settings),
                            ),
                            DetailCell(
                              label: '附加计入',
                              value: money(asset.addonTotal, store.settings),
                            ),
                            DetailCell(
                              label: '卖出价',
                              value: asset.soldPrice == null
                                  ? '—'
                                  : money(asset.soldPrice!, store.settings),
                            ),
                            DetailCell(
                              label: '净成本',
                              value: money(asset.netCost, store.settings),
                            ),
                          ],
                        ),
                        if (asset.addons.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const SectionLabel('附加项目'),
                          ...asset.addons.map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.name),
                                        const SizedBox(height: 2),
                                        Text(
                                          '购买时间：${a.effectivePurchaseDateLabel(asset.purchaseDate)}',
                                          style: const TextStyle(
                                            color: kMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    money(a.price, store.settings),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AssetLifecycleEventCard(asset: asset, store: store),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '备注',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(asset.note.isEmpty ? '暂无备注。' : asset.note),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: asset.tagIds
                            .map(
                              (id) => TinyTag(
                                label: store.tagById(id)?.name ?? id,
                                color: parseColor(
                                  store.tagById(id)?.color ?? '#7cc6f2',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GlobalBackButton(onTap: () => Navigator.pop(context)),
            Positioned(
              right: 16,
              top: 16,
              child: Row(
                children: [
                  HeaderIcon(
                    icon: Icons.edit_rounded,
                    onTap: () => Navigator.of(
                      context,
                    ).push(softRoute(AssetEditorPage(initial: asset))),
                  ),
                  const SizedBox(width: 8),
                  HeaderIcon(
                    icon: Icons.delete_outline_rounded,
                    onTap: () => confirmDeleteAsset(context, asset),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetLifecycleQuickActions extends StatelessWidget {
  final Asset asset;
  final AppStore store;
  const AssetLifecycleQuickActions({
    super.key,
    required this.asset,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt_rounded, color: kBrandStrong),
              SizedBox(width: 8),
              Text(
                '快捷流转',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '把资产从“服役—退役—卖出”串成闭环，日耗和复盘会自动更新。',
            style: TextStyle(color: kMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (asset.status != AssetStatus.serving)
                OutlinedButton.icon(
                  onPressed: () {
                    tapHaptic();
                    store.markAssetServing(asset.id);
                    showNativeSnack(context, '已恢复为服役中');
                  },
                  icon: const Icon(Icons.play_circle_fill_rounded),
                  label: const Text('恢复服役'),
                ),
              if (asset.status == AssetStatus.serving)
                OutlinedButton.icon(
                  onPressed: () {
                    tapHaptic();
                    store.markAssetRetired(asset.id);
                    showNativeSnack(context, '已标记为退役');
                  },
                  icon: const Icon(Icons.archive_rounded),
                  label: const Text('标记退役'),
                ),
              if (asset.status != AssetStatus.sold)
                FilledButton.icon(
                  onPressed: () => showAssetSoldDialog(context, asset, store),
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('记录卖出'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

void showAssetSoldDialog(BuildContext context, Asset asset, AppStore store) {
  final priceCtl = TextEditingController(
    text: asset.soldPrice?.toStringAsFixed(0) ?? '',
  );
  final dateCtl = TextEditingController(
    text: dateText(asset.soldAt ?? DateTime.now()),
  );
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('记录卖出：${asset.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: priceCtl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '卖出价'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dateCtl,
            decoration: const InputDecoration(labelText: '卖出日期 YYYY-MM-DD'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            mediumHaptic();
            final parsedSoldDate = parseUserDateOrNull(dateCtl.text);
            if (parsedSoldDate == null) {
              showNativeSnack(context, '卖出日期格式不正确');
              return;
            }
            store.markAssetSold(
              asset.id,
              soldAt: parsedSoldDate,
              soldPrice: asDouble(priceCtl.text),
            );
            Navigator.pop(dialogContext);
            showNativeSnack(context, '已记录卖出，资产复盘已更新');
          },
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

class AssetValueReplayCard extends StatelessWidget {
  final Asset asset;
  final AppStore store;
  const AssetValueReplayCard({
    super.key,
    required this.asset,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final soldRecovered = asset.status == AssetStatus.sold
        ? (asset.soldPrice ?? 0)
        : 0.0;
    final earningRecovered = store.getAssetRecoveryIncome(asset.id);
    final recovered = soldRecovered + earningRecovered;
    final consumed = store.getAssetNetConsumptionAfterRecovery(asset);
    final maxValue = math.max(asset.price + asset.dailyAddonTotal, 1);
    final recoveredRatio = (recovered / maxValue).clamp(0, 1).toDouble();
    final consumedRatio = (consumed / maxValue).clamp(0, 1).toDouble();
    final records = store.recoveryRecordsForAsset(asset.id);
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '价值回收',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    showRecoveryRecordSheet(context, store, seedAsset: asset),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('记录收益'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '除了二手卖出，也可以把一组资产实际带来的收入记入回收，例如拍摄接单、游戏设备直播收益、工具维修收入等。',
            style: TextStyle(color: kMuted, height: 1.32, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TargetProgressBar(
                  ratio: consumedRatio,
                  label: '净消耗 ${money(consumed, store.settings)}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TargetProgressBar(
                  ratio: recoveredRatio,
                  label: '已回收 ${money(recovered, store.settings)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridWrap(
            children: [
              DetailCell(
                label: '总投入',
                value: money(
                  asset.price + asset.dailyAddonTotal,
                  store.settings,
                ),
              ),
              DetailCell(
                label: '二手回收',
                value: money(soldRecovered, store.settings),
              ),
              DetailCell(
                label: '使用收益',
                value: money(earningRecovered, store.settings),
              ),
              DetailCell(
                label: '回收后日耗',
                value:
                    '${money(consumed / math.max(asset.serviceDays, 1), store.settings)} /天',
              ),
            ],
          ),
          if (records.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...records
                .take(3)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${dateText(r.date)} · ${r.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                        Text(
                          money(
                            r.amount / math.max(r.assetIds.length, 1),
                            store.settings,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

void showRecoveryRecordSheet(
  BuildContext context,
  AppStore store, {
  Asset? seedAsset,
}) {
  final titleCtl = TextEditingController(
    text: seedAsset == null ? '使用收益' : '${seedAsset.name} 带来的收益',
  );
  final amountCtl = TextEditingController();
  final dateCtl = TextEditingController(text: dateText(DateTime.now()));
  final noteCtl = TextEditingController();
  final selected = <String>{if (seedAsset != null) seedAsset.id};
  appSheet(
    context,
    title: '记录价值回收',
    subtitle: '选择参与产生收益的资产，并记录它们实际赚回来的金额。多件资产会在详情页里均摊显示。',
    child: StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppField(controller: titleCtl, label: '收益名称'),
            const SizedBox(height: 10),
            AppField(controller: amountCtl, label: '收益金额', number: true),
            const SizedBox(height: 10),
            DateFormField(controller: dateCtl, label: '收益日期'),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            const SizedBox(height: 12),
            const SectionLabel('参与资产'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.assets.map((asset) {
                final active = selected.contains(asset.id);
                return FilterChip(
                  selected: active,
                  avatar: SizedBox(
                    width: 24,
                    height: 24,
                    child: valoraIconVisual(
                      context,
                      asset.iconValue,
                      emojiSize: 14,
                      borderRadius: 9,
                    ),
                  ),
                  label: Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onSelected: (v) => setLocal(() {
                    if (v) {
                      selected.add(asset.id);
                    } else {
                      selected.remove(asset.id);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final amount = asDouble(amountCtl.text);
                      final parsedDate = parseUserDateOrNull(dateCtl.text);
                      if (amount <= 0) {
                        showNativeSnack(context, '请输入大于 0 的收益金额');
                        return;
                      }
                      if (selected.isEmpty) {
                        showNativeSnack(context, '至少选择一件资产');
                        return;
                      }
                      if (parsedDate == null) {
                        showNativeSnack(context, '收益日期格式不正确');
                        return;
                      }
                      await store.addRecoveryRecord(
                        ValueRecoveryRecord(
                          id: newId('recovery'),
                          title: titleCtl.text.trim().isEmpty
                              ? '使用收益'
                              : titleCtl.text.trim(),
                          assetIds: selected.toList(),
                          amount: amount,
                          date: parsedDate,
                          note: noteCtl.text.trim(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                      if (context.mounted)
                        showNativeSnack(context, '已记录价值回收收益');
                    },
                    icon: const Icon(Icons.savings_rounded),
                    label: const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

class AssetLifecycleEventCard extends StatelessWidget {
  final Asset asset;
  final AppStore store;
  const AssetLifecycleEventCard({
    super.key,
    required this.asset,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final events = <({DateTime date, String title, String subtitle, IconData icon, Color color})>[
      (
        date: asset.purchaseDate,
        title: '买入',
        subtitle:
            '${dateText(asset.purchaseDate)} · ${money(asset.price, store.settings)}',
        icon: Icons.add_circle_rounded,
        color: kBrandStrong,
      ),
      if (asset.expiresAt != null)
        (
          date: asset.expiresAt!,
          title: '到期/保修节点',
          subtitle:
              '${dateText(asset.expiresAt!)} · 提前 ${asset.remindBeforeDays ?? 0} 天提醒',
          icon: Icons.event_available_rounded,
          color: const Color(0xFFFFB020),
        ),
      if (asset.retiredAt != null)
        (
          date: asset.retiredAt!,
          title: '退役',
          subtitle:
              '${dateText(asset.retiredAt!)} · 持有 ${durationWithCalendarText(asset.serviceDays, store.settings.durationMode)}',
          icon: Icons.archive_rounded,
          color: const Color(0xFFFF8A65),
        ),
      if (asset.soldAt != null)
        (
          date: asset.soldAt!,
          title: '卖出',
          subtitle:
              '${dateText(asset.soldAt!)} · 回收 ${money(asset.soldPrice ?? 0, store.settings)}',
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFF4ADE80),
        ),
      ...store
          .recoveryRecordsForAsset(asset.id)
          .map(
            (r) => (
              date: r.date,
              title: '使用收益',
              subtitle:
                  '${dateText(r.date)} · ${r.title} · 分摊 ${money(r.amount / math.max(r.assetIds.length, 1), store.settings)}',
              icon: Icons.savings_rounded,
              color: const Color(0xFF22C55E),
            ),
          ),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '资产时间线',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: event.color.withOpacity(.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(event.icon, color: event.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.subtitle,
                          style: const TextStyle(color: kMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showHoldingTimeExplanation(
  BuildContext context,
  Asset asset,
  AppStore store,
) {
  final endDate = asset.serviceEndDate;
  final endLabel = asset.status == AssetStatus.serving
      ? '今天'
      : asset.status == AssetStatus.sold
      ? '卖出日期'
      : '退役日期';
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('持有时间说明'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('购买日期：${dateText(asset.purchaseDate)}'),
          const SizedBox(height: 6),
          Text('$endLabel：${dateText(endDate)}'),
          const SizedBox(height: 6),
          Text('原始天数：${asset.serviceDays} 天'),
          const SizedBox(height: 6),
          Text(
            '当前显示：${durationWithCalendarText(asset.serviceDays, store.settings.durationMode)}',
          ),
          const SizedBox(height: 12),
          const Text(
            '计算方式：从购买日期到当前日期、退役日期或卖出日期，按包含首尾日期的方式统计。你可以在“设置 - 外观交互 - 时长显示”里切换天、周、月或年/月显示。',
            style: TextStyle(color: kMuted, fontSize: 12, height: 1.45),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('知道了'),
        ),
      ],
    ),
  );
}

void confirmDeleteAsset(BuildContext context, Asset asset) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('删除资产'),
      content: Text('确认删除「${asset.name}」吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            context.store.deleteAsset(asset.id);
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
          child: const Text('删除'),
        ),
      ],
    ),
  );
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class DetailMini extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const DetailMini({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  IconData get _icon {
    if (label.contains('日均')) return Icons.speed_rounded;
    if (label.contains('时长') || label.contains('服役') || label.contains('持有'))
      return Icons.timeline_rounded;
    return Icons.insights_rounded;
  }

  Color get _color {
    if (label.contains('日均')) return const Color(0xFFFFB15C);
    if (label.contains('时长') || label.contains('服役') || label.contains('持有'))
      return const Color(0xFF7CC6F2);
    return kBrandStrong;
  }

  double get _progressValue {
    if (label.contains('日均')) return .64;
    if (label.contains('时长') || label.contains('服役') || label.contains('持有'))
      return .48;
    return .54;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withOpacity(.052)
            : Colors.white.withOpacity(.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(dark ? .30 : .20)),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(dark ? .10 : .08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 46,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon, size: 15, color: _color),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kMuted,
                          fontSize: 11.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15.5,
                    height: 1.0,
                    letterSpacing: -.15,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 5,
                    backgroundColor: dark
                        ? Colors.white.withOpacity(.10)
                        : const Color(0xFFE8EEF3),
                    color: _color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: content,
    );
  }
}

class GridWrap extends StatelessWidget {
  final List<Widget> children;
  const GridWrap({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const spacing = 8.0;
        final columns = c.maxWidth >= 680 ? 4 : 2;
        final width = (c.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map((e) => SizedBox(width: width, child: e))
              .toList(),
        );
      },
    );
  }
}

class DetailCell extends StatelessWidget {
  final String label;
  final String value;
  const DetailCell({super.key, required this.label, required this.value});

  IconData get _icon {
    if (label.contains('日期') || label.contains('达成'))
      return Icons.event_rounded;
    if (label.contains('价') || label.contains('成本') || label.contains('日耗'))
      return Icons.payments_rounded;
    if (label.contains('天')) return Icons.schedule_rounded;
    return Icons.radio_button_checked_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final accent = label.contains('日耗')
        ? const Color(0xFFFFB15C)
        : label.contains('日期') || label.contains('达成')
        ? const Color(0xFF7CC6F2)
        : kBrandStrong;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(.048)
            : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(context.isDark ? .18 : .12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withOpacity(.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 15, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kMuted,
                    fontSize: 11.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13.8,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onTap;
  const ChartPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final content = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: kMuted),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: kMuted)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(kRadiusLg),
      onTap: () {
        tapHaptic();
        onTap!.call();
      },
      child: content,
    );
  }
}

class TrendExplainRow extends StatelessWidget {
  final Asset asset;
  const TrendExplainRow({super.key, required this.asset});
  @override
  Widget build(BuildContext context) {
    final startDaily = asset.netCost;
    final nowDaily = asset.dailyCost;
    final saved = math.max(0.0, startDaily - nowDaily);
    final targetDays = asset.targetDays;
    final targetText = targetDays == null ? '未设目标' : '预测 ${targetDays} 天';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(.045)
            : const Color(0xFFF5FAFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '第 1 天 ${money(startDaily, context.store.settings)}/天',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ),
          Expanded(
            child: Text(
              '现在 ${money(nowDaily, context.store.settings)}/天',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ),
          Expanded(
            child: Text(
              targetText,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ),
        ],
      ),
    );
  }
}

void showAssetTrendGuide(BuildContext context, Asset asset, AppStore store) {
  appSheet(
    context,
    title: '怎么看日均成本趋势',
    subtitle: '这张图不是涨跌行情，而是“买入成本被使用天数摊薄”的过程。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailCell(
          label: '第 1 天日耗',
          value: '${money(asset.netCost, store.settings)} /天',
        ),
        const SizedBox(height: 8),
        DetailCell(
          label: '当前日耗',
          value: '${money(asset.dailyCost, store.settings)} /天',
        ),
        const SizedBox(height: 8),
        DetailCell(
          label: '持有时间',
          value: durationWithCalendarText(
            asset.serviceDays,
            store.settings.durationMode,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '理解方式：实线表示已经发生的摊薄，虚线会按目标日耗/目标天数推算未来趋势。横向绿色虚线是目标日耗，蓝线到达它时说明这件物品已经达到你设定的心理成本。',
          style: TextStyle(color: kMuted, height: 1.45),
        ),
      ],
    ),
  );
}

class DailyCostTrendChart extends StatelessWidget {
  final Asset asset;
  const DailyCostTrendChart({super.key, required this.asset});

  double? _targetDailyValue() {
    if (asset.targetMode == TargetMode.daily &&
        (asset.targetDailyCost ?? 0) > 0)
      return asset.targetDailyCost;
    final days = asset.targetDays;
    if (days != null && days > 0) return asset.netCost / days;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final nowDays = math.max(asset.serviceDays, 1);
    final targetDays = asset.targetDays;
    final endDays = math.max(nowDays, targetDays ?? nowDays);
    final sampleCount = targetDays != null && targetDays > nowDays ? 34 : 24;
    final values = <double>[];
    int actualCount = 0;
    for (var i = 0; i < sampleCount; i++) {
      final ratio = sampleCount == 1 ? 1.0 : i / (sampleCount - 1);
      final day = math.max(1, (1 + (endDays - 1) * ratio).round());
      values.add(asset.netCost / day);
      if (day <= nowDays) actualCount = i + 1;
    }
    actualCount = actualCount.clamp(1, values.length).toInt();
    return CustomPaint(
      painter: LineChartPainter(
        points: values,
        actualCount: actualCount,
        currentIndex: actualCount - 1,
        currentLabel: '当前',
        targetValue: _targetDailyValue(),
        targetLabel: targetDays == null ? null : '目标 ${targetDays}天',
      ),
      size: Size.infinite,
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> points;
  final int actualCount;
  final int? currentIndex;
  final String? currentLabel;
  final double? targetValue;
  final String? targetLabel;
  LineChartPainter({
    required this.points,
    this.actualCount = 0,
    this.currentIndex,
    this.currentLabel,
    this.targetValue,
    this.targetLabel,
  });

  Offset _pointForValue(
    int i,
    double value,
    Size size,
    double minV,
    double range,
  ) {
    const topPadding = 8.0;
    const bottomPadding = 10.0;
    final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);
    final x = size.width * i / math.max(points.length - 1, 1);
    final y = topPadding + chartHeight - ((value - minV) / range) * chartHeight;
    return Offset(x, y);
  }

  Path _pathForRange(int start, int end, Size size, double minV, double range) {
    final path = Path();
    if (points.isEmpty || start > end) return path;
    final first = _pointForValue(start, points[start], size, minV, range);
    path.moveTo(first.dx, first.dy);
    for (var i = start + 1; i <= end; i++) {
      final p = _pointForValue(i, points[i], size, minV, range);
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dash = 5,
    double gap = 4,
  }) {
    final total = (end - start).distance;
    if (total <= 0) return;
    final direction = (end - start) / total;
    double travelled = 0;
    while (travelled < total) {
      final from = start + direction * travelled;
      final to = start + direction * math.min(travelled + dash, total);
      canvas.drawLine(from, to, paint);
      travelled += dash + gap;
    }
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    Offset point,
    String text,
    Color color, {
    bool above = true,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelWidth = textPainter.width + 14;
    final labelHeight = textPainter.height + 7;
    final left = (point.dx - labelWidth / 2)
        .clamp(2.0, size.width - labelWidth - 2.0)
        .toDouble();
    final desiredTop = above ? point.dy - labelHeight - 12 : point.dy + 8;
    final top = desiredTop
        .clamp(2.0, size.height - labelHeight - 2.0)
        .toDouble();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, labelWidth, labelHeight),
      const Radius.circular(999),
    );
    canvas.drawRRect(rrect, Paint()..color = color.withOpacity(.90));
    textPainter.paint(canvas, Offset(left + 7, top + 3.5));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;
    final scaleValues = [...points, if (targetValue != null) targetValue!];
    final maxV = math.max(scaleValues.reduce(math.max), 1.0);
    final minV = math.max(0.0, scaleValues.reduce(math.min) * .92);
    final range = math.max(maxV - minV, 1.0);
    final grid = Paint()
      ..color = kMuted.withOpacity(0.12)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final actualEnd = math.max(0, math.min(actualCount, points.length) - 1);
    final actualPath = _pathForRange(0, actualEnd, size, minV, range);
    final fill = Path.from(actualPath)
      ..lineTo(
        _pointForValue(actualEnd, points[actualEnd], size, minV, range).dx,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kBrand.withOpacity(.34),
            kBrand.withOpacity(.14),
            kBrand.withOpacity(0),
          ],
          stops: const [0, .52, 1],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    final actualPaint = Paint()
      ..color = kBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(actualPath, actualPaint);

    if (actualEnd < points.length - 1) {
      final forecastPaint = Paint()
        ..color = kBrandStrong.withOpacity(.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (var i = actualEnd; i < points.length - 1; i++) {
        _drawDashedLine(
          canvas,
          _pointForValue(i, points[i], size, minV, range),
          _pointForValue(i + 1, points[i + 1], size, minV, range),
          forecastPaint,
          dash: 7,
          gap: 5,
        );
      }
    }

    if (targetValue != null && targetValue! > 0) {
      final y = _pointForValue(
        0,
        targetValue!,
        size,
        minV,
        range,
      ).dy.clamp(7.0, size.height - 7.0).toDouble();
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0xFF22C55E).withOpacity(.70)
          ..strokeWidth = 1.4,
        dash: 6,
        gap: 5,
      );
      if (targetLabel != null)
        _drawLabel(
          canvas,
          size,
          Offset(size.width - 42, y),
          targetLabel!,
          const Color(0xFF22C55E),
          above: y > size.height * .35,
        );
    }

    final idx = currentIndex == null
        ? null
        : currentIndex!.clamp(0, points.length - 1).toInt();
    if (idx != null) {
      final rawPoint = _pointForValue(idx, points[idx], size, minV, range);
      final point = Offset(
        rawPoint.dx.clamp(7.0, size.width - 7.0).toDouble(),
        rawPoint.dy.clamp(7.0, size.height - 22.0).toDouble(),
      );
      final guidePaint = Paint()
        ..color = kBrandStrong.withOpacity(.55)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      _drawDashedLine(
        canvas,
        Offset(point.dx, 0),
        Offset(point.dx, size.height),
        guidePaint,
        dash: 5,
        gap: 4,
      );
      canvas.drawCircle(
        point,
        7.5,
        Paint()..color = Colors.white.withOpacity(.95),
      );
      canvas.drawCircle(point, 4.7, Paint()..color = kBrandStrong);
      canvas.drawCircle(
        point,
        10.5,
        Paint()
          ..color = kBrandStrong.withOpacity(.14)
          ..style = PaintingStyle.fill,
      );
      if (currentLabel != null && currentLabel!.isNotEmpty)
        _drawLabel(canvas, size, point, currentLabel!, kBrandStrong);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.actualCount != actualCount ||
      oldDelegate.currentIndex != currentIndex ||
      oldDelegate.currentLabel != currentLabel ||
      oldDelegate.targetValue != targetValue ||
      oldDelegate.targetLabel != targetLabel;
}
