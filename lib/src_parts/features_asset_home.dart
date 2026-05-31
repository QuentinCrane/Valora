part of '../main.dart';

double homeMetaFontSize(AppSettings settings, {double base = 12.0}) =>
    (base * settings.homeMetaFontScale).clamp(9.8, 13.2).toDouble();
String homeDurationDaysText(Asset asset) => '${asset.serviceDays} 天';

void showHomeDurationPopover(BuildContext context, Asset asset) {
  final store = context.store;
  appSheet(
    context,
    title: '持有时间明细',
    subtitle: asset.name,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailCell(label: '首页统一显示', value: '${asset.serviceDays} 天'),
        const SizedBox(height: 8),
        DetailCell(
          label: '年/月换算',
          value: durationWithCalendarText(
            asset.serviceDays,
            store.settings.durationMode,
          ),
        ),
        const SizedBox(height: 8),
        DetailCell(label: '购买日期', value: dateText(asset.purchaseDate)),
        const SizedBox(height: 8),
        DetailCell(label: '计算截止', value: dateText(asset.serviceEndDate)),
        const SizedBox(height: 12),
        const Text(
          '首页卡片固定使用“天数”显示，避免同一张卡片里同时出现天、月、年导致被省略；更详细的年/月换算在这里查看。',
          style: TextStyle(color: kMuted, height: 1.45),
        ),
      ],
    ),
  );
}

class HomeAssetMetaLine extends StatelessWidget {
  final Asset asset;
  final AppStore store;
  final double baseFontSize;
  final bool spaced;
  const HomeAssetMetaLine({
    super.key,
    required this.asset,
    required this.store,
    this.baseFontSize = 12.0,
    this.spaced = false,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        '${money(asset.totalDisplayValue, store.settings)}${spaced ? ' 丨 ' : '丨'}已使用 ${homeDurationDaysText(asset)}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final base = homeMetaFontSize(store.settings, base: baseFontSize);
        final narrow = constraints.maxWidth < 145 || text.length > 24;
        final fontSize = narrow
            ? (base - 1.1).clamp(9.6, base).toDouble()
            : base;
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => showHomeDurationPopover(context, asset),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                color: kMuted,
                fontSize: fontSize,
                fontWeight: FontWeight.normal,
                height: 1.16,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AssetHomePage extends StatelessWidget {
  const AssetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final filtered = store.filteredAssets;
    return PageFrame(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 116),
      children: [
        HomeHeroHeader(store: store, visibleCount: filtered.length),
        const SizedBox(height: 14),
        TutorialTargetAnchor(
          id: 'home.filters',
          child: StatusAndViewRow(store: store),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          TutorialTargetAnchor(
            id: 'home.empty',
            child: EmptyStateCard(
              icon: '📦',
              title: '空空如也',
              subtitle: '点击底部 + 添加资产',
              actionLabel: '新增资产',
              onAction: () => Navigator.of(context).push(
                softRoute(const ComposePage(initialTab: ComposeTab.asset)),
              ),
            ),
          )
        else if (store.viewMode == HomeViewMode.grid)
          ResponsiveAssetGrid(assets: filtered)
        else if (store.viewMode == HomeViewMode.list)
          ...List.generate(
            filtered.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: i == 0
                  ? TutorialTargetAnchor(
                      id: 'home.assetCard',
                      child: AssetListTileCard(asset: filtered[i]),
                    )
                  : AssetListTileCard(asset: filtered[i]),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              filtered.length,
              (i) => i == 0
                  ? TutorialTargetAnchor(
                      id: 'home.assetCard',
                      child: AssetStickerChip(asset: filtered[i]),
                    )
                  : AssetStickerChip(asset: filtered[i]),
            ),
          ),
      ],
    );
  }
}

class ResponsiveAssetGrid extends StatelessWidget {
  final List<Asset> assets;
  const ResponsiveAssetGrid({super.key, required this.assets});

