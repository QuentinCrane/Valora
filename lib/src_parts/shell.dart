part of '../main.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> with TickerProviderStateMixin {
  int index = 0;
  bool _handledInitialIntent = false;
  bool _autoShowingOnboarding = false;
  bool _onboardingPromptShown = false;
  bool _dockMagicActive = false;
  bool _addMagicActive = false;
  _OnboardingOverlayRequest? _onboardingRequest;
  int _onboardingIndex = 0;
  Timer? _onboardingRetryTimer;
  late final PageController _pageController;
  late final AnimationController _dockGlassController;
  late final AnimationController _addGlassController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: index);
    _dockGlassController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 460),
        reverseDuration: const Duration(milliseconds: 460))
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _addGlassController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 360),
        reverseDuration: const Duration(milliseconds: 360))
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _onboardingOverlayRequest.addListener(_handleOnboardingRequest);
    NativeBridge.listenIncomingIntents(_handleIntentInfo);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handledInitialIntent) return;
      _handledInitialIntent = true;
      _handleIntentInfo(await NativeBridge.getInitialIntentInfo() ?? '');
      if (!mounted) return;
      _prewarmAnalyticsSnapshot();
      await _maybeAutoStartOnboarding();
    });
  }

  Future<void> _maybeAutoStartOnboarding() async {
    final store = context.store;
    if (store.settings.onboardingCompleted ||
        _autoShowingOnboarding ||
        _onboardingPromptShown ||
        _onboardingRequest != null) return;
    _autoShowingOnboarding = true;
    _onboardingPromptShown = true;
    _onboardingRetryTimer?.cancel();
    try {
      if (_pageController.hasClients) _pageController.jumpToPage(0);
      if (index != 0 && mounted) setState(() => index = 0);
      // Do not auto-open the overlay anymore. First launch can be busy with
      // intent handling, PageView layout, store hydration and glass capture.
      // A stable consent dialog avoids the old "flash and disappear" race.
      await Future<void>.delayed(const Duration(milliseconds: 520));
      if (!mounted ||
          store.settings.onboardingCompleted ||
          _onboardingRequest != null) return;
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) return;
      final agreed = await _showOnboardingPrompt();
      if (!mounted ||
          store.settings.onboardingCompleted ||
          _onboardingRequest != null) return;
      if (agreed == true) {
        _beginOnboarding(_OnboardingOverlayRequest(
            markSeen: true, completer: Completer<void>()));
      }
      // If the user declines, do not mark the tutorial as completed. It will be
      // offered again on next app launch because the user still has not watched
      // it once.
    } finally {
      _autoShowingOnboarding = false;
    }
  }

  Future<bool?> _showOnboardingPrompt() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  color: dark
                      ? kCardDark.withOpacity(.94)
                      : Colors.white.withOpacity(.94),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: dark
                          ? Colors.white.withOpacity(.10)
                          : Colors.white.withOpacity(.78)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(dark ? .28 : .10),
                        blurRadius: 28,
                        offset: const Offset(0, 14))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kBrand.withOpacity(dark ? .22 : .16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(Icons.school_rounded,
                            color: dark ? Colors.white : kText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(tr('shell.tutorial.promptTitle'),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: dark ? Colors.white : kText))),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      tr('shell.tutorial.promptDesc'),
                      style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: dark ? Colors.white.withOpacity(.72) : kMuted),
                    ),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(tr('shell.tutorial.notNow')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text(tr('shell.tutorial.start')),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleOnboardingRequest() {
    final request = _onboardingOverlayRequest.value;
    if (request == null || !mounted) return;
    _onboardingOverlayRequest.value = null;
    _beginOnboarding(request);
  }

  void _beginOnboarding(_OnboardingOverlayRequest request) {
    if (_onboardingRequest != null) {
      if (!request.completer.isCompleted) request.completer.complete();
      return;
    }
    setState(() {
      _onboardingRequest = request;
      _onboardingIndex = 0;
      index = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _settleShellOnboardingTarget());
  }

  @override
  void dispose() {
    _onboardingRetryTimer?.cancel();
    _onboardingOverlayRequest.removeListener(_handleOnboardingRequest);
    _dockGlassController.dispose();
    _addGlassController.dispose();
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

  List<_TutorialStepData> _shellOnboardingSteps(AppStore store) {
    final hasAsset = store.assets.isNotEmpty;
    return <_TutorialStepData>[
      _TutorialStepData(
        title: tr('shell.tutorial.step1Title'),
        subtitle: tr('shell.tutorial.step1Subtitle'),
        hint: tr('shell.tutorial.step1Hint'),
        icon: Icons.inventory_2_rounded,
        color: Color(0xFF7CC6F2),
        stage: _TutorialStage.shell,
        targetId: 'home.overview',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step2Title'),
        subtitle: tr('shell.tutorial.step2Subtitle'),
        hint: tr('shell.tutorial.step2Hint'),
        icon: Icons.tune_rounded,
        color: Color(0xFF8FD0F6),
        stage: _TutorialStage.shell,
        targetId: 'home.filters',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: hasAsset
            ? tr('shell.tutorial.step3TitleA')
            : tr('shell.tutorial.step3TitleB'),
        subtitle: hasAsset
            ? tr('shell.tutorial.step3SubtitleA')
            : tr('shell.tutorial.step3SubtitleB'),
        hint: hasAsset
            ? tr('shell.tutorial.step3HintA')
            : tr('shell.tutorial.step3HintB'),
        icon: Icons.view_agenda_rounded,
        color: const Color(0xFF9FD8F8),
        stage: _TutorialStage.shell,
        targetId: hasAsset ? 'home.assetCard' : 'home.empty',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step4Title'),
        subtitle: tr('shell.tutorial.step4Subtitle'),
        hint: tr('shell.tutorial.step4Hint'),
        icon: Icons.space_dashboard_rounded,
        color: Color(0xFFFFDC65),
        stage: _TutorialStage.shell,
        targetId: 'shell.dock',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step5Title'),
        subtitle: tr('shell.tutorial.step5Subtitle'),
        hint: tr('shell.tutorial.step5Hint'),
        icon: Icons.add_circle_rounded,
        color: Color(0xFFBDEB7E),
        stage: _TutorialStage.shell,
        targetId: 'shell.addButton',
        tabIndex: 0,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step6Title'),
        subtitle: tr('shell.tutorial.step6Subtitle'),
        hint: tr('shell.tutorial.step6Hint'),
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE8F7FE),
        stage: _TutorialStage.shell,
        targetId: 'wish.summary',
        tabIndex: 1,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step7Title'),
        subtitle: tr('shell.tutorial.step7Subtitle'),
        hint: tr('shell.tutorial.step7Hint'),
        icon: Icons.analytics_rounded,
        color: Color(0xFF8998F4),
        stage: _TutorialStage.shell,
        targetId: 'analytics.core',
        tabIndex: 2,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step8Title'),
        subtitle: tr('shell.tutorial.step8Subtitle'),
        hint: tr('shell.tutorial.step8Hint'),
        icon: Icons.health_and_safety_rounded,
        color: Color(0xFFC8EBFF),
        stage: _TutorialStage.shell,
        targetId: 'analytics.lifecycle',
        tabIndex: 2,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step9Title'),
        subtitle: tr('shell.tutorial.step9Subtitle'),
        hint: tr('shell.tutorial.step9Hint'),
        icon: Icons.settings_rounded,
        color: Color(0xFFD8E7FF),
        stage: _TutorialStage.shell,
        targetId: 'settings.menu',
        tabIndex: 3,
      ),
      _TutorialStepData(
        title: tr('shell.tutorial.step10Title'),
        subtitle: tr('shell.tutorial.step10Subtitle'),
        hint: tr('shell.tutorial.step10Hint'),
        icon: Icons.school_rounded,
        color: Color(0xFFBDEB7E),
        stage: _TutorialStage.shell,
        targetId: 'settings.quick',
        tabIndex: 3,
      ),
    ];
  }

  Future<void> _settleShellOnboardingTarget() async {
    if (!mounted || _onboardingRequest == null) return;
    final steps = _shellOnboardingSteps(context.store);
    if (_onboardingIndex >= steps.length) return;
    final step = steps[_onboardingIndex];
    if (index != step.tabIndex) {
      setState(() => index = step.tabIndex.clamp(0, 3).toInt());
      if (_pageController.hasClients) {
        await _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic);
      }
    }
    for (final delay in const [120, 260, 420]) {
      await Future<void>.delayed(Duration(milliseconds: delay));
      if (!mounted || _onboardingRequest == null) return;
      await _TutorialTargetRegistry.ensureVisible(
          step.targetId, MediaQuery.sizeOf(context));
      if (mounted) setState(() {});
    }
  }

  Future<void> _advanceOnboarding(int next) async {
    final request = _onboardingRequest;
    if (request == null) return;
    final steps = _shellOnboardingSteps(context.store);
    if (next < 0) return;
    if (next >= steps.length) {
      await _closeOnboarding(completed: true);
      return;
    }
    selectionHaptic();
    setState(() => _onboardingIndex = next);
    await _settleShellOnboardingTarget();
  }

  Future<void> _closeOnboarding({required bool completed}) async {
    final request = _onboardingRequest;
    if (request == null) return;
    if (request.markSeen && completed) {
      final store = context.store;
      await store
          .updateSettings(store.settings.copyWith(onboardingCompleted: true));
    }
    if (!mounted) return;
    setState(() {
      _onboardingRequest = null;
    });
    if (!request.completer.isCompleted) request.completer.complete();
  }

  void _setDockMagicActive(bool active) {
    if (_dockMagicActive == active || !mounted) return;
    setState(() => _dockMagicActive = active);
    if (active) {
      _dockGlassController.forward();
    } else {
      _dockGlassController.reverse();
    }
  }

  void _setAddMagicActive(bool active) {
    if (_addMagicActive == active || !mounted) return;
    setState(() => _addMagicActive = active);
    if (active) {
      _addGlassController.forward();
    } else {
      _addGlassController.reverse();
    }
  }

  lge.LiquidGlass _buildDockLiquidGlass(BuildContext context, Widget dock,
      EdgeInsets safe, bool dark, double dockWidth, double dockHeight) {
    final raw = _dockGlassController.value.clamp(0.0, 1.0).toDouble();
    final spring = raw == 0
        ? 0.0
        : Curves.easeOutBack.transform(raw).clamp(0.0, 1.18).toDouble();
    final w = dockWidth * (1.0 + .155 * spring);
    final h = dockHeight * (1.0 + .205 * spring);
    final left = math.max(14.0, 24 - (w - dockWidth) / 2);
    final bottom = 14 + safe.bottom - (h - dockHeight) * .18;
    return lge.LiquidGlass(
      key: const ValueKey('valora.shell.dock.lens'),
      width: w,
      height: h,
      position: lge.LiquidGlassAlignPosition(
        alignment: Alignment.bottomLeft,
        margin: EdgeInsets.only(left: left, bottom: bottom),
      ),
      shape: lge.RoundedRectangleShape(
        cornerRadius: 999,
        borderWidth: 1.35 + .42 * spring,
        borderColor: Colors.white.withOpacity(dark ? .32 : .70),
        lightColor: Colors.white.withOpacity(dark ? .78 : .94),
        lightIntensity: 1.55 + .42 * spring,
        lightDirection: 132,
        borderType: lge.OpticalBorder(
          borderSaturation: 1.55 + .26 * spring,
          ambientIntensity: 1.08 + .24 * spring,
          borderSolidity: 0.0,
        ),
      ),
      blur: const lge.LiquidGlassBlur(sigmaX: .002, sigmaY: .002),
      distortion: .112 + .030 * spring,
      distortionWidth: 44 + 10 * spring,
      magnification: 1.052 + .036 * spring,
      chromaticAberration: .00056 + .00014 * spring,
      saturation: 1.065,
      refractionMode: lge.LiquidGlassRefractionMode.shapeRefraction,
      color: Colors.white.withOpacity(dark ? .012 : .018),
      child: dock,
    );
  }

  lge.LiquidGlass _buildAddLiquidGlass(BuildContext context, Widget addButton,
      EdgeInsets safe, bool dark, double addSize) {
    final raw = _addGlassController.value.clamp(0.0, 1.0).toDouble();
    final spring = raw == 0
        ? 0.0
        : Curves.easeOutBack.transform(raw).clamp(0.0, 1.12).toDouble();
    final size = addSize * (1.0 + .105 * spring);
    return lge.LiquidGlass(
      key: const ValueKey('valora.shell.add.lens'),
      width: size,
      height: size,
      position: lge.LiquidGlassAlignPosition(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.only(
            right: 24 - (size - addSize) / 2,
            bottom: 19 + safe.bottom - (size - addSize) / 2),
      ),
      shape: lge.RoundedRectangleShape(
        cornerRadius: 999,
        borderWidth: 1.32 + .26 * spring,
        borderColor: Colors.white.withOpacity(dark ? .28 : .64),
        lightColor: Colors.white.withOpacity(dark ? .74 : .90),
        lightIntensity: 1.48 + .34 * spring,
        lightDirection: 132,
        borderType: lge.OpticalBorder(
          borderSaturation: 1.54 + .24 * spring,
          ambientIntensity: 1.08 + .22 * spring,
          borderSolidity: 0.0,
        ),
      ),
      blur: const lge.LiquidGlassBlur(sigmaX: .003, sigmaY: .003),
      distortion: .096 + .026 * spring,
      distortionWidth: 34 + 7 * spring,
      magnification: 1.044 + .030 * spring,
      chromaticAberration: .00052 + .00014 * spring,
      saturation: 1.055,
      refractionMode: lge.LiquidGlassRefractionMode.shapeRefraction,
      color: Colors.white.withOpacity(dark ? .018 : .026),
      child: addButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AssetHomePage(),
      WishHomePage(),
      AnalyticsHomePage(),
      SettingsHomePage()
    ];
    final media = MediaQuery.of(context);
    final safe = media.padding;
    final screen = media.size;
    final dark = context.isDark;
    final dockWidth =
        math.min(screen.width - 158, 404.0).clamp(238.0, 404.0).toDouble();
    final dockHeight = 76.0;
    final dockMagicScale = _dockMagicActive ? 1.135 : 1.0;
    final dockGlassWidth = dockWidth * dockMagicScale;
    final dockGlassHeight = dockHeight * (_dockMagicActive ? 1.18 : 1.0);
    final dockGlassLeft = math.max(14.0, 24 - (dockGlassWidth - dockWidth) / 2);
    final dockGlassBottom =
        14 + safe.bottom - (dockGlassHeight - dockHeight) * .18;
    final addSize = 66.0;
    final addMagicScale = _addMagicActive ? 1.105 : 1.0;
    final addGlassSize = addSize * addMagicScale;

    final shellBackground = Stack(
      children: [
        if (index == 0)
          const Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 380,
              child: HomeTopGradientWash()),
        SafeArea(
          bottom: false,
          child: PageView(
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
        ),
      ],
    );

    final useLiquidGlass =
        context.store.settings.glassEffectMode == GlassEffectMode.liquid;
    final dock = LiquidDock(
      index: index,
      onChanged: _goToTab,
      useLiquidGlass: useLiquidGlass,
      onInteractionChanged: _setDockMagicActive,
    );
    final addButton = TutorialTargetAnchor(
      id: 'shell.addButton',
      child: GlassAddButton(
        onTap: () => openCompose(
            context, index == 1 ? ComposeTab.wish : ComposeTab.asset),
        onPressChanged: _setAddMagicActive,
      ),
    );

    Widget shellLayer;
    if (useLiquidGlass) {
      shellLayer = lge.LiquidGlassView(
        realTimeCapture: true,
        useSync: true,
        refreshRate: lge.LiquidGlassRefreshRate.deviceRefreshRate,
        pixelRatio: (_dockMagicActive || _addMagicActive) ? .84 : .92,
        backgroundWidget: ValoraGlassSceneBackground(
            child: RepaintBoundary(child: shellBackground)),
        children: [
          _buildDockLiquidGlass(
              context, dock, safe, dark, dockWidth, dockHeight),
          _buildAddLiquidGlass(context, addButton, safe, dark, addSize),
        ],
      );
    } else {
      shellLayer = Stack(children: [
        shellBackground,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          left: dockGlassLeft,
          bottom: dockGlassBottom,
          width: dockGlassWidth,
          height: dockGlassHeight,
          child: ValoraLiquidGlassSurface(
            height: dockGlassHeight,
            radius: 999,
            tintOpacity: .14,
            blurSigma: .42,
            child: dock,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          right: 24 - (addGlassSize - addSize) / 2,
          bottom: 19 + safe.bottom - (addGlassSize - addSize) / 2,
          width: addGlassSize,
          height: addGlassSize,
          child: ValoraLiquidGlassSurface(
            height: addSize,
            radius: 999,
            circular: true,
            tintOpacity: .16,
            blurSigma: .52,
            child: addButton,
          ),
        ),
      ]);
    }

    return GradientScaffold(
      child: Stack(
        children: [
          shellLayer,
          if (_onboardingRequest != null)
            Builder(builder: (context) {
              final tutorialSteps = _shellOnboardingSteps(context.store);
              final safeIndex = _onboardingIndex
                  .clamp(0, math.max(0, tutorialSteps.length - 1))
                  .toInt();
              return Positioned.fill(
                child: _ShellOnboardingOverlay(
                  step: tutorialSteps[safeIndex],
                  index: safeIndex,
                  total: tutorialSteps.length,
                  onPrevious: safeIndex == 0
                      ? null
                      : () => _advanceOnboarding(safeIndex - 1),
                  onNext: () => _advanceOnboarding(safeIndex + 1),
                  onSkip: () => _closeOnboarding(completed: false),
                ),
              );
            }),
        ],
      ),
    );
  }

  void openCompose(BuildContext context, ComposeTab tab) {
    mediumHaptic();
    Navigator.of(context).push(softRoute<void>(ComposePage(initialTab: tab)));
  }
}

