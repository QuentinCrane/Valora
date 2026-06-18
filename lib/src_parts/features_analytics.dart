part of '../main.dart';

class AnalyticsHomePage extends StatelessWidget {
  const AnalyticsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final analytics = store.analyticsSnapshot;
    final category = analytics.categoryDistribution;
    final tags = analytics.tagDistribution;
    final topDaily = analytics.topDailyAssets;
    return PageFrame(children: [
      Text(tr('analytics.title'),
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.normal, height: 0.95)),
      const SizedBox(height: 6),
      Text(tr('analytics.subtitle'), style: const TextStyle(color: kMuted)),
      const SizedBox(height: 14),
      TutorialTargetAnchor(
          id: 'analytics.core',
          child: InkWell(
            borderRadius: BorderRadius.circular(kRadiusLg),
            onTap: () {
              tapHaptic();
              showAnalyticsSummaryDetail(context, store);
            },
            child: AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(tr('analytics.coreMetrics'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal))),
                    const Icon(Icons.chevron_right_rounded, color: kMuted)
                  ]),
                  const SizedBox(height: 12),
                  GridWrap(children: [
                    DetailCell(
                        label: tr('analytics.totalAssetValue'),
                        value:
                            money(analytics.totalAssetValue, store.settings)),
                    DetailCell(
                        label: tr('analytics.avgDailyCost'),
                        value:
                            money(analytics.averageDailyCost, store.settings)),
                    DetailCell(
                        label: tr('analytics.totalInvested'),
                        value:
                            money(analytics.totalPurchaseCost, store.settings)),
                    DetailCell(
                        label: tr('analytics.wishBudget'),
                        value: money(analytics.wishBudget, store.settings)),
                  ]),
                ])),
          )),
      const SizedBox(height: 12),
      TutorialTargetAnchor(
          id: 'analytics.insights', child: InsightStrip(store: store)),
      const SizedBox(height: 12),
      TutorialTargetAnchor(
          id: 'analytics.lifecycle',
          child: LifecycleDashboardCard(store: store)),
      const SizedBox(height: 12),
      TutorialTargetAnchor(
          id: 'analytics.quality', child: PortfolioQualityCard(store: store)),
      const SizedBox(height: 12),
      AssetTimeMachineCard(store: store),
      const SizedBox(height: 12),
      if (store.walletLeaks().isNotEmpty) ...[
        WalletLeakCard(store: store),
        const SizedBox(height: 12)
      ],
      if (store.dueSoonAssets().isNotEmpty) ...[
        DueSoonCard(store: store),
        const SizedBox(height: 12)
      ],
      if (store.pricelessAssets().isNotEmpty) ...[
        PricelessHomeCard(store: store),
        const SizedBox(height: 12)
      ],
      TutorialTargetAnchor(
          id: 'analytics.valueTrend',
          child: ChartPanel(
              title: tr('analytics.valueTrend'),
              subtitle: tr('analytics.valueTrendDesc'),
              onTap: () => showValueTrendDetail(context, store),
              child: SizedBox(
                  height: 190,
                  child: ValueTrendChart(points: analytics.valueTrend)))),
      const SizedBox(height: 12),
      LifecycleTimelineCard(store: store),
      const SizedBox(height: 12),
      ValueQuadrantCard(store: store),
      const SizedBox(height: 12),
      SnapshotCompareCard(store: store),
      const SizedBox(height: 12),
      AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('analytics.assetCheckup'),
            style:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
        const SizedBox(height: 10),
        ...analytics.insights.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: item.color.withOpacity(.16),
                      borderRadius: BorderRadius.circular(13)),
                  child: Icon(item.icon, color: item.color, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(item.title,
                        style: const TextStyle(fontWeight: FontWeight.normal)),
                    const SizedBox(height: 2),
                    Text(item.description,
                        style: const TextStyle(color: kMuted, height: 1.35))
                  ])),
            ]))),
        const Divider(height: 22),
        GridWrap(children: [
          DetailCell(
              label: tr('analytics.netCost'),
              value: money(analytics.lifecycleNetConsumption, store.settings)),
          DetailCell(
              label: tr('analytics.valueRecovered'),
              value: money(analytics.lifecycleRecoveredValue, store.settings)),
        ]),
      ])),
      const SizedBox(height: 12),
      ChartPanel(
          title: tr('analytics.categoryValuation'),
          subtitle: tr('analytics.categoryValuationDesc'),
          onTap: () => showCategoryDistributionDetail(context, store),
          child: category.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(child: Text(tr('analytics.noData'))))
              : Row(children: [
                  SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChartLite(values: category.values.toList())),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: category.entries
                              .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                      '${e.key}  ${money(e.value, store.settings)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal))))
                              .toList()))
                ])),
      const SizedBox(height: 12),
      ChartPanel(
          title: tr('analytics.tagDistribution'),
          subtitle: tr('analytics.tagDistributionDesc'),
          onTap: () => showTagDistributionDetail(context, store),
          child: tags.isEmpty
              ? SizedBox(
                  height: 80,
                  child: Center(child: Text(tr('analytics.noTags'))))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.entries
                      .map((e) => TinyTag(
                          label: '${e.key} · ${e.value}', color: kBrandStrong))
                      .toList())),
      const SizedBox(height: 12),
      InkWell(
        borderRadius: BorderRadius.circular(kRadiusLg),
        onTap: () {
          tapHaptic();
          showDailyCostRankingDetail(context, store);
        },
        child: AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(tr('analytics.dailyCostRanking'),
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 18))),
            const Icon(Icons.chevron_right_rounded, color: kMuted)
          ]),
          const SizedBox(height: 12),
          if (topDaily.isEmpty)
            Text(tr('analytics.noDailyCostAssets'),
                style: const TextStyle(color: kMuted)),
          ...topDaily.take(6).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context)
                      .push(softRoute(AssetDetailPage(assetId: a.id))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      SizedBox(
                          width: 28,
                          height: 28,
                          child: valoraIconVisual(context, a.iconValue,
                              emojiSize: 20, borderRadius: 10)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(a.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal))),
                      Text(
                          '${money(a.dailyCost, store.settings)} ${tr('time.perDay')}',
                          style: const TextStyle(fontWeight: FontWeight.normal))
                    ]),
                  ),
                ),
              )),
        ])),
      ),
      const SizedBox(height: 12),
      ChartPanel(
          title: tr('analytics.serviceDuration'),
          subtitle: tr('analytics.serviceDurationDesc'),
          onTap: () => showServiceDurationDetail(context, store),
          child: SizedBox(
              height: 170,
              child: BarChartLite(
                  values: store.assets
                      .map((a) => a.serviceDays.toDouble())
                      .toList()))),
    ]);
  }
}

