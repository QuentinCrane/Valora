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
        reverseDuration: const Duration(milliseconds: 460));
    _addGlassController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 360),
        reverseDuration: const Duration(milliseconds: 360));
    _onboardingOverlayRequest.addListener(_handleOnboardingRequest);
    NativeBridge.listenIncomingIntents(_handleIntentInfo);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _handledInitialIntent) return;
      _handledInitialIntent = true;
      await _handleIntentInfo(await NativeBridge.getInitialIntentInfo() ?? '');
      if (!mounted) return;
      _prewarmAnalyticsSnapshot();
      await _maybeAutoStartOnboarding();
    });
  }

  Future<void> _maybeAutoStartOnboarding() async {
    final store = context.readStore;
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
        final glass = valoraUseSceneLiquidGlass(dialogContext);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.transparent,
          child: ValoraGlassBackdrop(
            radius: 30,
            blur: 14,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: dark
                    ? kCardDark.withOpacity(glass ? .72 : .94)
                    : Colors.white.withOpacity(glass ? .70 : .94),
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
                        onPressed: () => Navigator.of(dialogContext).pop(false),
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
                        onPressed: () => Navigator.of(dialogContext).pop(true),
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

  Future<void> _handleIntentInfo(String raw) async {
    if (!mounted || raw.isEmpty) return;
    if (raw.contains('com.valora.assets.ADD_WISH')) {
      openCompose(context, ComposeTab.wish);
    } else if (raw.contains('com.valora.assets.ADD_ASSET')) {
      openCompose(context, ComposeTab.asset);
    } else {
      final payload = nativeJsonMap(raw);
      if ((payload['action'] ?? '').toString() !=
          'android.intent.action.SEND') {
        return;
      }
      final mimeType = (payload['type'] ?? '').toString().toLowerCase();
      final sharedUri = (payload['uri'] ?? '').toString().trim();
      String? initialIcon;
      if (sharedUri.isNotEmpty && mimeType.startsWith('image/')) {
        initialIcon = await NativeBridge.persistImageUri(sharedUri);
        if (!mounted) return;
      }
      var initialName = (payload['text'] ?? '')
          .toString()
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (initialName.length > 80) initialName = initialName.substring(0, 80);
      if (initialName.isEmpty && (initialIcon?.isEmpty ?? true)) return;
      openCompose(
        context,
        ComposeTab.asset,
        initialName: initialName.isEmpty ? null : initialName,
        initialIcon: initialIcon,
      );
    }
  }

  void _prewarmAnalyticsSnapshot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 预先把分析页所需的聚合数据缓存好，避免从设置页切到分析页时首帧卡顿。
      context.readStore.analyticsSnapshot;
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
    final steps = _shellOnboardingSteps(context.readStore);
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
    final steps = _shellOnboardingSteps(context.readStore);
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
      final store = context.readStore;
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
    if (valoraMotionTier(context) == ValoraMotionTier.off) return;
    final duration = valoraMotionDuration(
        context, const Duration(milliseconds: 460),
        reduced: const Duration(milliseconds: 270));
    _dockGlassController.duration = duration;
    _dockGlassController.reverseDuration = duration;
    setState(() => _dockMagicActive = active);
    if (active) {
      _dockGlassController.forward();
    } else {
      _dockGlassController.reverse();
    }
  }

  void _setAddMagicActive(bool active) {
    if (_addMagicActive == active || !mounted) return;
    if (valoraMotionTier(context) == ValoraMotionTier.off) return;
    final duration = valoraMotionDuration(
        context, const Duration(milliseconds: 360),
        reduced: const Duration(milliseconds: 210));
    _addGlassController.duration = duration;
    _addGlassController.reverseDuration = duration;
    setState(() => _addMagicActive = active);
    if (active) {
      _addGlassController.forward();
    } else {
      _addGlassController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.readStore;
    final pages = const [
      AssetHomePage(),
      WishHomePage(),
      AnalyticsHomePage(),
      SettingsHomePage()
    ];
    final media = MediaQuery.of(context);
    final safe = media.padding;
    final screen = media.size;
    final dockWidth =
        math.min(screen.width - 124, 404.0).clamp(192.0, 404.0).toDouble();
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

    final useLiquidGlass = valoraUseSceneLiquidGlass(context);
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
        realTimeCapture: valoraLiquidGlassRealtimeCapture(context),
        useSync: valoraLiquidGlassUseSync(context),
        refreshRate: valoraLiquidGlassRefreshRate(context),
        pixelRatio: liquidGlassCapturePixelRatio(context),
        backgroundWidget: ValoraGlassSceneBackground(
            child: RepaintBoundary(child: shellBackground)),
        child: ValoraGlassNavigation(
          index: index,
          onChanged: _goToTab,
          onAdd: () => openCompose(
              context, index == 1 ? ComposeTab.wish : ComposeTab.asset),
          dockWidth: dockWidth,
          dockHeight: dockHeight,
          addSize: addSize,
          safeBottom: safe.bottom,
        ),
      );
    } else {
      shellLayer = Stack(children: [
        shellBackground,
        AnimatedPositioned(
          duration: valoraMotionDuration(
              context, const Duration(milliseconds: 420),
              reduced: const Duration(milliseconds: 240)),
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
          duration: valoraMotionDuration(
              context, const Duration(milliseconds: 360),
              reduced: const Duration(milliseconds: 210)),
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
              final tutorialSteps = _shellOnboardingSteps(store);
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
          StoreSelector<PersistenceSaveState>(
            store: store,
            selector: (store) => store.persistenceState,
            builder: (context, state) {
              if (!state.isSaving && !state.isFailed) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 14,
                right: 14,
                bottom: safe.bottom + 100,
                child: PersistenceStatusBanner(store: store, state: state),
              );
            },
          ),
        ],
      ),
    );
  }

  void openCompose(BuildContext context, ComposeTab tab,
      {String? initialName, String? initialIcon}) {
    mediumHaptic();
    Navigator.of(context).push(softRoute<void>(ComposePage(
        initialTab: tab, initialName: initialName, initialIcon: initialIcon)));
  }
}

