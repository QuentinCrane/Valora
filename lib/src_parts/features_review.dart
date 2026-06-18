part of '../main.dart';

class PortfolioQualityCard extends StatelessWidget {
  final AppStore store;
  const PortfolioQualityCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final active =
        store.assets.where((a) => a.status == AssetStatus.serving).toList();
    final targeted =
        active.where((a) => a.targetMode != TargetMode.none).length;
    final highRisk = store.walletLeaks(limit: 99).length;
    final sold = store.assets.where((a) => a.status == AssetStatus.sold).length;
    final retired =
        store.assets.where((a) => a.status == AssetStatus.retired).length;
    final tagged = store.assets.where((a) => a.tagIds.isNotEmpty).length;
    final total = math.max(store.assets.length, 1);
    final score = _qualityScore(store);
    final tone = score >= 82
        ? const Color(0xFF22C55E)
        : score >= 64
            ? kBrandStrong
            : const Color(0xFFFFB020);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: tone.withOpacity(.16),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.health_and_safety_rounded, color: tone)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tr('review.healthTitle'),
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 17)),
                const SizedBox(height: 3),
                Text(tr('review.healthSubtitle'),
                    style: TextStyle(color: kMuted, fontSize: 12)),
              ])),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score.toDouble()),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(value.round().toString(),
                style: TextStyle(
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.normal,
                    color: tone)),
          ),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
              minHeight: 10,
              value: score / 100,
              backgroundColor: context.isDark ? kSoftDark : kSoft,
              color: tone),
        ),
        const SizedBox(height: 12),
        GridWrap(children: [
          DetailCell(
              label: tr('review.targetCoverage'),
              value:
                  '${active.isEmpty ? 0 : (targeted / math.max(active.length, 1) * 100).round()}%'),
          DetailCell(
              label: tr('review.tagCoverage'),
              value: '${(tagged / total * 100).round()}%'),
          DetailCell(
              label: tr('review.pendingRisk'),
              value: '$highRisk ${tr('review.items')}'),
          DetailCell(
              label: tr('review.completedFlow'),
              value: '${sold + retired} ${tr('review.items')}'),
        ]),
        const SizedBox(height: 10),
        Text(_qualitySuggestion(score, highRisk, targeted, active.length),
            style: const TextStyle(color: kMuted, height: 1.35, fontSize: 12)),
      ]),
    );
  }
}

int _qualityScore(AppStore store) {
  final total = math.max(store.assets.length, 1);
  final active =
      store.assets.where((a) => a.status == AssetStatus.serving).toList();
  final taggedRatio =
      store.assets.where((a) => a.tagIds.isNotEmpty).length / total;
  final categoryRatio =
      store.assets.where((a) => a.categoryId != null).length / total;
  final targetRatio = active.isEmpty
      ? .0
      : active.where((a) => a.targetMode != TargetMode.none).length /
          active.length;
  final riskPenalty = math.min(store.walletLeaks(limit: 99).length * 7, 28);
  final snapshotBonus = math.min(store.snapshots.length * 3, 9);
  final flowBonus = math.min(
      store.assets
              .where((a) =>
                  a.status == AssetStatus.sold ||
                  a.status == AssetStatus.retired)
              .length *
          2,
      8);
  final score = 46 +
      taggedRatio * 13 +
      categoryRatio * 12 +
      targetRatio * 14 +
      snapshotBonus +
      flowBonus -
      riskPenalty;
  return score.round().clamp(0, 100).toInt();
}

String _qualitySuggestion(
    int score, int riskCount, int targeted, int activeCount) {
  if (score >= 82) return tr('review.suggestionHigh');
  if (riskCount > 0) return tr('review.suggestionRisk');
  if (activeCount > 0 && targeted < activeCount ~/ 2)
    return tr('review.suggestionTarget');
  return tr('review.suggestionBase');
}

class ValueQuadrantCard extends StatelessWidget {
  final AppStore store;
  const ValueQuadrantCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final active =
        store.assets.where((a) => a.status == AssetStatus.serving).toList();
    return ChartPanel(
      title: tr('review.quadrantTitle'),
      subtitle: tr('review.quadrantSubtitle'),
      onTap:
          active.isEmpty ? null : () => showValueQuadrantDetail(context, store),
      child: active.isEmpty
          ? SizedBox(
              height: 150,
              child: Center(child: Text(tr('review.noServingAsset'))))
          : SizedBox(
              height: 220,
              child:
                  ValueQuadrantChart(assets: active, settings: store.settings)),
    );
  }
}

class ValueQuadrantChart extends StatelessWidget {
  final List<Asset> assets;
  final AppSettings settings;
  const ValueQuadrantChart(
      {super.key, required this.assets, required this.settings});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: ValueQuadrantPainter(assets, context.isDark),
        size: Size.infinite);
  }
}