void showAnalyticsSummaryDetail(BuildContext context, AppStore store) {
  final analytics = store.analyticsSnapshot;
  final serving =
      store.assets.where((a) => a.status == AssetStatus.serving).length;
  final retired =
      store.assets.where((a) => a.status == AssetStatus.retired).length;
  final sold = store.assets.where((a) => a.status == AssetStatus.sold).length;
  appSheet(context,
      title: tr('analytics.coreMetricsDetail'),
      subtitle: tr('analytics.coreMetricsDetailDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GridWrap(children: [
          DetailCell(
              label: tr('analytics.assetCount'),
              value: '${store.assets.length} ${tr('analytics.countUnit')}'),
          DetailCell(
              label: tr('analytics.statusBreakdown'),
              value: '$serving / $retired / $sold'),
          DetailCell(
              label: tr('analytics.totalInvested'),
              value: money(analytics.totalPurchaseCost, store.settings)),
          DetailCell(
              label: tr('analytics.netCost'),
              value: money(analytics.lifecycleNetConsumption, store.settings)),
        ]),
        const SizedBox(height: 12),
        Text(tr('analytics.summaryNote'),
            style: const TextStyle(color: kMuted, height: 1.45)),
      ]));
}

void showValueTrendDetail(BuildContext context, AppStore store) {
  final points = store.analyticsSnapshot.valueTrend;
  appSheet(context,
      title: tr('analytics.valueTrendDetail'),
      subtitle: tr('analytics.valueTrendDetailDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (points.isEmpty)
          Text(tr('analytics.noTrendData'),
              style: const TextStyle(color: kMuted))
        else
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text(p.label)),
                  Text(money(p.value, store.settings),
                      style: const TextStyle(fontWeight: FontWeight.normal))
                ]),
              )),
      ]));
}

