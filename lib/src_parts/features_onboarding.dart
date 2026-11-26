part of '../main.dart';

/// First-launch welcome flow.
///
/// Shown instead of [ShellPage] only for fresh installs: the boot succeeded,
/// the store is empty and the user has not seen the flow before. Completing or
/// skipping writes `welcomeCompleted`, which swaps the home branch back to the
/// shell, where the existing tutorial prompt takes over.
class OnboardingFlowPage extends StatefulWidget {
  const OnboardingFlowPage({super.key});

  @override
  State<OnboardingFlowPage> createState() => _OnboardingFlowPageState();
}

class _OnboardingFlowPageState extends State<OnboardingFlowPage> {
  static const _pageCount = 3;
  final PageController _pageController = PageController();
  int _index = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int next) {
    final target = next.clamp(0, _pageCount - 1).toInt();
    if (target == _index) return;
    selectionHaptic();
    _pageController.animateToPage(
      target,
      duration: valoraMotionDuration(
        context,
        const Duration(milliseconds: 380),
        reduced: const Duration(milliseconds: 230),
      ),
      curve: Curves.easeOutCubic,
    );
    setState(() => _index = target);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final store = context.readStore;
    await store.updateSettings(store.settings.copyWith(welcomeCompleted: true));
    // The StoreSelector around MaterialApp rebuilds on the settings change and
    // swaps this page for ShellPage; nothing else to do here.
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final motion = valoraMotionTier(context) != ValoraMotionTier.off;
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 0),
                child: TextButton(
                  onPressed: () {
                    lightHaptic();
                    _finish();
                  },
                  child: Text(tr('onboarding.skip')),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (next) => setState(() => _index = next),
                children: const [
                  _OnboardingWelcomePage(),
                  _OnboardingConceptPage(),
                  _OnboardingFeaturesPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: _index > 0
                            ? IconButton(
                                tooltip: tr('onboarding.back'),
                                onPressed: () => _goTo(_index - 1),
                                icon: const Icon(Icons.arrow_back_rounded),
                              )
                            : null,
                      ),
                      Expanded(
                        child: Semantics(
                          label: tr('onboarding.pageIndicator'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < _pageCount; i++)
                                AnimatedContainer(
                                  duration: motion
                                      ? const Duration(milliseconds: 260)
                                      : Duration.zero,
                                  curve: Curves.easeOutCubic,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _index
                                        ? (dark
                                            ? const Color(0xFF8FD4FF)
                                            : kBrandStrong)
                                        : (dark
                                            ? Colors.white
                                                .withValues(alpha: .22)
                                            : Colors.black
                                                .withValues(alpha: .14)),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (_index < _pageCount - 1) {
                        _goTo(_index + 1);
                      } else {
                        mediumHaptic();
                        _finish();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      _index < _pageCount - 1
                          ? tr('onboarding.next')
                          : tr('onboarding.start'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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

class _OnboardingPageShell extends StatelessWidget {
  final List<Widget> children;
  const _OnboardingPageShell({required this.children});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 8, 26, 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _OnboardingWelcomePage extends StatelessWidget {
  const _OnboardingWelcomePage();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return _OnboardingPageShell(children: [
      const LogoMark(size: 108),
      const SizedBox(height: 26),
      Text(
        tr('onboarding.welcome.title'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: dark ? Colors.white : kText,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        tr('onboarding.welcome.slogan'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
          color: dark ? const Color(0xFF8FD4FF) : kBrandStrong,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        tr('onboarding.welcome.desc'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: dark ? Colors.white.withValues(alpha: .66) : kMuted,
        ),
      ),
      const SizedBox(height: 22),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _OnboardingPill(
            icon: Icons.verified_user_rounded,
            label: tr('onboarding.pill.local'),
          ),
          _OnboardingPill(
            icon: Icons.person_off_rounded,
            label: tr('onboarding.pill.noAccount'),
          ),
          _OnboardingPill(
            icon: Icons.lock_rounded,
            label: tr('onboarding.pill.private'),
          ),
        ],
      ),
    ]);
  }
}

class _OnboardingPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _OnboardingPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .07)
            : kBrand.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .10)
              : kBrand.withValues(alpha: .22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 15, color: dark ? const Color(0xFF8FD4FF) : kBrandStrong),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white.withValues(alpha: .86) : kText,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingConceptPage extends StatelessWidget {
  const _OnboardingConceptPage();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final curveColor = dark ? const Color(0xFF8FD4FF) : kBrandStrong;
    return _OnboardingPageShell(children: [
      Text(
        tr('onboarding.concept.title'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: dark ? Colors.white : kText,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        tr('onboarding.concept.desc'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: dark ? Colors.white.withValues(alpha: .66) : kMuted,
        ),
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
        decoration: BoxDecoration(
          color: dark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(kRadiusLg),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: .10)
                : Colors.black.withValues(alpha: .06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? .24 : .06),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Semantics(
              label: tr('onboarding.concept.chart'),
              child: SizedBox(
                height: 108,
                width: double.infinity,
                child: CustomPaint(
                  painter: _OnboardingValueTrailPainter(color: curveColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded,
                    size: 18,
                    color: dark
                        ? const Color(0xFFFFD98A)
                        : const Color(0xFFE8A13C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr('onboarding.concept.example'),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: dark ? Colors.white.withValues(alpha: .78) : kText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ]);
  }
}

/// Decorative declining daily-cost curve for the concept page.
class _OnboardingValueTrailPainter extends CustomPainter {
  final Color color;
  const _OnboardingValueTrailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final control = Offset(size.width * .46, size.height * .04);
    final end = Offset(size.width, size.height * .66);
    final start = Offset(0, size.height * .16);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .18,
        size.height * .12,
        control.dx,
        control.dy,
        size.width * .62,
        size.height * .52,
      )
      ..quadraticBezierTo(
        size.width * .86,
        size.height * .68,
        end.dx,
        end.dy,
      );

    final fill = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [color.withValues(alpha: .16), color.withValues(alpha: .01)],
        ),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          start,
          end,
          [color, color.withValues(alpha: .55)],
        ),
    );

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(start, 4.5, dotPaint);
    canvas.drawCircle(end, 4.5, dotPaint);
    canvas.drawCircle(
      end,
      9,
      Paint()..color = color.withValues(alpha: .22),
    );
  }

  @override
  bool shouldRepaint(_OnboardingValueTrailPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _OnboardingFeaturesPage extends StatelessWidget {
  const _OnboardingFeaturesPage();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return _OnboardingPageShell(children: [
      Text(
        tr('onboarding.features.title'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: dark ? Colors.white : kText,
        ),
      ),
      const SizedBox(height: 22),
      Column(
        children: [
          _OnboardingFeatureCard(
            icon: Icons.home_rounded,
            color: const Color(0xFF7CC6F2),
            title: tr('onboarding.features.assets'),
            desc: tr('onboarding.features.assetsDesc'),
          ),
          _OnboardingFeatureCard(
            icon: Icons.shopping_bag_rounded,
            color: const Color(0xFFFFB27C),
            title: tr('onboarding.features.wishes'),
            desc: tr('onboarding.features.wishesDesc'),
          ),
          _OnboardingFeatureCard(
            icon: Icons.pie_chart_rounded,
            color: const Color(0xFF9F8FF4),
            title: tr('onboarding.features.analytics'),
            desc: tr('onboarding.features.analyticsDesc'),
          ),
          _OnboardingFeatureCard(
            icon: Icons.settings_rounded,
            color: const Color(0xFF7ED49A),
            title: tr('onboarding.features.settings'),
            desc: tr('onboarding.features.settingsDesc'),
          ),
        ]
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: card,
                ))
            .toList(),
      ),
    ]);
  }
}

class _OnboardingFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _OnboardingFeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .05)
            : color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: .08)
              : color.withValues(alpha: .20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: dark ? .24 : .18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 22, color: dark ? color : kText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: dark ? Colors.white : kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: dark ? Colors.white.withValues(alpha: .62) : kMuted,
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