class _ShellOnboardingOverlay extends StatelessWidget {
  final _TutorialStepData step;
  final int index;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _ShellOnboardingOverlay({
    required this.step,
    required this.index,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return _MeasuredTutorialOverlay(
      step: step,
      index: index,
      total: total,
      onPrevious: onPrevious,
      onNext: onNext,
      onSkip: onSkip,
    );
  }
}

class LiquidDock extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final bool useLiquidGlass;
  final ValueChanged<bool>? onInteractionChanged;
  const LiquidDock(
      {super.key,
      required this.index,
      required this.onChanged,
      this.useLiquidGlass = true,
      this.onInteractionChanged});

  @override
  State<LiquidDock> createState() => _LiquidDockState();
}

class _LiquidDockState extends State<LiquidDock> {
  bool _dragging = false;
  bool _fingerDown = false;
  int? _previewIndex;
  double _fingerX = 0;

  void _setInteractionActive(bool active) {
    widget.onInteractionChanged?.call(active);
  }

  int _indexFromLocalX(double x, double width) {
    final itemWidth = math.max(width / 4, 1.0);
    return (x / itemWidth).floor().clamp(0, 3).toInt();
  }

  void _setFinger(double x, double width, {bool preview = false}) {
    final next = _indexFromLocalX(x, width);
    _fingerX = x.clamp(0.0, width).toDouble();
    if (preview && next != _previewIndex) {
      _previewIndex = next;
      selectionHaptic();
    }
  }