class PersistenceStatusBanner extends StatelessWidget {
  final AppStore store;
  final PersistenceSaveState state;

  const PersistenceStatusBanner({
    super.key,
    required this.store,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final failed = state.isFailed;
    final scheme = Theme.of(context).colorScheme;
    final message =
        tr(failed ? 'store.persistence.failed' : 'store.persistence.saving');
    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Material(
        elevation: 4,
        color: failed ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(kRadiusMd),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              failed
                  ? Icon(Icons.warning_amber_rounded,
                      color: scheme.onErrorContainer)
                  : SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: failed ? scheme.onErrorContainer : scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (failed)
                Semantics(
                  button: true,
                  label: tr('store.persistence.retry'),
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await store.retryPersistence();
                        if (!context.mounted) return;
                        showNativeSnack(
                            context, tr('store.persistence.retryDone'));
                      } catch (_) {
                        if (!context.mounted) return;
                        showNativeSnack(
                            context, tr('store.persistence.retryFailed'));
                      }
                    },
                    child: Text(tr('store.persistence.retry')),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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

/// Library-backed navigation and action, layered over a LiquidGlassView.
class ValoraGlassNavigation extends StatefulWidget {
  const ValoraGlassNavigation(
      {super.key,
      required this.index,
      required this.onChanged,
      required this.onAdd,
      required this.dockWidth,
      required this.dockHeight,
      required this.addSize,
      required this.safeBottom});

  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  final double dockWidth, dockHeight, addSize, safeBottom;

  @override
  State<ValoraGlassNavigation> createState() => _ValoraGlassNavigationState();
}

class _ValoraGlassNavigationState extends State<ValoraGlassNavigation> {
  int? _dragIndex;

  void _previewDrag(double x) {
    final next = (x / (widget.dockWidth / 4)).floor().clamp(0, 3);
    if (_dragIndex != next) {
      setState(() => _dragIndex = next);
      selectionHaptic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fullMotion = valoraMotionTier(context) == ValoraMotionTier.full;
    // On a live shader backend the library places its morphing bar itself.
    // In its capture fallback (and in reduced motion), place the plain bar.
    final morph = fullMotion && ui.ImageFilter.isShaderFilterSupported;
    final labels = [
      tr('dock.assets'),
      tr('dock.wishes'),
      tr('dock.analytics'),
      tr('dock.settings')
    ];
    const icons = [
      Icons.home_rounded,
      Icons.shopping_bag_rounded,
      Icons.pie_chart_rounded,
      Icons.settings_rounded
    ];
    final tint = dark ? const Color(0x88252E3B) : const Color(0x90FFFFFF);
    final bar = lge.LiquidGlassTabBar(
      key: const ValueKey('valora.shell.library-tab-bar'),
      items: [for (final icon in icons) lge.LiquidGlassTabBarItem(icon: icon)],
      selectedIndex: _dragIndex ?? widget.index,
      onChanged: widget.onChanged,
      width: widget.dockWidth,
      height: widget.dockHeight,
      alignment: Alignment.bottomLeft,
      margin: const EdgeInsets.only(left: 24, bottom: 14),
      itemPadding: 6,
      itemStyle: lge.LiquidGlassTabItemStyle(
        selectedColor: dark ? Colors.white : kText,
        unselectedColor:
            dark ? const Color(0xFFA8B5C4) : const Color(0xFF748391),
        iconSize: 23,
        underGlassIconSize: 27,
      ),
      style: lge.LiquidGlassStyle(
        shape: const lge.LiquidGlassShape.continuousRoundedRectangle(
            cornerRadius: 999),
        color: tint,
        blur: liquidGlassBlurSigma(context),
        refractionIndex: 1.025,
        refractionWidth: 32,
        saturation: 1.08,
        specular: const lge.LiquidGlassLight.specular(
            thickness: 6, angle: 132, intensity: 1.2, sharpness: .35),
        glow: const lge.LiquidGlassLight.glow(
            thickness: 18, angle: 222, intensity: .65),
      ),
      pillStyle: lge.LiquidGlassTabPillStyle(
        mode:
            morph ? lge.LiquidGlassPillMode.both : lge.LiquidGlassPillMode.none,
        animated: true,
        animationDuration:
            valoraMotionDuration(context, const Duration(milliseconds: 320)),
        confineToBar: true,
        color: dark ? const Color(0x44FFFFFF) : const Color(0x77FFFFFF),
        glassStyle: lge.LiquidGlassStyle(
          shape: const lge.LiquidGlassShape.continuousRoundedRectangle(
              cornerRadius: 999),
          color: dark ? const Color(0x1FFFFFFF) : const Color(0x30FFFFFF),
          blur: 1.5,
          refractionIndex: 1.035,
          refractionWidth: 22,
          specular:
              const lge.LiquidGlassLight.specular(thickness: 5, angle: 132),
        ),
      ),
    );
    final Widget positionedBar = morph
        ? Positioned.fill(child: ExcludeSemantics(child: bar))
        : Positioned(
            left: 24,
            bottom: widget.safeBottom + 14,
            width: widget.dockWidth,
            height: widget.dockHeight,
            child: ExcludeSemantics(
                child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (d) => _previewDrag(d.localPosition.dx),
              onHorizontalDragUpdate: (d) => _previewDrag(d.localPosition.dx),
              onHorizontalDragEnd: (_) {
                final target = _dragIndex;
                setState(() => _dragIndex = null);
                if (target != null) widget.onChanged(target);
              },
              onHorizontalDragCancel: () => setState(() => _dragIndex = null),
              child: bar,
            )),
          );
    return Stack(children: [
      positionedBar,
      // The library's animated bar uses a raw pointer listener, so provide
      // explicit, individually actionable accessibility nodes as well.
      Positioned(
        left: 24,
        bottom: widget.safeBottom + 14,
        width: widget.dockWidth,
        height: widget.dockHeight,
        child: TutorialTargetAnchor(
            id: 'shell.dock',
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Semantics(
                      container: true,
                      button: true,
                      label: labels[i],
                      selected: i == widget.index,
                      onTap: () => widget.onChanged(i),
                      child: const SizedBox.expand(),
                    ),
                  )
              ],
            )),
      ),
      Positioned(
        right: 24,
        bottom: widget.safeBottom + 19,
        width: widget.addSize,
        height: widget.addSize,
        child: TutorialTargetAnchor(
          id: 'shell.addButton',
          child: Semantics(
            button: true,
            label: tr('common.add'),
            onTap: widget.onAdd,
            child: ExcludeSemantics(
                child: lge.LiquidGlassBatch.exclude(
              child: lge.LiquidGlassTabBarAction(
                key: const ValueKey('valora.shell.library-add'),
                icon: Icons.add_rounded,
                onTap: widget.onAdd,
                size: widget.addSize,
                foregroundColor: dark ? Colors.white : kText,
                touch: fullMotion
                    ? const lge.LiquidGlassTouch.flexing(lge.LiquidGlassFlex())
                    : null,
                style: lge.LiquidGlassStyle(
                  color: tint,
                  blur: liquidGlassBlurSigma(context),
                  refractionIndex: 1.025,
                  refractionWidth: 26,
                  specular: const lge.LiquidGlassLight.specular(
                      thickness: 6, angle: 132),
                ),
              ),
            )),
          ),
        ),
      ),
    ]);
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
        duration: valoraMotionDuration(
            context, const Duration(milliseconds: 360),
            reduced: const Duration(milliseconds: 210)),
        curve:
            _fingerDown || _dragging ? Curves.easeOutBack : Curves.easeOutCubic,
        offset: Offset(0, _dockLift() / 76),
        child: AnimatedScale(
          duration: valoraMotionDuration(
              context, const Duration(milliseconds: 360),
              reduced: const Duration(milliseconds: 210)),
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
                final thumbW = math.max(itemW - 6, 48).toDouble();
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
                            : valoraMotionDuration(
                                context, const Duration(milliseconds: 460),
                                reduced: const Duration(milliseconds: 260)),
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
                            : valoraMotionDuration(
                                context, const Duration(milliseconds: 430),
                                reduced: const Duration(milliseconds: 250)),
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
                          void selectItem() {
                            tapHaptic();
                            widget.onChanged(i);
                          }

                          return Expanded(
                            child: Semantics(
                              button: true,
                              container: true,
                              label: items[i].label,
                              selected: active,
                              onTap: selectItem,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: selectItem,
                                child: AnimatedScale(
                                  duration: (_fingerDown || _dragging)
                                      ? valoraMotionDuration(context,
                                          const Duration(milliseconds: 90),
                                          reduced:
                                              const Duration(milliseconds: 60))
                                      : valoraMotionDuration(context,
                                          const Duration(milliseconds: 330),
                                          reduced: const Duration(
                                              milliseconds: 190)),
                                  curve: (_fingerDown || _dragging)
                                      ? Curves.easeOutCubic
                                      : Curves.easeOutBack,
                                  scale: scale,
                                  child: AnimatedContainer(
                                    duration: valoraMotionDuration(context,
                                        const Duration(milliseconds: 260),
                                        reduced:
                                            const Duration(milliseconds: 150)),
                                    curve: Curves.easeOutCubic,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          items[i].icon,
                                          size: active ? 24 : 22,
                                          color: active
                                              ? (context.isDark
                                                  ? Colors.white
                                                      .withOpacity(.95)
                                                  : kText.withOpacity(.94))
                                              : kMuted.withOpacity(
                                                  context.isDark ? .62 : .56),
                                        ),
                                        const SizedBox(height: 3),
                                        AnimatedContainer(
                                          duration: valoraMotionDuration(
                                              context,
                                              const Duration(milliseconds: 240),
                                              reduced: const Duration(
                                                  milliseconds: 140)),
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
        duration: valoraMotionDuration(
            context, const Duration(milliseconds: 260),
            reduced: const Duration(milliseconds: 150)),
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
      duration: valoraMotionDuration(context, const Duration(milliseconds: 220),
          reduced: const Duration(milliseconds: 130)),
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
    return Semantics(
      button: true,
      label: tr('common.add'),
      onTap: widget.onTap,
      child: GestureDetector(
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
          duration: valoraMotionDuration(
              context, Duration(milliseconds: down ? 260 : 340),
              reduced: Duration(milliseconds: down ? 150 : 200)),
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
      children: children
          .map((child) => ValoraAdaptiveContent(child: child))
          .toList(growable: false),
    );
  }
}

class SliverPageFrame extends StatelessWidget {
  final List<WidgetBuilder> sections;
  final EdgeInsets? padding;
  final Key? scrollKey;

  const SliverPageFrame({
    super.key,
    required this.sections,
    this.padding,
    this.scrollKey,
  });

  @override
  Widget build(BuildContext context) {
    final contentPadding =
        padding ?? const EdgeInsets.fromLTRB(14, 16, 14, 116);
    return CustomScrollView(
      key: scrollKey,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: contentPadding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ValoraAdaptiveContent(
                child: sections[index](context),
              ),
              childCount: sections.length,
              addAutomaticKeepAlives: false,
            ),
          ),
        ),
      ],
    );
  }
}