void showCategoryDistributionDetail(BuildContext context, AppStore store) {
  final entries = store.analyticsSnapshot.categoryDistribution.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final total = entries.fold(0.0, (sum, e) => sum + e.value);
  appSheet(context,
      title: tr('analytics.categoryDetail'),
      subtitle: tr('analytics.categoryDetailDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (entries.isEmpty)
          Text(tr('analytics.noCategoryData'),
              style: const TextStyle(color: kMuted))
        else
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(e.key)),
                        Text(
                            '${money(e.value, store.settings)} · ${(total <= 0 ? 0 : e.value / total * 100).toStringAsFixed(1)}%')
                      ]),
                      const SizedBox(height: 5),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                              value: total <= 0 ? 0 : e.value / total,
                              minHeight: 7,
                              backgroundColor: context.isDark
                                  ? Colors.white12
                                  : const Color(0xFFEAF1F7),
                              color: kBrandStrong)),
                    ]),
              )),
      ]));
}

void showTagDistributionDetail(BuildContext context, AppStore store) {
  final entries = store.analyticsSnapshot.tagDistribution.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  appSheet(context,
      title: tr('analytics.tagDetail'),
      subtitle: tr('analytics.tagDetailDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (entries.isEmpty)
          Text(tr('analytics.noTags'))
        else
          ...entries.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              trailing: Text('${e.value} ${tr('analytics.countUnit')}'))),
      ]));
}

void showServiceDurationDetail(BuildContext context, AppStore store) {
  final list = [...store.assets]
    ..sort((a, b) => b.serviceDays.compareTo(a.serviceDays));
  appSheet(context,
      title: tr('analytics.serviceDurationRanking'),
      subtitle: tr('analytics.serviceDurationRankingDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (list.isEmpty)
          Text(tr('analytics.noAssets'))
        else
          ...list.take(12).map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                    width: 38,
                    height: 38,
                    child: valoraIconVisual(context, a.iconValue,
                        emojiSize: 22, borderRadius: 14)),
                title:
                    Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    '${assetMetricLabel(a)} ${assetMetricValueText(a, store.settings)}'),
                trailing: Text(durationWithCalendarText(
                    a.serviceDays, store.settings.durationMode)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(softRoute(AssetDetailPage(assetId: a.id)));
                },
              )),
      ]));
}

void showDailyCostRankingDetail(BuildContext context, AppStore store) {
  final list = store.assets
      .where((a) => !a.isPriceless && a.includeInDailyCost)
      .toList()
    ..sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
  appSheet(context,
      title: tr('analytics.dailyCostDetail'),
      subtitle: tr('analytics.dailyCostDetailDesc'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (list.isEmpty)
          Text(tr('analytics.noDailyCostAssets'),
              style: const TextStyle(color: kMuted))
        else
          ...list.map((a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                    width: 42,
                    height: 42,
                    child: valoraIconVisual(context, a.iconValue,
                        emojiSize: 23, borderRadius: 15)),
                title:
                    Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    '${tr('analytics.purchased')} ${assetBasePriceText(a, store.settings)} · ${tr('analytics.held')} ${durationWithCalendarText(a.serviceDays, store.settings.durationMode)} · ${store.categoryName(a.categoryId)}'),
                trailing: Text(
                    '${money(a.dailyCost, store.settings)} ${tr('time.perDay')}',
                    style: const TextStyle(fontWeight: FontWeight.normal)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(softRoute(AssetDetailPage(assetId: a.id)));
                },
              )),
      ]));
}