class ValueQuadrantPainter extends CustomPainter {
  final List<Asset> assets;
  final bool dark;
  ValueQuadrantPainter(this.assets, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    if (assets.isEmpty || size.width <= 0 || size.height <= 0) return;
    const left = 34.0;
    const top = 14.0;
    const right = 10.0;
    const bottom = 28.0;
    final chart = Rect.fromLTWH(
        left,
        top,
        math.max(size.width - left - right, 1.0),
        math.max(size.height - top - bottom, 1.0));
    final axis = Paint()
      ..color = kMuted.withOpacity(.18)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(chart.left, chart.bottom),
        Offset(chart.right, chart.bottom), axis);
    canvas.drawLine(
        Offset(chart.left, chart.top), Offset(chart.left, chart.bottom), axis);
    canvas.drawLine(Offset(chart.left, chart.center.dy),
        Offset(chart.right, chart.center.dy), axis);
    canvas.drawLine(Offset(chart.center.dx, chart.top),
        Offset(chart.center.dx, chart.bottom), axis);

    final maxDays = assets.fold<int>(
        1, (maxValue, asset) => math.max(maxValue, asset.serviceDays));
    final maxDaily = assets.fold<double>(
        1, (maxValue, asset) => math.max(maxValue, asset.dailyCost));
    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    void label(String text, Offset at, {Color color = kMuted}) {
      textPainter.text = TextSpan(
          text: text,
          style: TextStyle(
              color: color.withOpacity(.9),
              fontSize: 10,
              fontWeight: FontWeight.normal));
      textPainter.layout(maxWidth: 80);
      textPainter.paint(canvas, at);
    }

    label(tr('review.quadrantLongLow'),
        Offset(chart.right - 64, chart.bottom - 18),
        color: const Color(0xFF22C55E));
    label(tr('review.quadrantShortHigh'), Offset(chart.left + 8, chart.top + 8),
        color: kDanger);
    label(tr('review.axisServiceDays'),
        Offset(chart.center.dx - 24, chart.bottom + 8));
    label(tr('review.axisDailyCost'), Offset(0, chart.top + 2));

    for (final asset in assets) {
      final x = chart.left + asset.serviceDays / maxDays * chart.width;
      final y = chart.bottom - asset.dailyCost / maxDaily * chart.height;
      final ratio = asset.targetMode == TargetMode.none
          ? .36
          : math.max(.45, asset.targetRatio);
      final color = asset.dailyCost > maxDaily * .55
          ? kDanger
          : asset.serviceDays > maxDays * .55
              ? const Color(0xFF22C55E)
              : kBrandStrong;
      canvas.drawCircle(
          Offset(x, y), 13, Paint()..color = color.withOpacity(.13));
      canvas.drawCircle(
          Offset(x, y), 6 + 4 * ratio, Paint()..color = color.withOpacity(.86));
    }
  }

  @override
  bool shouldRepaint(covariant ValueQuadrantPainter oldDelegate) =>
      oldDelegate.assets != assets || oldDelegate.dark != dark;
}

void showValueQuadrantDetail(BuildContext context, AppStore store) {
  final active =
      store.assets.where((a) => a.status == AssetStatus.serving).toList();
  final maxDays = active.fold<int>(
      1, (maxValue, asset) => math.max(maxValue, asset.serviceDays));
  final maxDaily = active.fold<double>(
      1, (maxValue, asset) => math.max(maxValue, asset.dailyCost));

  String quadrantOf(Asset asset) {
    final longUse = asset.serviceDays >= maxDays * .5;
    final lowCost = asset.dailyCost <= maxDaily * .5;
    if (longUse && lowCost) return 'longLow';
    if (longUse && !lowCost) return 'longHigh';
    if (!longUse && lowCost) return 'shortLow';
    return 'shortHigh';
  }

  String quadrantLabel(String q) {
    switch (q) {
      case 'longLow':
        return tr('review.quadrantLongLow');
      case 'longHigh':
        return tr('review.quadrantLongHigh');
      case 'shortLow':
        return tr('review.quadrantShortLow');
      default:
        return tr('review.quadrantShortHigh');
    }
  }

  Color quadrantColor(String q) {
    switch (q) {
      case 'longLow':
        return const Color(0xFF22C55E);
      case 'longHigh':
        return const Color(0xFFF59E0B);
      case 'shortLow':
        return kBrandStrong;
      default:
        return kDanger;
    }
  }

  final grouped = <String, List<Asset>>{
    'longLow': [],
    'longHigh': [],
    'shortLow': [],
    'shortHigh': [],
  };
  for (final asset in active) {
    grouped[quadrantOf(asset)]!.add(asset);
  }
  for (final list in grouped.values) {
    list.sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
  }

  appSheet(context,
      title: tr('review.quadrantDetailTitle'),
      subtitle: tr('review.quadrantDetailSubtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (active.isEmpty)
          Text(tr('review.noServingAsset'),
              style: const TextStyle(color: kMuted))
        else
          ...grouped.entries.map((entry) {
            final color = quadrantColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                          '${quadrantLabel(entry.key)} · ${entry.value.length} ${tr('review.items')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 15))
                    ]),
                    const SizedBox(height: 8),
                    if (entry.value.isEmpty)
                      Text(tr('review.noAsset'),
                          style: TextStyle(color: kMuted, fontSize: 12))
                    else
                      ...entry.value.map((asset) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                                width: 40,
                                height: 40,
                                child: valoraIconVisual(
                                    context, asset.iconValue,
                                    emojiSize: 22, borderRadius: 14)),
                            title: Text(asset.name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                '${tr('review.served')} ${asset.serviceDays} ${tr('time.day')} · ${tr('review.dailyAvg')} ${money(asset.dailyCost, store.settings)} ${tr('detail.perDay')}'),
                            trailing: const Icon(Icons.chevron_right_rounded,
                                color: kMuted),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(softRoute(
                                  AssetDetailPage(assetId: asset.id)));
                            },
                          )),
                  ]),
            );
          }),
      ]));
}