  void _startDockSlide(DragStartDetails details, double width) {
    _dragging = true;
    _fingerDown = true;
    _setInteractionActive(true);
    _setFinger(details.localPosition.dx, width, preview: true);
    setState(() {});
  }

  void _updateDockSlide(DragUpdateDetails details, double width) {
    if (!_dragging) return;
    _setFinger(details.localPosition.dx, width, preview: true);
    setState(() {});
  }

  void _endDockSlide() {
    if (!_dragging) return;
    final target = (_previewIndex ?? widget.index).clamp(0, 3).toInt();
    _dragging = false;
    _fingerDown = false;
    _setInteractionActive(false);
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

  void _pointerDown(PointerDownEvent event, double width) {
    _fingerDown = true;
    _setInteractionActive(true);
    _setFinger(event.localPosition.dx, width, preview: true);
    setState(() {});
  }

  void _pointerMove(PointerMoveEvent event, double width) {
    if (!_fingerDown && !_dragging) return;
    _fingerX = event.localPosition.dx.clamp(0.0, width).toDouble();
    setState(() {});
  }

  void _pointerUp() {
    if (_dragging) return;
    _fingerDown = false;
    _setInteractionActive(false);
    _previewIndex = null;
    _fingerX = 0;
    setState(() {});
  }

  double _dockScale() {
    // The actual glass lens is enlarged by ShellPage so the whole Dock, not
    // only its contents, grows like the macOS Dock. Keep the inner transform
    // almost neutral to avoid clipping inside the lens.
    return 1.0;
  }

  double _dockLift() {
    if (!_fingerDown && !_dragging) return 0.0;
    return -6.0;
  }

  double _macScaleFor(int index, double itemWidth) {
    final visualIndex = (_dragging || _fingerDown)
        ? (_previewIndex ?? widget.index)
        : widget.index;
    final selectedBase = index == visualIndex ? 1.030 : .985;
    if (!_fingerDown && !_dragging) return selectedBase;
    final center = itemWidth * (index + .5);
    final distance = (center - _fingerX).abs();
    final raw =
        (1.0 - distance / (itemWidth * 1.55)).clamp(0.0, 1.0).toDouble();
    final curved = Curves.easeOutExpo.transform(raw).clamp(0.0, 1.0).toDouble();
    return (selectedBase + curved * .225).clamp(.94, 1.285).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _DockItem(Icons.home_rounded, tr('dock.assets')),
      _DockItem(Icons.shopping_bag_rounded, tr('dock.wishes')),
      _DockItem(Icons.pie_chart_rounded, tr('dock.analytics')),
      _DockItem(Icons.settings_rounded, tr('dock.settings')),
    ];
    final indicatorIndex =
        (_dragging ? (_previewIndex ?? widget.index) : widget.index)
            .clamp(0, 3)
            .toInt();
    return TutorialTargetAnchor(
      id: 'shell.dock',
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 360),
        curve:
            _fingerDown || _dragging ? Curves.easeOutBack : Curves.easeOutCubic,
        offset: Offset(0, _dockLift() / 76),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 360),
          curve: _fingerDown || _dragging
              ? Curves.easeOutBack
              : Curves.easeOutCubic,
          scale: _dockScale(),
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final itemW = w / 4;
                final thumbW = math.max(itemW - 6, 52).toDouble();
                final thumbLeft = (_fingerDown || _dragging)
                    ? (_fingerX - thumbW / 2)
                        .clamp(5.0, math.max(5.0, w - thumbW - 5))
                        .toDouble()
                    : itemW * indicatorIndex + 5;
                return Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) => _pointerDown(event, w),
                  onPointerMove: (event) => _pointerMove(event, w),
                  onPointerUp: (_) => _pointerUp(),
                  onPointerCancel: (_) => _pointerUp(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (d) => _startDockSlide(d, w),
                    onHorizontalDragUpdate: (d) => _updateDockSlide(d, w),
                    onHorizontalDragEnd: (_) => _endDockSlide(),
                    onHorizontalDragCancel: _endDockSlide,
                    child: Stack(children: [
                      AnimatedPositioned(
                        duration: (_fingerDown || _dragging)
                            ? Duration.zero
                            : const Duration(milliseconds: 460),
                        curve: Curves.easeOutBack,
                        left: (thumbLeft - thumbW * .20)
                            .clamp(0.0, math.max(0.0, w - thumbW * 1.40))
                            .toDouble(),
                        top: 1,
                        width: thumbW * 1.40,
                        height: 64,
                        child: _DockLiquidHalo(
                            active: _fingerDown || _dragging,
                            useLiquidGlass: widget.useLiquidGlass),
                      ),
                      AnimatedPositioned(
                        duration: (_fingerDown || _dragging)
                            ? Duration.zero
                            : const Duration(milliseconds: 430),
                        curve: Curves.easeOutBack,
                        left: thumbLeft,
                        top: 3,
                        width: thumbW,
                        height: 60,
                        child: _DockLiquidThumb(
                            dragging: _dragging || _fingerDown,
                            useLiquidGlass: widget.useLiquidGlass),
                      ),
                      Row(
                        children: List.generate(items.length, (i) {
                          final visualIndex = (_dragging || _fingerDown)
                              ? (_previewIndex ?? widget.index)
                              : widget.index;
                          final active = i == visualIndex;
                          final scale = _macScaleFor(i, itemW);
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                tapHaptic();
                                widget.onChanged(i);
                              },
                              child: AnimatedScale(
                                duration: (_fingerDown || _dragging)
                                    ? const Duration(milliseconds: 90)
                                    : const Duration(milliseconds: 330),
                                curve: (_fingerDown || _dragging)
                                    ? Curves.easeOutCubic
                                    : Curves.easeOutBack,
                                scale: scale,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        items[i].icon,
                                        size: active ? 24 : 22,
                                        color: active
                                            ? (context.isDark
                                                ? Colors.white.withOpacity(.95)
                                                : kText.withOpacity(.94))
                                            : kMuted.withOpacity(
                                                context.isDark ? .62 : .56),
                                      ),
                                      const SizedBox(height: 3),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 240),
                                        width: active ? 18 : 4,
                                        height: active ? 3 : 2,
                                        decoration: BoxDecoration(
                                          color: active
                                              ? (context.isDark
                                                  ? Colors.white
                                                      .withOpacity(.82)
                                                  : kText.withOpacity(.70))
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DockLiquidHalo extends StatelessWidget {
  final bool active;
  final bool useLiquidGlass;
  const _DockLiquidHalo({required this.active, required this.useLiquidGlass});

  @override
  Widget build(BuildContext context) {
    if (!useLiquidGlass) return const SizedBox.shrink();
    final dark = context.isDark;
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        opacity: active ? .22 : .06,
        child: CustomPaint(
          painter: _DockHaloPainter(
              dark: dark, active: active, useLiquidGlass: useLiquidGlass),
        ),
      ),
    );
  }
}

class _DockHaloPainter extends CustomPainter {
  final bool dark;
  final bool active;
  final bool useLiquidGlass;
  const _DockHaloPainter(
      {required this.dark, required this.active, required this.useLiquidGlass});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rr =
        RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(999));
    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.20, -.55),
        radius: 1.12,
        colors: useLiquidGlass
            ? (dark
                ? [
                    Colors.white.withOpacity(active ? .11 : .055),
                    Colors.white.withOpacity(.018),
                    Colors.transparent
                  ]
                : [
                    Colors.white.withOpacity(active ? .32 : .18),
                    const Color(0xFFBDEFFF).withOpacity(active ? .10 : .04),
                    Colors.transparent
                  ])
            : (dark
                ? [
                    Colors.white.withOpacity(active ? .20 : .12),
                    Colors.white.withOpacity(.035),
                    Colors.transparent
                  ]
                : [
                    Colors.white.withOpacity(active ? .70 : .42),
                    const Color(0xFFBDEFFF).withOpacity(active ? .18 : .10),
                    Colors.transparent
                  ]),
        stops: const [0, .48, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, body);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 1.1 : .75
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(dark ? .20 : .46),
          const Color(0xFF7CC6F2).withOpacity(dark ? .05 : .12),
          Colors.white.withOpacity(dark ? .10 : .34),
        ],
      ).createShader(rect);
    canvas.drawRRect(rr, edge);
  }

  @override
  bool shouldRepaint(covariant _DockHaloPainter oldDelegate) =>
      oldDelegate.dark != dark ||
      oldDelegate.active != active ||
      oldDelegate.useLiquidGlass != useLiquidGlass;
}