class ValueTrendChart extends StatelessWidget {
  final List<AssetTrendPoint> points;
  const ValueTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return Center(child: Text(tr('analytics.noTrendData')));
    return CustomPaint(painter: ValueTrendPainter(points), size: Size.infinite);
  }
}

class ValueTrendPainter extends CustomPainter {
  final List<AssetTrendPoint> points;
  ValueTrendPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;
    final values = points.map((e) => e.value).toList();
    final maxV = math.max(values.reduce(math.max), 1.0);
    final minV = values.reduce(math.min);
    final range = math.max(maxV - minV, 1.0);
    final gridPaint = Paint()
      ..color = kMuted.withOpacity(.13)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final path =
        smoothPathFromValues(values, size, topPadding: 2, bottomPadding: 2);
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kBrand.withOpacity(.34),
          kBrand.withOpacity(.16),
          kBrand.withOpacity(0)
        ],
        stops: const [0, .52, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fill, fillPaint);
    final linePaint = Paint()
      ..color = kBrand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
    final dotPaint = Paint()..color = kBrand;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / math.max(values.length - 1, 1);
      final y = size.height - ((values[i] - minV) / range) * size.height;
      canvas.drawCircle(
          Offset(x, y), 3.2, Paint()..color = Colors.white.withOpacity(.88));
      canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ValueTrendPainter oldDelegate) =>
      oldDelegate.points != points;
}

class LifecycleTimelineCard extends StatelessWidget {
  final AppStore store;
  const LifecycleTimelineCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final events = store.lifecycleEvents(limit: 6);
    return AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.timeline_rounded, color: kBrandStrong),
        const SizedBox(width: 8),
        Expanded(
            child: Text(tr('analytics.timeMachine'),
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 18))),
      ]),
      const SizedBox(height: 4),
      Text(tr('analytics.timeMachineDesc'),
          style: const TextStyle(color: kMuted, fontSize: 12)),
      const SizedBox(height: 12),
      if (events.isEmpty)
        Text(tr('analytics.noEvents'), style: const TextStyle(color: kMuted))
      else
        ...events.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: event.color.withOpacity(.16),
                        shape: BoxShape.circle),
                    child: Icon(event.icon, color: event.color, size: 18)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(event.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      const SizedBox(height: 2),
                      Text('${dateText(event.date)} · ${event.subtitle}',
                          style: const TextStyle(
                              color: kMuted, fontSize: 12, height: 1.3)),
                    ])),
              ]),
            )),
    ]));
  }
}

class PieChartLite extends StatelessWidget {
  final List<double> values;
  const PieChartLite({super.key, required this.values});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: PiePainter(values), size: Size.infinite);
}

class PiePainter extends CustomPainter {
  final List<double> values;
  PiePainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return;
    final colors = [
      kBrand,
      Colors.greenAccent,
      Colors.amber,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.blueAccent
    ];
    var start = -math.pi / 2;
    final rect = Offset.zero & size;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(rect.deflate(4), start, sweep, true,
          Paint()..color = colors[i % colors.length]);
      start += sweep;
    }
    canvas.drawCircle(
        size.center(Offset.zero),
        math.min(size.width, size.height) * .25,
        Paint()..color = Colors.white.withOpacity(.88));
  }

  @override
  bool shouldRepaint(covariant PiePainter oldDelegate) =>
      oldDelegate.values != values;
}

class BarChartLite extends StatelessWidget {
  final List<double> values;
  const BarChartLite({super.key, required this.values});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: BarPainter(values), size: Size.infinite);
}

class BarPainter extends CustomPainter {
  final List<double> values;
  BarPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = math.max(values.reduce(math.max), 1.0);
    final barW = size.width / values.length * .58;
    final gap = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final h = values[i] / maxV * size.height;
      final x = i * gap + (gap - barW) / 2;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h), const Radius.circular(8));
      canvas.drawRRect(r,
          Paint()..color = kBrand.withOpacity(.45 + .45 * (values[i] / maxV)));
    }
  }

  @override
  bool shouldRepaint(covariant BarPainter oldDelegate) =>
      oldDelegate.values != values;
}