class SnapshotCompareCard extends StatelessWidget {
  final AppStore store;
  const SnapshotCompareCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final latest = store.snapshots.isEmpty ? null : store.snapshots.first;
    final latestSummary =
        latest == null ? null : _snapshotSummary(latest.payload);
    final current = _PortfolioSummary(
      assetCount: store.assets.length,
      wishCount: store.wishes.where((w) => !w.archived).length,
      totalValue: store.getTotalAssetValue(),
      dailyCost: store.getAverageDailyCost(),
      recovered: store.getLifecycleRecoveredValue(),
    );
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: const Color(0xFFA78BFA).withOpacity(.16),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.compare_arrows_rounded,
                  color: Color(0xFFA78BFA))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tr('review.snapshotTitle'),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 17)),
                const SizedBox(height: 2),
                Text(tr('review.snapshotSubtitle'),
                    style: const TextStyle(color: kMuted, fontSize: 12)),
              ])),
        ]),
        const SizedBox(height: 12),
        if (latestSummary == null)
          Text(tr('review.noSnapshot'),
              style: const TextStyle(color: kMuted, height: 1.35))
        else ...[
          Text('${tr('review.latestSnapshot')}${latest!.label}',
              style: const TextStyle(fontWeight: FontWeight.normal)),
          const SizedBox(height: 10),
          GridWrap(children: [
            DetailCell(
                label: tr('review.assetCountChange'),
                value: _signedInt(current.assetCount - latestSummary.assetCount,
                    unit: tr('review.items'))),
            DetailCell(
                label: tr('review.wishCountChange'),
                value: _signedInt(current.wishCount - latestSummary.wishCount,
                    unit: tr('review.wishItems'))),
            DetailCell(
                label: tr('review.netValueChange'),
                value: _signedMoney(
                    current.totalValue - latestSummary.totalValue,
                    store.settings)),
            DetailCell(
                label: tr('review.dailyCostChange'),
                value: _signedMoney(current.dailyCost - latestSummary.dailyCost,
                    store.settings)),
          ]),
        ],
      ]),
    );
  }
}

class _PortfolioSummary {
  final int assetCount;
  final int wishCount;
  final double totalValue;
  final double dailyCost;
  final double recovered;
  const _PortfolioSummary(
      {required this.assetCount,
      required this.wishCount,
      required this.totalValue,
      required this.dailyCost,
      required this.recovered});
}

_PortfolioSummary _snapshotSummary(String raw) {
  try {
    final data = Map<String, dynamic>.from(jsonDecode(raw));
    final settings = AppSettings.fromMap(
        Map<String, dynamic>.from(data['settings'] ?? const {}));
    final assets = ((data['assets'] as List?) ?? [])
        .map((e) => Asset.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final wishes = ((data['wishes'] as List?) ?? [])
        .map((e) => Wish.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final totalValue = assets
        .where((a) =>
            settings.includeRetiredInTotal || a.status != AssetStatus.retired)
        .fold(0.0, (s, a) => s + a.assetValue);
    final dailyAssets =
        assets.where((a) => !a.isPriceless && a.includeInDailyCost).toList();
    final dailyCost = dailyAssets.isEmpty
        ? 0.0
        : dailyAssets.fold(0.0, (s, a) => s + a.dailyCost) / dailyAssets.length;
    final recovered = assets
        .where((a) => a.status == AssetStatus.sold && !a.isPriceless)
        .fold(0.0, (s, a) => s + (a.soldPrice ?? 0));
    return _PortfolioSummary(
        assetCount: assets.length,
        wishCount: wishes.where((w) => !w.archived).length,
        totalValue: totalValue,
        dailyCost: dailyCost,
        recovered: recovered);
  } catch (_) {
    return const _PortfolioSummary(
        assetCount: 0, wishCount: 0, totalValue: 0, dailyCost: 0, recovered: 0);
  }
}

String _signedInt(int value, {required String unit}) =>
    value == 0 ? '0$unit' : '${value > 0 ? '+' : ''}$value$unit';
String _signedMoney(double value, AppSettings settings) => value == 0
    ? money(0, settings)
    : '${value > 0 ? '+' : ''}${money(value, settings)}';