class _DockLiquidThumb extends StatelessWidget {
  final bool dragging;
  final bool useLiquidGlass;
  const _DockLiquidThumb(
      {required this.dragging, required this.useLiquidGlass});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    if (!useLiquidGlass) {
      // 经典毛玻璃模式回到 0.79 一类的轻量胶囊，不再使用额外光球/大 halo。
      return IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: dark
                    ? kDarkBlueSoft.withOpacity(.42)
                    : Colors.white.withOpacity(.26),
                border: Border.all(
                    color: (dark ? kBrand : Colors.white)
                        .withOpacity(dark ? .24 : .56),
                    width: 1),
                boxShadow: [
                  if (!dark)
                    BoxShadow(
                        color: Colors.white.withOpacity(.38),
                        blurRadius: dragging ? 20 : 14,
                        spreadRadius: -8,
                        offset: const Offset(-3, -4)),
                  BoxShadow(
                      color: Colors.black.withOpacity(dark ? .18 : .045),
                      blurRadius: dragging ? 20 : 14,
                      spreadRadius: -8,
                      offset: const Offset(0, 8)),
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
                  gradient: RadialGradient(colors: [
                    kBrand.withOpacity(dark ? .14 : .18),
                    Colors.white.withOpacity(0)
                  ]),
                ),
              ),
            ),
          ]),
        ),
      );
    }
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: dragging ? .42 : .24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: CustomPaint(
          painter: _DockThumbPainter(
              dark: dark, active: dragging, useLiquidGlass: useLiquidGlass),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _DockThumbPainter extends CustomPainter {
  final bool dark;
  final bool active;
  final bool useLiquidGlass;
  const _DockThumbPainter(
      {required this.dark, required this.active, required this.useLiquidGlass});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rr =
        RRect.fromRectAndRadius(rect.deflate(.7), const Radius.circular(999));
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: useLiquidGlass
            ? (dark
                ? [
                    Colors.white.withOpacity(.045),
                    Colors.white.withOpacity(.012),
                    Colors.white.withOpacity(.028)
                  ]
                : [
                    Colors.white.withOpacity(.09),
                    const Color(0xFFEAF9FF).withOpacity(.035),
                    Colors.white.withOpacity(.055)
                  ])
            : (dark
                ? [
                    Colors.white.withOpacity(.14),
                    Colors.white.withOpacity(.040),
                    Colors.white.withOpacity(.08)
                  ]
                : [
                    Colors.white.withOpacity(.58),
                    const Color(0xFFEAF9FF).withOpacity(.24),
                    Colors.white.withOpacity(.34)
                  ]),
        stops: const [0, .56, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, fill);

    final caustic = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.72, -.88),
        radius: .95,
        colors: useLiquidGlass
            ? [
                Colors.white.withOpacity(dark ? .045 : .075),
                Colors.white.withOpacity(dark ? .010 : .025),
                Colors.transparent,
              ]
            : [
                Colors.white.withOpacity(dark ? .28 : .82),
                Colors.white.withOpacity(dark ? .06 : .26),
                Colors.transparent,
              ],
        stops: const [0, .34, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, caustic);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: useLiquidGlass
            ? (dark
                ? [
                    Colors.white.withOpacity(.18),
                    Colors.white.withOpacity(.040),
                    Colors.white.withOpacity(.085)
                  ]
                : [
                    Colors.white.withOpacity(.24),
                    const Color(0xFFC9F0FF).withOpacity(.08),
                    Colors.white.withOpacity(.16)
                  ])
            : (dark
                ? [
                    Colors.white.withOpacity(.42),
                    Colors.white.withOpacity(.10),
                    Colors.white.withOpacity(.20)
                  ]
                : [
                    Colors.white.withOpacity(.96),
                    const Color(0xFFC9F0FF).withOpacity(.56),
                    Colors.white.withOpacity(.82)
                  ]),
      ).createShader(rect);
    canvas.drawRRect(rr, rim);

    final specRect = Rect.fromLTWH(
        size.width * .20, 3, size.width * .40, useLiquidGlass ? 1.4 : 3.0);
    final shine = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(
              useLiquidGlass ? (dark ? .035 : .075) : (dark ? .16 : .54)),
          Colors.transparent
        ],
      ).createShader(specRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(specRect, const Radius.circular(999)), shine);
  }

  @override
  bool shouldRepaint(covariant _DockThumbPainter oldDelegate) =>
      oldDelegate.dark != dark ||
      oldDelegate.active != active ||
      oldDelegate.useLiquidGlass != useLiquidGlass;
}

class GlassAddButton extends StatefulWidget {
  final VoidCallback onTap;
  final ValueChanged<bool>? onPressChanged;
  const GlassAddButton({super.key, required this.onTap, this.onPressChanged});

  @override
  State<GlassAddButton> createState() => _GlassAddButtonState();
}

class _GlassAddButtonState extends State<GlassAddButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => down = true);
        widget.onPressChanged?.call(true);
      },
      onTapCancel: () {
        setState(() => down = false);
        widget.onPressChanged?.call(false);
      },
      onTapUp: (_) {
        setState(() => down = false);
        widget.onPressChanged?.call(false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: Duration(milliseconds: down ? 260 : 340),
        curve: down ? Curves.easeOutBack : Curves.easeOutCubic,
        scale: down ? 1.075 : 1,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Center(
            child: Icon(Icons.add_rounded,
                size: 34,
                color: context.isDark
                    ? Colors.white.withOpacity(.94)
                    : kText.withOpacity(.92)),
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
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: padding ?? const EdgeInsets.fromLTRB(14, 16, 14, 116),
      children: children,
    );
  }
}
