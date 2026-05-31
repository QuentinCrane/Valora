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
    return PageFrame(
      children: [
        Text(
          '分析',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.normal,
            height: 0.95,
          ),
        ),
        const SizedBox(height: 6),
        const Text('用聚合数据判断资产是否值得继续持有。', style: TextStyle(color: kMuted)),
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
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          '核心指标',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: kMuted),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridWrap(
                    children: [
                      DetailCell(
                        label: '资产总值',
                        value: money(analytics.totalAssetValue, store.settings),
                      ),
                      DetailCell(
                        label: '平均日耗',
                        value: money(
                          analytics.averageDailyCost,
                          store.settings,
                        ),
                      ),
                      DetailCell(
                        label: '累计投入',
                        value: money(
                          analytics.totalPurchaseCost,
                          store.settings,
                        ),
                      ),
                      DetailCell(
                        label: '心愿预算',
                        value: money(analytics.wishBudget, store.settings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'analytics.insights',
          child: InsightStrip(store: store),
        ),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'analytics.lifecycle',
          child: LifecycleDashboardCard(store: store),
        ),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'analytics.quality',
          child: PortfolioQualityCard(store: store),
        ),
        const SizedBox(height: 12),
        AssetTimeMachineCard(store: store),
        const SizedBox(height: 12),
        if (store.walletLeaks().isNotEmpty) ...[
          WalletLeakCard(store: store),
          const SizedBox(height: 12),
        ],
        if (store.dueSoonAssets().isNotEmpty) ...[
          DueSoonCard(store: store),
          const SizedBox(height: 12),
        ],
        TutorialTargetAnchor(
          id: 'analytics.valueTrend',
          child: ChartPanel(
            title: '长期价值地图',
            subtitle: '蓝线代表估算净值；下方渐变面积代表历史价值沉淀。点击查看明细。',
            onTap: () => showValueTrendDetail(context, store),
            child: SizedBox(
              height: 190,
              child: ValueTrendChart(points: analytics.valueTrend),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LifecycleTimelineCard(store: store),
        const SizedBox(height: 12),
        ValueQuadrantCard(store: store),
        const SizedBox(height: 12),
        SnapshotCompareCard(store: store),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '资产体检',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
              ),
              const SizedBox(height: 10),
              ...analytics.insights.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(.16),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: const TextStyle(
                                color: kMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 22),
              GridWrap(
                children: [
                  DetailCell(
                    label: '净成本合计',
                    value: money(
                      analytics.lifecycleNetConsumption,
                      store.settings,
                    ),
                  ),
                  DetailCell(
                    label: '价值回收',
                    value: money(
                      analytics.lifecycleRecoveredValue,
                      store.settings,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ChartPanel(
          title: '分类估值占比',
          subtitle: '按照分类汇总当前资产价值。点击查看分类明细。',
          onTap: () => showCategoryDistributionDetail(context, store),
          child: category.isEmpty
              ? const SizedBox(height: 120, child: Center(child: Text('暂无数据')))
              : Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChartLite(values: category.values.toList()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: category.entries
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${e.key}  ${money(e.value, store.settings)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        ChartPanel(
          title: '标签分布',
          subtitle: '标签更适合描述资产场景。点击查看标签明细。',
          onTap: () => showTagDistributionDetail(context, store),
          child: tags.isEmpty
              ? const SizedBox(height: 80, child: Center(child: Text('暂无标签')))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.entries
                      .map(
                        (e) => TinyTag(
                          label: '${e.key} · ${e.value}',
                          color: kBrandStrong,
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(kRadiusLg),
          onTap: () {
            tapHaptic();
            showDailyCostRankingDetail(context, store);
          },
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        '日均成本排行',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: kMuted),
                  ],
                ),
                const SizedBox(height: 12),
                ...topDaily
                    .take(6)
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(
                            context,
                          ).push(softRoute(AssetDetailPage(assetId: a.id))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: valoraIconVisual(
                                    context,
                                    a.iconValue,
                                    emojiSize: 20,
                                    borderRadius: 10,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    a.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${money(a.dailyCost, store.settings)} /天',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ChartPanel(
          title: '服役时长分布',
          subtitle: '观察哪些资产已经陪伴你很久。点击查看服役排行。',
          onTap: () => showServiceDurationDetail(context, store),
          child: SizedBox(
            height: 170,
            child: BarChartLite(
              values: store.assets
                  .map((a) => a.serviceDays.toDouble())
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

void showAnalyticsSummaryDetail(BuildContext context, AppStore store) {
  final analytics = store.analyticsSnapshot;
  final serving = store.assets
      .where((a) => a.status == AssetStatus.serving)
      .length;
  final retired = store.assets
      .where((a) => a.status == AssetStatus.retired)
      .length;
  final sold = store.assets.where((a) => a.status == AssetStatus.sold).length;
  appSheet(
    context,
    title: '核心指标明细',
    subtitle: '这里把首页看板之外的计算口径展开。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridWrap(
          children: [
            DetailCell(label: '资产数量', value: '${store.assets.length} 件'),
            DetailCell(
              label: '服役 / 退役 / 卖出',
              value: '$serving / $retired / $sold',
            ),
            DetailCell(
              label: '累计投入',
              value: money(analytics.totalPurchaseCost, store.settings),
            ),
            DetailCell(
              label: '净成本合计',
              value: money(analytics.lifecycleNetConsumption, store.settings),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '说明：总资产按当前估值与是否计入总资产计算；日均成本按仍计入日均的资产净消耗除以服役天数估算。',
          style: TextStyle(color: kMuted, height: 1.45),
        ),
      ],
    ),
  );
}

void showValueTrendDetail(BuildContext context, AppStore store) {
  final points = store.analyticsSnapshot.valueTrend;
  appSheet(
    context,
    title: '长期价值地图明细',
    subtitle: '每个节点代表一段时间内资产净值的估算。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (points.isEmpty)
          const Text('暂无趋势数据', style: TextStyle(color: kMuted))
        else
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text(p.label)),
                  Text(
                    money(p.value, store.settings),
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

void showCategoryDistributionDetail(BuildContext context, AppStore store) {
  final entries = store.analyticsSnapshot.categoryDistribution.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final total = entries.fold(0.0, (sum, e) => sum + e.value);
  appSheet(
    context,
    title: '分类估值明细',
    subtitle: '用于判断钱主要压在哪类资产里。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          const Text('暂无分类数据', style: TextStyle(color: kMuted))
        else
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.key)),
                      Text(
                        '${money(e.value, store.settings)} · ${(total <= 0 ? 0 : e.value / total * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: total <= 0 ? 0 : e.value / total,
                      minHeight: 7,
                      backgroundColor: context.isDark
                          ? Colors.white12
                          : const Color(0xFFEAF1F7),
                      color: kBrandStrong,
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

void showTagDistributionDetail(BuildContext context, AppStore store) {
  final entries = store.analyticsSnapshot.tagDistribution.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  appSheet(
    context,
    title: '标签明细',
    subtitle: '标签更适合描述使用场景、购买原因和复盘角度。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          const Text('暂无标签')
        else
          ...entries.map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              trailing: Text('${e.value} 件'),
            ),
          ),
      ],
    ),
  );
}

void showServiceDurationDetail(BuildContext context, AppStore store) {
  final list = [...store.assets]
    ..sort((a, b) => b.serviceDays.compareTo(a.serviceDays));
  appSheet(
    context,
    title: '服役时长排行',
    subtitle: '适合找出真正长期陪伴你的资产。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (list.isEmpty)
          const Text('暂无资产')
        else
          ...list
              .take(12)
              .map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 38,
                    height: 38,
                    child: valoraIconVisual(
                      context,
                      a.iconValue,
                      emojiSize: 22,
                      borderRadius: 14,
                    ),
                  ),
                  title: Text(
                    a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('日均 ${money(a.dailyCost, store.settings)} /天'),
                  trailing: Text(
                    durationWithCalendarText(
                      a.serviceDays,
                      store.settings.durationMode,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                    ).push(softRoute(AssetDetailPage(assetId: a.id)));
                  },
                ),
              ),
      ],
    ),
  );
}

void showDailyCostRankingDetail(BuildContext context, AppStore store) {
  final list = [...store.assets]
    ..sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
  appSheet(
    context,
    title: '日均成本排行明细',
    subtitle: '点击任一资产进入详情页，查看购买价、服役天数、目标日均等。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (list.isEmpty)
          const Text('暂无资产', style: TextStyle(color: kMuted))
        else
          ...list.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 42,
                height: 42,
                child: valoraIconVisual(
                  context,
                  a.iconValue,
                  emojiSize: 23,
                  borderRadius: 15,
                ),
              ),
              title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '购入 ${money(a.price, store.settings)} · 持有 ${durationWithCalendarText(a.serviceDays, store.settings.durationMode)} · ${store.categoryName(a.categoryId)}',
              ),
              trailing: Text(
                '${money(a.dailyCost, store.settings)} /天',
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).push(softRoute(AssetDetailPage(assetId: a.id)));
              },
            ),
          ),
      ],
    ),
  );
}

class ValueTrendChart extends StatelessWidget {
  final List<AssetTrendPoint> points;
  const ValueTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const Center(child: Text('暂无趋势数据'));
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
    final path = smoothPathFromValues(
      values,
      size,
      topPadding: 2,
      bottomPadding: 2,
    );
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
          kBrand.withOpacity(0),
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
        Offset(x, y),
        3.2,
        Paint()..color = Colors.white.withOpacity(.88),
      );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.timeline_rounded, color: kBrandStrong),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '资产时光机',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '最近的买入、退役、卖出都会在这里形成复盘线索。',
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const Text('暂无事件', style: TextStyle(color: kMuted))
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dateText(event.date)} · ${event.subtitle}',
                            style: const TextStyle(
                              color: kMuted,
                              fontSize: 12,
                              height: 1.3,
                            ),
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
      Colors.blueAccent,
    ];
    var start = -math.pi / 2;
    final rect = Offset.zero & size;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(
        rect.deflate(4),
        start,
        sweep,
        true,
        Paint()..color = colors[i % colors.length],
      );
      start += sweep;
    }
    canvas.drawCircle(
      size.center(Offset.zero),
      math.min(size.width, size.height) * .25,
      Paint()..color = Colors.white.withOpacity(.88),
    );
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
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        r,
        Paint()..color = kBrand.withOpacity(.45 + .45 * (values[i] / maxV)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BarPainter oldDelegate) =>
      oldDelegate.values != values;
}