  int _columnCount(double width) {
    if (width >= 1180) return 5;
    if (width >= 920) return 4;
    if (width >= 620) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = _columnCount(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final cardHeight = columns >= 3 ? 168.0 : 176.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            assets.length,
            (i) => SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: i == 0
                  ? TutorialTargetAnchor(
                      id: 'home.assetCard',
                      child: AssetGridCard(asset: assets[i]),
                    )
                  : AssetGridCard(asset: assets[i]),
            ),
          ),
        );
      },
    );
  }
}

class HomeHeroHeader extends StatelessWidget {
  final AppStore store;
  final int visibleCount;
  const HomeHeroHeader({
    super.key,
    required this.store,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appDisplayName(context),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.normal,
                    letterSpacing: -.28,
                    color: dark ? Colors.white : kText,
                    height: 1.0,
                  ),
                ),
              ),
              _HeaderGlassPill(
                onSearch: () {
                  lightHaptic();
                  showSearchSheet(context);
                },
                onFilter: () {
                  lightHaptic();
                  showFilterSheet(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          TutorialTargetAnchor(
            id: 'home.overview',
            child: AssetOverviewCard(store: store, visibleCount: visibleCount),
          ),
        ],
      ),
    );
  }
}

class HomeTopGradientWash extends StatelessWidget {
  const HomeTopGradientWash({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isDark) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07151C), Color(0xFF0A0D0E), Color(0x000A0D0E)],
            stops: [0, .58, 1],
          ),
        ),
      );
    }
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFBFEAFF),
                  Color(0xFFD9F3FF),
                  Color(0xFFF6FCFF),
                  Color(0x00FFFFFF),
                ],
                stops: [0, .42, .74, 1],
              ),
            ),
          ),
        ),
        Positioned(
          right: -64,
          top: -52,
          width: 230,
          height: 230,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(.62),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -70,
          top: 78,
          width: 210,
          height: 210,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [kBrand.withOpacity(.22), kBrand.withOpacity(0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderGlassPill extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  const _HeaderGlassPill({required this.onSearch, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withOpacity(.10)
                : Colors.white.withOpacity(.64),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(context.isDark ? .12 : .76),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onSearch,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.search_rounded, size: 25),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onFilter,
                child: const SizedBox(
                  width: 46,
                  height: 48,
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetOverviewCard extends StatelessWidget {
  final AppStore store;
  final int visibleCount;
  const AssetOverviewCard({
    super.key,
    required this.store,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = math.max(store.assets.length, 1);
    final serving = store.statusCount(AssetStatus.serving);
    final retired = store.statusCount(AssetStatus.retired);
    final sold = store.statusCount(AssetStatus.sold);
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: BoxDecoration(
        color: dark
            ? kCardDark.withOpacity(.98)
            : Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(dark ? .08 : .85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? .28 : .055),
            blurRadius: 30,
            spreadRadius: -16,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: kBrand.withOpacity(dark ? .04 : .13),
            blurRadius: 24,
            spreadRadius: -16,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '资产总览',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  letterSpacing: .15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withOpacity(.07)
                      : const Color(0xFFF3F3F4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$visibleCount/${store.assets.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12.5,
                    color: dark
                        ? Colors.white.withOpacity(.70)
                        : const Color(0xFF4F5056),
                    letterSpacing: -.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: _OverviewMoneyBlock(
                  label: '总资产',
                  value: store.getTotalAssetValue(),
                  store: store,
                  emphasized: true,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 10,
                child: _OverviewMoneyBlock(
                  label: '日均成本',
                  value: store.getAverageDailyCost(),
                  store: store,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const DottedDivider(),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: StatusProgress(
                  label: '服 役 中',
                  count: serving,
                  total: total,
                  color: kBrandStrong,
                  onTap: () => store.setStatusFilter('serving'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusProgress(
                  label: '已 退 役',
                  count: retired,
                  total: total,
                  color: const Color(0xFFFFC400),
                  onTap: () => store.setStatusFilter('retired'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusProgress(
                  label: '已 卖 出',
                  count: sold,
                  total: total,
                  color: const Color(0xFFA6A6AA),
                  onTap: () => store.setStatusFilter('sold'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMoneyBlock extends StatelessWidget {
  final String label;
  final double value;
  final AppStore store;
  final bool emphasized;
  const _OverviewMoneyBlock({
    required this.label,
    required this.value,
    required this.store,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final amountStyle = TextStyle(
      color: dark ? Colors.white.withOpacity(.94) : const Color(0xFF202124),
      fontWeight: FontWeight.w700,
      fontSize: emphasized ? 26 : 24,
      height: 1.04,
      letterSpacing: -1.05,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        lightHaptic();
        showNativeSnack(context, '$label：${money(value, store.settings)}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: dark
                    ? Colors.white.withOpacity(.46)
                    : const Color(0xFF9DA0A6),
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            RollingMoney(
              value: value,
              settings: store.settings,
              style: amountStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusProgress extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final VoidCallback? onTap;
  const StatusProgress({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : (count / total).clamp(0.0, 1.0);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap == null
          ? null
          : () {
              lightHaptic();
              onTap!.call();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: 13,
                  color: kMuted,
                  fontWeight: FontWeight.normal,
                ),
                children: [
                  TextSpan(text: label),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: '$count',
                    style: TextStyle(
                      color: context.isDark
                          ? Colors.white.withOpacity(.82)
                          : kText,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    height: 7,
                    color: context.isDark
                        ? Colors.white.withOpacity(.08)
                        : const Color(0xFFEDEEEF),
                  ),
                  AnimatedFractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    duration: const Duration(milliseconds: 560),
                    curve: Curves.easeOutCubic,
                    child: Container(height: 7, color: color),
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

class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = math.max(1, (constraints.maxWidth / 9).floor());
      return Row(
        children: List.generate(
          count,
          (i) => Expanded(
            child: Container(
              height: 1.2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: kMuted.withOpacity(.13),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class OverviewMini extends StatelessWidget {
  final String label;
  final String value;
  final bool numeric;
  const OverviewMini({
    super.key,
    required this.label,
    required this.value,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(.08)
            : Colors.white.withOpacity(0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          numeric
              ? FlipText(
                  value,
                  style: TextStyle(
                    color: context.isDark
                        ? Colors.white.withOpacity(.92)
                        : kBrandInk,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                )
              : Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.isDark
                        ? Colors.white.withOpacity(.92)
                        : kBrandInk,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.isDark
                  ? Colors.white.withOpacity(.58)
                  : const Color(0xB3071D2B),
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class RollingMoney extends StatefulWidget {
  final double value;
  final AppSettings settings;
  final TextStyle style;
  const RollingMoney({
    super.key,
    required this.value,
    required this.settings,
    required this.style,
  });
  @override
  State<RollingMoney> createState() => _RollingMoneyState();
}

class _RollingMoneyState extends State<RollingMoney>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double from = 0;
  double to = 0;
  int _lastTick = -1;

  @override
  void initState() {
    super.initState();
    final shouldIntroAnimate = widget.value.abs() > 0.005;
    from = shouldIntroAnimate ? 0 : widget.value;
    to = widget.value;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
      value: shouldIntroAnimate ? 0 : 1,
    )..addListener(_tickHaptics);
    if (shouldIntroAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.forward(from: 0);
      });
    }
  }

  void _tickHaptics() {
    if ((to - from).abs() < 0.005) return;
    final tick = (controller.value * 5).floor();
    if (tick != _lastTick && tick >= 1 && tick <= 5) {
      _lastTick = tick;
      if (tick >= 5) {
        lightHaptic();
      } else {
        selectionHaptic();
      }
    }
  }

  @override
  void didUpdateWidget(covariant RollingMoney oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      from = oldWidget.value;
      to = widget.value;
      _lastTick = -1;
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_tickHaptics);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(controller.value);
        final v = from + (to - from) * t;
        final tilt = (1 - t) * .52;
        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateX(tilt),
          child: Opacity(
            opacity: .38 + .62 * t,
            child: Text(
              money(v, widget.settings),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

class FlipText extends StatelessWidget {
  final String value;
  final TextStyle style;
  const FlipText(this.value, {super.key, required this.style});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: .88, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

class InsightStrip extends StatelessWidget {
  final AppStore store;
  const InsightStrip({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final insights = store.assetInsights();
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: insights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = insights[index];
          return Container(
            width: math.min(MediaQuery.sizeOf(context).width * .78, 330),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.isDark ? kCardDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: item.color.withOpacity(.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(context.isDark ? 0 : .04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kMuted,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LifecycleDashboardCard extends StatelessWidget {
  final AppStore store;
  const LifecycleDashboardCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final totalCost = store.getTotalPurchaseCost();
    final totalValue = store.getTotalAssetValue();
    final recovered = store.getLifecycleRecoveredValue();
    final consumed = store.getLifecycleNetConsumption().toDouble();
    final netPosition = store.getNetAssetPosition();
    final maxValue = math.max(math.max(totalCost, totalValue + recovered), 1.0);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kBrand.withOpacity(.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: kBrandStrong,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '资产生命账本',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '把买入、持有、闲置、卖出放在同一张账里看。',
                      style: TextStyle(color: kMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => showRecoveryRecordSheet(context, store),
                icon: const Icon(Icons.add_rounded, size: 17),
                label: const Text('记录收益'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Row(
              children: [
                Flexible(
                  flex: math.max((totalValue / maxValue * 1000).round(), 1),
                  child: Container(height: 10, color: kBrandStrong),
                ),
                Flexible(
                  flex: math.max((recovered / maxValue * 1000).round(), 1),
                  child: Container(height: 10, color: const Color(0xFF4ADE80)),
                ),
                Flexible(
                  flex: math.max(
                    (math.max(consumed, 0) / maxValue * 1000).round(),
                    1,
                  ),
                  child: Container(height: 10, color: const Color(0xFFFFB020)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridWrap(
            children: [
              DetailCell(
                label: '累计投入',
                value: money(totalCost, store.settings),
              ),
              DetailCell(
                label: '当前净值',
                value: money(totalValue, store.settings),
              ),
              DetailCell(
                label: '价值回收',
                value: money(recovered, store.settings),
              ),
              DetailCell(label: '净消耗', value: money(consumed, store.settings)),
            ],
          ),
        ],
      ),
    );
  }
}

class AssetTimeMachineCard extends StatelessWidget {
  final AppStore store;
  const AssetTimeMachineCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final latest = store.snapshots.isEmpty ? null : store.snapshots.first;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        tapHaptic();
        showBackupManager(context);
      },
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFA78BFA).withOpacity(.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFFA78BFA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '资产时光机',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    latest == null
                        ? '还没有快照。点这里进入快照管理，可创建、恢复和删除。'
                        : '已有 ${store.snapshots.length} 份快照，点这里管理 / 恢复 / 删除。最近：${latest.label}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.manage_history_rounded, color: kBrandStrong),
          ],
        ),
      ),
    );
  }
}

class WalletLeakCard extends StatelessWidget {
  final AppStore store;
  const WalletLeakCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final leaks = store.walletLeaks(limit: 3);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: kDanger),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '钱包漏洞警报',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '优先关注这些还在吞预算、但可能没有被充分使用的资产。',
            style: TextStyle(color: kMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...leaks.map(
            (item) => InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(
                context,
              ).push(softRoute(AssetDetailPage(assetId: item.asset.id))),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    AssetIcon(asset: item.asset, size: 42),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.asset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.reason} · ${money(item.asset.dailyCost, store.settings)} /天',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: kMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: kMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusAndViewRow extends StatelessWidget {
  final AppStore store;
  const StatusAndViewRow({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final status = [
      ('全部', 'all'),
      ('服役中', 'serving'),
      ('退役', 'retired'),
      ('卖出', 'sold'),
    ];
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: status
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item.$1),
                        selected: store.statusFilter == item.$2,
                        onSelected: (_) {
                          tapHaptic();
                          store.setStatusFilter(item.$2);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        HeaderIcon(
          icon: Icons.sort_rounded,
          size: 40,
          onTap: () => showSortSheet(context),
        ),
        const SizedBox(width: 6),
        HeaderIcon(
          icon: Icons.more_horiz_rounded,
          size: 40,
          onTap: () => showFilterSheet(context),
        ),
      ],
    );
  }
}

class CategoryStrip extends StatelessWidget {
  final AppStore store;
  const CategoryStrip({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterPill(
            label: '全部',
            active: store.categoryFilter == 'all',
            onTap: () {
              tapHaptic();
              store.setCategoryFilter('all');
            },
          ),
          FilterPill(
            label: '未分类',
            active: store.categoryFilter == 'uncategorized',
            onTap: () {
              tapHaptic();
              store.setCategoryFilter('uncategorized');
            },
          ),
          ...store.categories.map(
            (c) => FilterPill(
              label: '${c.icon} ${c.name}',
              active: store.categoryFilter == c.id,
              onTap: () {
                tapHaptic();
                store.setCategoryFilter(c.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const FilterPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          tapHaptic();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? kBrand : (context.isDark ? kSoftDark : kSoft),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? (context.isDark ? kBrandInk : kBrandInk)
                  : (context.isDark ? Colors.white.withOpacity(.86) : kText),
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const HeaderIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        lightHaptic();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.70),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(context.isDark ? 0.08 : 0.68),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDark ? 0.20 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.50),
      ),
    );
  }
}

class DueSoonCard extends StatelessWidget {
  final AppStore store;
  const DueSoonCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final rows = store.dueSoonAssets();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.event_available_rounded, color: Color(0xFFFFB020)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '到期提醒',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '订阅、保修、会员和租赁类资产，适合提前做续费/退订/流转决策。',
            style: TextStyle(color: kMuted, height: 1.35),
          ),
          const SizedBox(height: 12),
          ...rows.map((asset) {
            final days = math.max(
              asset.expiresAt!.difference(DateTime.now()).inDays,
              0,
            );
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AssetIcon(asset: asset, size: 42),
              title: Text(
                asset.name,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              subtitle: Text('${dateText(asset.expiresAt!)} 到期 · 剩余 $days 天'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(
                context,
              ).push(softRoute(AssetDetailPage(assetId: asset.id))),
            );
          }),
        ],
      ),
    );
  }
}

class AssetGridCard extends StatelessWidget {
  final Asset asset;
  const AssetGridCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        lightHaptic();
        Navigator.of(
          context,
        ).push(softRoute(AssetDetailPage(assetId: asset.id)));
      },
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssetCardIcon(asset: asset, size: 58),
                  const Spacer(),
                  StatusBadge(status: asset.status),
                ],
              ),
              const Spacer(),
              Text(
                asset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.2,
                  fontWeight: FontWeight.normal,
                  height: 1.14,
                  letterSpacing: -.08,
                ),
              ),
              const SizedBox(height: 4),
              HomeAssetMetaLine(asset: asset, store: store, baseFontSize: 12.0),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: money(asset.dailyCost, store.settings),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18.2,
                        height: 1,
                        letterSpacing: -.45,
                        color: context.isDark
                            ? Colors.white.withOpacity(.92)
                            : kText,
                      ),
                    ),
                    const TextSpan(
                      text: '/天',
                      style: TextStyle(
                        color: kMuted,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetListTileCard extends StatelessWidget {
  final Asset asset;
  const AssetListTileCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        lightHaptic();
        Navigator.of(
          context,
        ).push(softRoute(AssetDetailPage(assetId: asset.id)));
      },
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              AssetIcon(asset: asset, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            asset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15.5,
                            ),
                          ),
                        ),
                        StatusBadge(status: asset.status),
                      ],
                    ),
                    const SizedBox(height: 5),
                    HomeAssetMetaLine(
                      asset: asset,
                      store: store,
                      baseFontSize: 12.2,
                      spaced: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(asset.dailyCost, store.settings),
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '/天',
                    style: TextStyle(color: kMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetStickerChip extends StatelessWidget {
  final Asset asset;
  const AssetStickerChip({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final width = (MediaQuery.sizeOf(context).width - 42) / 2;
    final hash = asset.id.hashCode.abs();
    final tilt = [-0.035, 0.026, -0.018, 0.038, -0.028][hash % 5];
    final tones = [
      const Color(0xFFFFFFFF),
      const Color(0xFFFFFEF8),
      const Color(0xFFF8FBFF),
      const Color(0xFFFBFFF5),
      const Color(0xFFFFF8FB),
    ];
    final bg = context.isDark ? kCardDark : tones[hash % tones.length];
    return Transform.rotate(
      angle: tilt,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => Navigator.of(
          context,
        ).push(softRoute(AssetDetailPage(assetId: asset.id))),
        child: Container(
          width: width.clamp(146.0, 210.0).toDouble(),
          height: 166,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(context.isDark ? .05 : .72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? .28 : .065),
                blurRadius: 26,
                spreadRadius: -8,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssetCardIcon(asset: asset, size: 58),
                  const Spacer(),
                  StatusBadge(status: asset.status),
                ],
              ),
              const Spacer(),
              Text(
                asset.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  height: 1.18,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: money(asset.dailyCost, store.settings),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 19,
                        letterSpacing: -.55,
                      ),
                    ),
                    const TextSpan(
                      text: ' /天',
                      style: TextStyle(
                        color: kMuted,
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.isDark ? kCardDark.withOpacity(.96) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [softShadow(context)],
        border: Border.all(
          color: (context.isDark ? Colors.white : Colors.black).withOpacity(
            context.isDark ? 0.065 : 0.04,
          ),
        ),
      ),
      child: child,
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: card,
      builder: (context, t, content) => Opacity(
        opacity: t,
        child: Transform.scale(scale: .985 + .015 * t, child: content),
      ),
    );
  }
}

BoxShadow softShadow(BuildContext context) => BoxShadow(
  color: Colors.black.withOpacity(context.isDark ? 0.18 : 0.06),
  blurRadius: 18,
  offset: const Offset(0, 8),
);

class AssetIcon extends StatelessWidget {
  final Asset asset;
  final double size;
  const AssetIcon({super.key, required this.asset, this.size = 54});

  @override
  Widget build(BuildContext context) {
    final c = parseColor(
      context.store.categoryById(asset.categoryId)?.color ?? '#7cc6f2',
    );
    final isImage = isValoraImageIcon(asset.iconValue);
    final isSticker = isImage && isValoraStickerImage(asset.iconValue);
    // 图片封面/裁切贴纸按“方形圆角”稳定显示，避免保存或导入后又被首页圆形容器二次裁掉。
    // Emoji/3D 图标仍保留圆形底，保证不同尺寸设备上的视觉中心一致。
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isImage
                ? (context.isDark
                      ? Colors.white.withOpacity(.045)
                      : const Color(0xFFF6FAFD))
                : c.withOpacity(0.20),
            shape: isImage ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isImage ? BorderRadius.circular(size * .28) : null,
            border: isImage
                ? Border.all(
                    color: (context.isDark ? Colors.white : Colors.black)
                        .withOpacity(.045),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isImage ? (isSticker ? size * .045 : 0) : size * .075,
            ),
            child: valoraIconVisual(
              context,
              asset.iconValue,
              emojiSize: size * .52,
              borderRadius: isImage ? size * .28 : size,
            ),
          ),
        ),
      ),
    );
  }
}

class AssetCardIcon extends StatelessWidget {
  final Asset asset;
  final double size;
  const AssetCardIcon({super.key, required this.asset, this.size = 58});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * .32),
          child: Center(
            child: SizedBox.square(
              dimension: size,
              child: valoraIconVisual(
                context,
                asset.iconValue,
                emojiSize: size * .58,
                borderRadius: size * .32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final AssetStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final dot = status == AssetStatus.serving
        ? kBrandStrong
        : status == AssetStatus.retired
        ? const Color(0xFFFFC400)
        : const Color(0xFFA6A6AA);
    final label = status == AssetStatus.serving
        ? '服役中'
        : status == AssetStatus.retired
        ? '已退役'
        : '已卖出';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(.055)
            : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (context.isDark ? Colors.white : Colors.black).withOpacity(
            .035,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: context.isDark
                  ? Colors.white.withOpacity(.82)
                  : kText.withOpacity(.80),
              fontSize: 11.5,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const MetricTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.isDark ? kSoftDark : kSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: kMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class TargetProgressBar extends StatelessWidget {
  final double ratio;
  final String label;
  const TargetProgressBar({
    super.key,
    required this.ratio,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: kMuted, fontSize: 12),
              ),
            ),
            Text(
              '${(ratio * 100).round()}%',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: context.isDark
                ? Colors.white12
                : const Color(0xFFE7EDF2),
            color: kBrandStrong,
          ),
        ),
      ],
    );
  }
}

class TinyTag extends StatelessWidget {
  final String label;
  final Color color;
  const TinyTag({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.isDark
              ? Colors.white.withOpacity(.86)
              : (color.computeLuminance() > 0.55 ? kText : color),
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 31)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

void showSearchSheet(BuildContext context) {
  final store = context.store;
  final controller = TextEditingController(text: store.query);
  appSheet(
    context,
    title: '搜索资产',
    subtitle: '输入名称、标签、分类或备注关键字来筛选。',
    child: Column(
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: '搜索资产、标签、备注',
          ),
          onChanged: store.setQuery,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.clear();
                  store.setQuery('');
                },
                child: const Text('清空搜索'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('完成'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void showFilterSheet(BuildContext context) {
  final store = context.store;
  appSheet(
    context,
    title: '筛选',
    subtitle: '这里放一些不会打断浏览的补充过滤。',
    child: StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          children: [
            SwitchListTile(
              value: store.taggedOnly,
              onChanged: (v) {
                tapHaptic();
                setLocal(() => store.setAdvancedFilters(taggedOnlyValue: v));
              },
              title: const Text(
                '仅看有标签',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              subtitle: const Text('排除还没整理过的资产'),
            ),
            SwitchListTile(
              value: store.targetedOnly,
              onChanged: (v) {
                tapHaptic();
                setLocal(() => store.setAdvancedFilters(targetedOnlyValue: v));
              },
              title: const Text(
                '仅看有目标',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              subtitle: const Text('只看已设置日耗目标的资产'),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      store.resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('重置筛选'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('完成'),
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

void showSortSheet(BuildContext context) {
  final store = context.store;
  appSheet(
    context,
    title: '排序与视图',
    subtitle: '切换资产列表的默认排序方式和展示方式。',
    child: StatefulBuilder(
      builder: (context, setLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('排序'),
            Wrap(
              spacing: 8,
              children: SortMode.values
                  .map(
                    (mode) => ChoiceChip(
                      label: Text(mode.label),
                      selected: store.sortMode == mode,
                      onSelected: (_) {
                        tapHaptic();
                        setLocal(() => store.setSortMode(mode));
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const SectionLabel('首页风格'),
            Wrap(
              spacing: 8,
              children: HomeViewMode.values
                  .map(
                    (mode) => ChoiceChip(
                      label: Text(mode.label),
                      selected: store.viewMode == mode,
                      onSelected: (_) {
                        tapHaptic();
                        setLocal(() => store.setViewMode(mode));
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('完成'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> appSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Widget child,
}) async {
  mediumHaptic();
  await Navigator.of(context).push(
    softRoute(
      _AppSheetRoutePage(title: title, subtitle: subtitle, child: child),
      style: ValoraRouteStyle.sheet,
    ),
  );
}

class _AppSheetRoutePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _AppSheetRoutePage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageFrame(
            padding: EdgeInsets.fromLTRB(
              14,
              70 + MediaQuery.paddingOf(context).top,
              14,
              116 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? kCardDark.withOpacity(.88)
                      : Colors.white.withOpacity(.92),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(context.isDark ? .12 : .72),
                  ),
                  boxShadow: [softShadow(context)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kMuted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ],
          ),
          GlobalBackButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
    ),
  );
}
