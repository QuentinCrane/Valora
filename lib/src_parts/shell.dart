part of '../main.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;
  bool _handledInitialIntent = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: index);
    NativeBridge.listenIncomingIntents(_handleIntentInfo);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handledInitialIntent) return;
      _handledInitialIntent = true;
      _handleIntentInfo(await NativeBridge.getInitialIntentInfo() ?? '');
      if (!mounted) return;
      _prewarmAnalyticsSnapshot();
      final store = context.store;
      if (!store.settings.onboardingCompleted) {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (mounted && !store.settings.onboardingCompleted) {
          await showOnboardingTutorial(context, markSeen: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleIntentInfo(String raw) {
    if (!mounted || raw.isEmpty) return;
    if (raw.contains('com.valora.assets.ADD_WISH')) {
      openCompose(context, ComposeTab.wish);
    } else if (raw.contains('com.valora.assets.ADD_ASSET')) {
      openCompose(context, ComposeTab.asset);
    }
  }

  void _prewarmAnalyticsSnapshot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 预先把分析页所需的聚合数据缓存好，避免从设置页切到分析页时首帧卡顿。
      context.store.analyticsSnapshot;
    });
  }

  void _goToTab(int v) {
    final next = v.clamp(0, 3).toInt();
    if (next == index) {
      lightHaptic();
      if (next == 2 || next == 3) _prewarmAnalyticsSnapshot();
      return;
    }
    if (next == 2 || next == 3) _prewarmAnalyticsSnapshot();
    tapHaptic();
    setState(() => index = next);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 430),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AssetHomePage(),
      WishHomePage(),
      AnalyticsHomePage(),
      SettingsHomePage(),
    ];
    return GradientScaffold(
      child: Stack(
        children: [
          if (index == 0)
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
                  clipBehavior: Clip.hardEdge,
                  pageSnapping: true,
                  allowImplicitScrolling: false,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (v) {
                    if (v == 2 || v == 3) _prewarmAnalyticsSnapshot();
                    if (v != index) {
                      lightHaptic();
                      setState(() => index = v);
                    }
                  },
                  children: pages,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12 + MediaQuery.paddingOf(context).bottom,
                  child: LiquidDock(
                    index: index,
                    onChanged: _goToTab,
                    onAdd: () => openCompose(
                      context,
                      index == 1 ? ComposeTab.wish : ComposeTab.asset,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openCompose(BuildContext context, ComposeTab tab) {
    mediumHaptic();
    Navigator.of(context).push(softRoute<void>(ComposePage(initialTab: tab)));
  }
}

class LiquidDock extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  const LiquidDock({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  State<LiquidDock> createState() => _LiquidDockState();
}

class _LiquidDockState extends State<LiquidDock> {
  bool _dragging = false;
  int? _previewIndex;
  double _fingerX = 0;

  int _indexFromLocalX(double x, double width) {
    final itemWidth = math.max(width / 4, 1.0);
    return (x / itemWidth).floor().clamp(0, 3).toInt();
  }

  void _startDockSlide(DragStartDetails details, double width) {
    final next = _indexFromLocalX(details.localPosition.dx, width);
    _dragging = true;
    _previewIndex = next;
    _fingerX = details.localPosition.dx.clamp(0.0, width).toDouble();
    selectionHaptic();
    setState(() {});
  }

  void _updateDockSlide(DragUpdateDetails details, double width) {
    if (!_dragging) return;
    final next = _indexFromLocalX(details.localPosition.dx, width);
    _fingerX = details.localPosition.dx.clamp(0.0, width).toDouble();
    if (next != _previewIndex) {
      _previewIndex = next;
      selectionHaptic();
    }
    setState(() {});
  }

  void _endDockSlide() {
    if (!_dragging) return;
    final target = (_previewIndex ?? widget.index).clamp(0, 3).toInt();
    _dragging = false;
    _previewIndex = null;
    _fingerX = 0;
    if (target != widget.index) {
      mediumHaptic();
      widget.onChanged(target);
    } else {
      lightHaptic();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      _DockItem(Icons.home_rounded, '资产'),
      _DockItem(Icons.shopping_bag_rounded, '心愿'),
      _DockItem(Icons.pie_chart_rounded, '分析'),
      _DockItem(Icons.settings_rounded, '设置'),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final dockWidth = math.min(width - 116, 406.0);
    final shownIndex = (_previewIndex ?? widget.index).clamp(0, 3).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TutorialTargetAnchor(
              id: 'shell.dock',
              child: SizedBox(
                width: dockWidth,
                height: 72,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final itemW = w / 4;
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (d) => _startDockSlide(d, w),
                      onHorizontalDragUpdate: (d) => _updateDockSlide(d, w),
                      onHorizontalDragEnd: (_) => _endDockSlide(),
                      onHorizontalDragCancel: _endDockSlide,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _WaterDropShell(borderRadius: 999),
                          ),
                          AnimatedPositioned(
                            duration: _dragging
                                ? Duration.zero
                                : const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                            left: itemW * shownIndex + 5,
                            top: 6,
                            width: math.max(itemW - 10, 48),
                            height: 60,
                            child: _DockLiquidThumb(dragging: _dragging),
                          ),
                          if (_dragging)
                            Positioned(
                              left: (_fingerX - 33).clamp(
                                0.0,
                                math.max(w - 66, 0),
                              ),
                              top: 4,
                              width: 66,
                              height: 64,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(.42),
                                        kBrand.withOpacity(.11),
                                        Colors.white.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            children: List.generate(items.length, (i) {
                              final active = i == shownIndex;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    tapHaptic();
                                    widget.onChanged(i);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 230),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AnimatedScale(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          scale: active ? 1.08 : .96,
                                          child: Icon(
                                            items[i].icon,
                                            size: active ? 24 : 22,
                                            color: active
                                                ? (context.isDark
                                                      ? Colors.white
                                                            .withOpacity(.94)
                                                      : kText.withOpacity(.92))
                                                : kMuted.withOpacity(
                                                    context.isDark ? .60 : .54,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 240,
                                          ),
                                          width: active ? 18 : 4,
                                          height: active ? 3 : 2,
                                          decoration: BoxDecoration(
                                            color: active
                                                ? kBrandStrong.withOpacity(.92)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TutorialTargetAnchor(
            id: 'shell.addButton',
            child: GlassAddButton(
              onTap: () {
                mediumHaptic();
                widget.onAdd();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterDropShell extends StatelessWidget {
  final double borderRadius;
  const _WaterDropShell({required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final baseGradient = dark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kDarkBlueSoft.withOpacity(.46),
              kDarkBlue.withOpacity(.28),
              const Color(0xFF061522).withOpacity(.22),
            ],
            stops: const [0, .50, 1],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(.42),
              Colors.white.withOpacity(.20),
              kBrand.withOpacity(.055),
              Colors.white.withOpacity(.14),
            ],
            stops: const [0, .38, .72, 1],
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: dark ? 16 : 18,
          sigmaY: dark ? 16 : 18,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: baseGradient,
                  border: Border.all(
                    color: (dark ? kBrand : Colors.white).withOpacity(
                      dark ? .24 : .50,
                    ),
                    width: dark ? .85 : 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? .34 : .105),
                      blurRadius: 28,
                      spreadRadius: -14,
                      offset: const Offset(0, 18),
                    ),
                    if (!dark)
                      BoxShadow(
                        color: kBrand.withOpacity(.12),
                        blurRadius: 30,
                        spreadRadius: -18,
                        offset: const Offset(0, 10),
                      ),
                    if (!dark)
                      BoxShadow(
                        color: Colors.white.withOpacity(.34),
                        blurRadius: 20,
                        spreadRadius: -12,
                        offset: const Offset(-8, -8),
                      ),
                  ],
                ),
              ),
            ),
            // Keep only rim lighting; remove strip-style glossy highlights.
            Positioned(
              left: 1,
              right: 1,
              top: 1,
              height: 1.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  color: (dark ? kBrand : Colors.white).withOpacity(
                    dark ? .16 : .26,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 1,
              right: 1,
              bottom: 1,
              height: 1.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(borderRadius),
                  ),
                  color: (dark ? kBrand : Colors.white).withOpacity(
                    dark ? .07 : .16,
                  ),
                ),
              ),
            ),
            if (!dark)
              Positioned(
                right: 12,
                bottom: 8,
                width: 76,
                height: 34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: RadialGradient(
                      colors: [
                        kBrand.withOpacity(.20),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockLiquidThumb extends StatelessWidget {
  final bool dragging;
  const _DockLiquidThumb({required this.dragging});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: dark
                  ? kDarkBlueSoft.withOpacity(.42)
                  : Colors.white.withOpacity(.26),
              border: Border.all(
                color: (dark ? kBrand : Colors.white).withOpacity(
                  dark ? .24 : .56,
                ),
                width: 1,
              ),
              boxShadow: [
                if (!dark)
                  BoxShadow(
                    color: Colors.white.withOpacity(.38),
                    blurRadius: dragging ? 20 : 14,
                    spreadRadius: -8,
                    offset: const Offset(-3, -4),
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? .18 : .045),
                  blurRadius: dragging ? 20 : 14,
                  spreadRadius: -8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            width: 28,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    kBrand.withOpacity(dark ? .14 : .18),
                    Colors.white.withOpacity(0),
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

class GlassAddButton extends StatefulWidget {
  final VoidCallback onTap;
  const GlassAddButton({super.key, required this.onTap});

  @override
  State<GlassAddButton> createState() => _GlassAddButtonState();
}

class _GlassAddButtonState extends State<GlassAddButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: down ? .94 : 1,
        child: SizedBox(
          width: 72,
          height: 72,
          child: ClipOval(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: _WaterDropShell(borderRadius: 999),
                ),
                Positioned(
                  right: 13,
                  bottom: 14,
                  width: 26,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          kBrand.withOpacity(.24),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 34,
                    color: context.isDark
                        ? Colors.white.withOpacity(.92)
                        : kText.withOpacity(.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  final IconData icon;
  final String label;
  const _DockItem(this.icon, this.label);
}

class PageFrame extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  const PageFrame({super.key, required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(14, 16, 14, 116),
      children: children,
    );
  }
}
