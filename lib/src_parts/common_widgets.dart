part of '../main.dart';

enum ValoraRouteStyle {
  auto,
  detail,
  editor,
  compose,
  settings,
  sheet,
  analytics,
  plain
}

class ValoraRightSlideFadePageTransitionsBuilder
    extends PageTransitionsBuilder {
  const ValoraRightSlideFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final v = animation.value.clamp(0.0, 1.0).toDouble();
        final curve = Curves.easeOutCubic.transform(v);
        // Push: from a short right offset to the final position.
        // Pop / predictive back: the same route animation runs backward, so the
        // page only slides horizontally to the right and fades out. No scale,
        // no center shrink, no clipping layer.
        final dx = 86.0 * (1.0 - curve);
        final opacity = (.28 + .72 * curve).clamp(0.0, 1.0).toDouble();
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }
}

ValoraRouteStyle valoraRouteStyleFor(Widget page) {
  final name = page.runtimeType.toString();
  if (name.contains('AssetDetail') || name.contains('WishDetail'))
    return ValoraRouteStyle.detail;
  if (name.contains('Editor') || name.contains('Compose'))
    return ValoraRouteStyle.editor;
  if (name.contains('Settings') ||
      name.contains('Cloud') ||
      name.contains('Manager')) return ValoraRouteStyle.settings;
  if (name.contains('Analytics') || name.contains('Review'))
    return ValoraRouteStyle.analytics;
  if (name.contains('Sheet') || name.contains('_AppSheet'))
    return ValoraRouteStyle.sheet;
  return ValoraRouteStyle.plain;
}

/// Route-local wrapper for pages opened through [softRoute].
///
/// The right-slide fade motion is now provided by
/// [ValoraRightSlideFadePageTransitionsBuilder]. This boundary intentionally
/// avoids adding a second scale/clip layer, so predictive back no longer looks
/// like it is shrinking toward the center.
class PredictiveBackBoundary extends StatelessWidget {
  final Widget child;
  final ValoraRouteStyle style;
  const PredictiveBackBoundary(
      {super.key, required this.child, this.style = ValoraRouteStyle.plain});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    final content = RepaintBoundary(child: child);
    if (animation == null) return PopScope(canPop: true, child: content);

    return PopScope(
      canPop: true,
      child: AnimatedBuilder(
        animation: animation,
        child: content,
        builder: (context, child) {
          // 只在真实 pop / 系统预测式返回阶段叠加轻量提示；push 阶段不做二次动画，
          // 避免设置页进入时列表闪一下，也避免和系统返回进度抢动画。
          if (animation.status != AnimationStatus.reverse)
            return child ?? content;
          final t = animation.value.clamp(0.0, 1.0).toDouble();
          return _buildContextualMotion(context, child ?? content, t,
              reverse: true);
        },
      ),
    );
  }

  Widget _buildContextualMotion(BuildContext context, Widget content, double t,
      {required bool reverse}) {
    final p = reverse ? (1.0 - t).clamp(0.0, 1.0).toDouble() : 0.0;
    if (p <= 0.001) return content;

    switch (style) {
      case ValoraRouteStyle.detail:
        return _detailBackMotion(context, content, p);
      case ValoraRouteStyle.editor:
      case ValoraRouteStyle.compose:
        return _editorBackMotion(content, p);
      case ValoraRouteStyle.settings:
        return _settingsBackMotion(content, p);
      case ValoraRouteStyle.sheet:
        return _sheetBackMotion(content, p);
      case ValoraRouteStyle.analytics:
        return _analyticsBackMotion(content, p);
      case ValoraRouteStyle.auto:
      case ValoraRouteStyle.plain:
        return _plainBackMotion(content, p);
    }
  }

  double _motion(double p) => p.clamp(0.0, 1.0).toDouble();

  Widget _rightSlideFadeMotion(Widget content, double p,
      {double distance = 96, double fade = .48}) {
    final curve = Curves.easeOutCubic.transform(_motion(p));
    return Transform.translate(
      offset: Offset(distance * curve, 0),
      child: Opacity(
        opacity: (1.0 - fade * curve).clamp(.0, 1.0).toDouble(),
        child: content,
      ),
    );
  }

  Widget _detailBackMotion(BuildContext context, Widget content, double p) {
    return _rightSlideFadeMotion(content, p, distance: 108, fade: .50);
  }

  Widget _editorBackMotion(Widget content, double p) {
    return _rightSlideFadeMotion(content, p, distance: 102, fade: .48);
  }

  Widget _settingsBackMotion(Widget content, double p) {
    // 预测式返回只做“水平向右回收 + 逐渐透明”。
    // 不再叠加中心缩小、裁切或阴影，避免和系统右滑回收方向冲突。
    return _rightSlideFadeMotion(content, p, distance: 112, fade: .52);
  }

  Widget _sheetBackMotion(Widget content, double p) {
    return _rightSlideFadeMotion(content, p, distance: 92, fade: .42);
  }

  Widget _analyticsBackMotion(Widget content, double p) {
    return _rightSlideFadeMotion(content, p, distance: 96, fade: .44);
  }

  Widget _plainBackMotion(Widget content, double p) {
    return _rightSlideFadeMotion(content, p, distance: 86, fade: .36);
  }
}

class GlobalBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const GlobalBackButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Positioned(
      left: 12,
      top: MediaQuery.paddingOf(context).top + 10,
      child: GlassBackButton(onTap: onTap));
}

class GlassBackButton extends StatefulWidget {
  final VoidCallback onTap;
  const GlassBackButton({super.key, required this.onTap});

  @override
  State<GlassBackButton> createState() => _GlassBackButtonState();
}

class _GlassBackButtonState extends State<GlassBackButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      onTap: () {
        lightHaptic();
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 320),
        curve: down ? Curves.easeOutBack : Curves.easeOutCubic,
        scale: down ? 1.065 : 1,
        child: ValoraLiquidGlassSurface(
          width: 88,
          height: 44,
          radius: 999,
          distortion: .08,
          distortionWidth: 24,
          blurSigma: 1.2,
          tintOpacity: dark ? .09 : .30,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    size: 24,
                    color: dark
                        ? Colors.white.withOpacity(.94)
                        : kText.withOpacity(.88)),
                const SizedBox(width: 2),
                Text(tr('common.back'),
                    style: TextStyle(
                        color: dark
                            ? Colors.white.withOpacity(.92)
                            : kText.withOpacity(.88),
                        fontWeight: FontWeight.normal,
                        fontSize: 13)),
              ]),
        ),
      ),
    );
  }
}

class ValoraGlassSceneBackground extends StatelessWidget {
  final Widget child;
  const ValoraGlassSceneBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  Color(0xFF071D2B),
                  Color(0xFF061522),
                  Color(0xFF0A2435),
                  kBgDark
                ]
              : const [Colors.white, Colors.white, Colors.white],
          stops: dark ? const [0, .42, .76, 1] : null,
        ),
      ),
      child: child,
    );
  }
}

/// Shared iOS-style tuning for the scene-level liquid lenses.
///
/// A single persisted value changes both the optical blur and the milk-glass
/// tint. Keeping the two in lockstep avoids the muddy, low-contrast look that
/// a blur-only control would create.
double liquidGlassBlurSigma(BuildContext context) => lerpDouble(
      .70,
      2.35,
      context.store.settings.liquidGlassSoftness,
    )!;

Color liquidGlassTint(BuildContext context) {
  final softness = context.store.settings.liquidGlassSoftness;
  final opacity = context.isDark
      ? lerpDouble(.028, .090, softness)!
      : lerpDouble(.040, .130, softness)!;
  return Colors.white.withOpacity(opacity);
}

double liquidGlassCapturePixelRatio(BuildContext context,
    {bool duringInteraction = false}) {
  final ratio =
      lerpDouble(.955, 1.0, context.store.settings.liquidGlassSoftness)!;
  return (ratio - (duringInteraction ? .025 : 0.0)).clamp(.92, 1.0).toDouble();
}

class ValoraLiquidGlassSurface extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double distortion;
  final double distortionWidth;
  final double magnification;
  final double blurSigma;
  final double pixelRatio;
  final double tintOpacity;
  final bool realtime;
  final bool circular;

  const ValoraLiquidGlassSurface({
    super.key,
    this.width,
    required this.height,
    required this.radius,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.distortion = .115,
    this.distortionWidth = 34,
    this.magnification = 1.024,
    this.blurSigma = .62,
    this.pixelRatio = .72,
    this.tintOpacity = .18,
    this.realtime = true,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = width ??
          (constraints.maxWidth.isFinite ? constraints.maxWidth : height);
      final h = height;
      final effectiveRadius = circular ? h / 2 : radius;
      return SizedBox(
        width: width,
        height: h,
        child: _StaticValoraGlassSurface(
          radius: effectiveRadius,
          tintOpacity: tintOpacity,
          blurSigma: math.min(blurSigma, .75),
          widthHint: w,
          child: Padding(
            padding: padding,
            child: Center(child: child),
          ),
        ),
      );
    });
  }
}

/// Lightweight fallback glass for ordinary small controls.
///
/// Lightweight fallback for ordinary small controls.
///
/// True shader glass is used only for scene-level surfaces such as the bottom Dock
/// and large floating save buttons. Small controls deliberately keep this soft
/// Gaussian fallback so they do not create many background capture surfaces.
class _StaticValoraGlassSurface extends StatelessWidget {
  final double radius;
  final double tintOpacity;
  final double blurSigma;
  final double widthHint;
  final Widget child;

  const _StaticValoraGlassSurface({
    required this.radius,
    required this.tintOpacity,
    required this.blurSigma,
    required this.widthHint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 回退到 0.79 一类的轻量毛玻璃按钮：普通小按钮不要再伪装成 shader
    // liquid glass，否则既不像真正折射，也会让页面显得脏和卡。
    final dark = context.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: math.max(8.0, blurSigma * 8.0),
            sigmaY: math.max(8.0, blurSigma * 8.0)),
        child: CustomPaint(
          painter: _ValoraLiquidRimPainter(
            dark: dark,
            radius: radius,
            borderColor: Colors.white,
            fillOpacity: tintOpacity,
            widthHint: widthHint,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ValoraLiquidRimPainter extends CustomPainter {
  final bool dark;
  final double radius;
  final Color borderColor;
  final double fillOpacity;
  final double widthHint;
  const _ValoraLiquidRimPainter({
    required this.dark,
    required this.radius,
    required this.borderColor,
    this.fillOpacity = .18,
    this.widthHint = 120,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rr =
        RRect.fromRectAndRadius(rect.deflate(.6), Radius.circular(radius));

    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                Colors.white.withOpacity(.075 + fillOpacity * .14),
                Colors.white.withOpacity(.032),
                Colors.white.withOpacity(.052)
              ]
            : [
                Colors.white.withOpacity(.30 + fillOpacity * .42),
                Colors.white.withOpacity(.14 + fillOpacity * .12),
                const Color(0xFFEAF8FF).withOpacity(.16 + fillOpacity * .20)
              ],
        stops: const [0, .56, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, body);

    final causticRect =
        Rect.fromLTWH(size.width * .07, 0, size.width * .88, size.height * .56);
    final caustic = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.62, -.92),
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(dark ? .16 : .34),
          Colors.white.withOpacity(dark ? .04 : .10),
          Colors.transparent,
        ],
        stops: const [0, .36, 1],
      ).createShader(causticRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(causticRect, Radius.circular(radius)), caustic);

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide < 36 ? 1.05 : 1.35
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                Colors.white.withOpacity(.30),
                Colors.white.withOpacity(.09),
                Colors.white.withOpacity(.040),
                Colors.white.withOpacity(.16)
              ]
            : [
                Colors.white.withOpacity(.58),
                const Color(0xFFCFEFFF).withOpacity(.26),
                const Color(0xFF7CC6F2).withOpacity(.08),
                Colors.white.withOpacity(.42)
              ],
        stops: const [0, .35, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(rr, outer);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = borderColor.withOpacity(dark ? .22 : .30);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.deflate(2.0), Radius.circular(math.max(0, radius - 2))),
        inner);

    final isWidePill = widthHint > size.height * 2.4;
    final spec = Rect.fromLTWH(
        size.width * .16,
        2.2,
        size.width * (isWidePill ? .42 : .54),
        math.max(1.2, size.height * (isWidePill ? .035 : .055)));
    final shine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(dark ? .10 : .24),
          Colors.white.withOpacity(dark ? .03 : .07),
          Colors.transparent
        ],
        stops: const [0, .28, .72, 1],
      ).createShader(spec);
    canvas.drawRRect(
        RRect.fromRectAndRadius(spec, const Radius.circular(999)), shine);

    final lower = Rect.fromLTWH(
        size.width * .12, size.height - 4.7, size.width * .76, 2.4);
    final bottom = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF7CC6F2).withOpacity(dark ? .04 : .055),
          Colors.white.withOpacity(dark ? .03 : .075),
          Colors.transparent
        ],
      ).createShader(lower);
    canvas.drawRRect(
        RRect.fromRectAndRadius(lower, const Radius.circular(999)), bottom);
  }

  @override
  bool shouldRepaint(covariant _ValoraLiquidRimPainter oldDelegate) {
    return oldDelegate.dark != dark ||
        oldDelegate.radius != radius ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.fillOpacity != fillOpacity ||
        oldDelegate.widthHint != widthHint;
  }
}

class ValoraGlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;
  final Color? iconColor;
  const ValoraGlassIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.size = 44,
      this.tooltip,
      this.iconColor});

  @override
  State<ValoraGlassIconButton> createState() => _ValoraGlassIconButtonState();
}

class _ValoraGlassIconButtonState extends State<ValoraGlassIconButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      onTap: () {
        lightHaptic();
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: down ? Curves.easeOutBack : Curves.easeOutCubic,
        scale: down ? 1.08 : 1,
        child: ValoraLiquidGlassSurface(
          width: widget.size,
          height: widget.size,
          radius: widget.size / 2,
          circular: true,
          distortion: .125,
          distortionWidth: 26,
          blurSigma: .55,
          tintOpacity: context.isDark ? .12 : .24,
          child: Icon(widget.icon,
              size: widget.size * .50,
              color: widget.iconColor ??
                  (context.isDark
                      ? Colors.white.withOpacity(.92)
                      : kText.withOpacity(.90))),
        ),
      ),
    );
    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * .24),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: kBrand.withOpacity(.72),
                borderRadius: BorderRadius.circular(size * .24)),
            child: Center(
                child: Icon(Icons.inventory_2_rounded,
                    size: size * .52, color: kBrandInk)),
          ),
        ),
      );
}

class MissingPage extends StatelessWidget {
  final String title;
  const MissingPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) => GradientScaffold(
          child: SafeArea(
              child: Stack(children: [
        Center(child: Text(title)),
        GlobalBackButton(onTap: () {
          lightHaptic();
          Navigator.pop(context);
        })
      ])));
}

const List<String> kQuickAssetIcons = [
  '📦',
  '📱',
  '💻',
  '🎧',
  '⌚',
  '🎮',
  '📷',
  '🚗',
  '🏠',
  '🎒',
  '🧳',
  '✨'
];

class Valora3DIconSpec {
  final String emoji;
  final Color a;
  final Color b;
  final Color c;
  final String label;
  const Valora3DIconSpec(this.emoji, this.a, this.b, this.c, this.label);

  String get localizedLabel => tl(label);
}

const Map<String, Valora3DIconSpec> kThreeDIconSpecs = {
  'z3d:box': Valora3DIconSpec(
      '📦', Color(0xFFFFE2B8), Color(0xFFC47A3E), Color(0xFF9A5A30), '纸箱'),
  'z3d:phone': Valora3DIconSpec(
      '📱', Color(0xFFDFF5FF), Color(0xFF7CC6F2), Color(0xFF4866D8), '手机'),
  'z3d:laptop': Valora3DIconSpec(
      '💻', Color(0xFFEAF2FF), Color(0xFF9BB9E9), Color(0xFF55677E), '电脑'),
  'z3d:camera': Valora3DIconSpec(
      '📷', Color(0xFFEFE9FF), Color(0xFFA899F0), Color(0xFF50446A), '相机'),
  'z3d:headphone': Valora3DIconSpec(
      '🎧', Color(0xFFEDEFFF), Color(0xFFBAC1F7), Color(0xFF454A5D), '耳机'),
  'z3d:watch': Valora3DIconSpec(
      '⌚', Color(0xFFF2F6FF), Color(0xFFB7C7E8), Color(0xFF374151), '手表'),
  'z3d:game': Valora3DIconSpec(
      '🎮', Color(0xFFE9FFF4), Color(0xFF99E5B9), Color(0xFF3B4A55), '游戏机'),
  'z3d:car': Valora3DIconSpec(
      '🚗', Color(0xFFFFF1F0), Color(0xFFFF9285), Color(0xFFE34B43), '汽车'),
  'z3d:house': Valora3DIconSpec(
      '🏠', Color(0xFFEFFFF7), Color(0xFF95E2C4), Color(0xFF517C6A), '房产'),
  'z3d:bag': Valora3DIconSpec(
      '🎒', Color(0xFFFFF4D8), Color(0xFFFFD166), Color(0xFF945D2C), '背包'),
  'z3d:suitcase': Valora3DIconSpec(
      '🧳', Color(0xFFFFEBD7), Color(0xFFD98C56), Color(0xFF7B4C31), '行李箱'),
  'z3d:diamond': Valora3DIconSpec(
      '💎', Color(0xFFE6FAFF), Color(0xFF8CE4FF), Color(0xFF2D8FB7), '宝石'),
  'z3d:coin': Valora3DIconSpec(
      '🪙', Color(0xFFFFF4BF), Color(0xFFF5B94B), Color(0xFF98611C), '硬币'),
  'z3d:wallet': Valora3DIconSpec(
      '👛', Color(0xFFFFE6F3), Color(0xFFFF9CCF), Color(0xFF974C71), '钱包'),
  'z3d:card': Valora3DIconSpec(
      '💳', Color(0xFFEAF7FF), Color(0xFF7EC8F5), Color(0xFF315E86), '银行卡'),
  'z3d:receipt': Valora3DIconSpec(
      '🧾', Color(0xFFFFFFFF), Color(0xFFD7E4F1), Color(0xFF8192A5), '票据'),
  'z3d:printer': Valora3DIconSpec(
      '🖨️', Color(0xFFF0ECFF), Color(0xFFBBAAF7), Color(0xFF675E7F), '打印机'),
  'z3d:keyboard': Valora3DIconSpec(
      '⌨️', Color(0xFFF0F2F7), Color(0xFFC6CCD8), Color(0xFF626A7A), '键盘'),
  'z3d:mouse': Valora3DIconSpec(
      '🖱️', Color(0xFFF6F0FF), Color(0xFFC5ACEB), Color(0xFF70647E), '鼠标'),
  'z3d:monitor': Valora3DIconSpec(
      '🖥️', Color(0xFFEAF6FF), Color(0xFF8CCCF3), Color(0xFF42677E), '显示器'),
  'z3d:tv': Valora3DIconSpec(
      '📺', Color(0xFFE8F4FF), Color(0xFF77B7EE), Color(0xFF414F5F), '电视'),
  'z3d:router': Valora3DIconSpec(
      '📡', Color(0xFFE8FFF5), Color(0xFF7CE2B5), Color(0xFF357A64), '路由器'),
  'z3d:battery': Valora3DIconSpec(
      '🔋', Color(0xFFEFFFF0), Color(0xFF8DEB70), Color(0xFF427D35), '电池'),
  'z3d:plug': Valora3DIconSpec(
      '🔌', Color(0xFFF1F3F8), Color(0xFFB6BED0), Color(0xFF6A7282), '充电器'),
  'z3d:bulb': Valora3DIconSpec(
      '💡', Color(0xFFFFF7D7), Color(0xFFFFD45A), Color(0xFFB87C2D), '灯具'),
  'z3d:fridge': Valora3DIconSpec(
      '🧊', Color(0xFFE8FBFF), Color(0xFF8EDAEF), Color(0xFF5B97AE), '冰箱'),
  'z3d:washer': Valora3DIconSpec(
      '🧺', Color(0xFFFFF1DF), Color(0xFFE7B26F), Color(0xFF8B6A42), '洗衣'),
  'z3d:broom': Valora3DIconSpec(
      '🧹', Color(0xFFFFF4D8), Color(0xFFEBBE69), Color(0xFF83613B), '清洁'),
  'z3d:plant': Valora3DIconSpec(
      '🪴', Color(0xFFEFFFF3), Color(0xFF7EDD91), Color(0xFF4A7B50), '绿植'),
  'z3d:sofa': Valora3DIconSpec(
      '🛋️', Color(0xFFFFEFE8), Color(0xFFEAA98F), Color(0xFF93644F), '沙发'),
  'z3d:bed': Valora3DIconSpec(
      '🛏️', Color(0xFFEAF0FF), Color(0xFFA8B8F4), Color(0xFF65729A), '床'),
  'z3d:chair': Valora3DIconSpec(
      '🪑', Color(0xFFFFEAD7), Color(0xFFDDA16E), Color(0xFF7B563F), '椅子'),
  'z3d:shoe': Valora3DIconSpec(
      '👟', Color(0xFFEAF9FF), Color(0xFF80D2EF), Color(0xFF396F83), '鞋'),
  'z3d:shirt': Valora3DIconSpec(
      '👕', Color(0xFFEAF3FF), Color(0xFF79B7EF), Color(0xFF416E95), '衣服'),
  'z3d:glasses': Valora3DIconSpec(
      '👓', Color(0xFFF0F4F8), Color(0xFFC8D3DE), Color(0xFF4B5563), '眼镜'),
  'z3d:ring': Valora3DIconSpec(
      '💍', Color(0xFFF7F0FF), Color(0xFFCA9CFF), Color(0xFF7751A6), '戒指'),
  'z3d:book': Valora3DIconSpec(
      '📚', Color(0xFFFFEAEF), Color(0xFFF18CA6), Color(0xFF8A4B62), '书籍'),
  'z3d:music': Valora3DIconSpec(
      '🎵', Color(0xFFE9E9FF), Color(0xFF9D9CF4), Color(0xFF5554A4), '音乐'),
  'z3d:guitar': Valora3DIconSpec(
      '🎸', Color(0xFFFFECD8), Color(0xFFE39A55), Color(0xFF8A5634), '乐器'),
  'z3d:ball': Valora3DIconSpec(
      '🏀', Color(0xFFFFE6C9), Color(0xFFFF9E3D), Color(0xFF9B501B), '篮球'),
  'z3d:bike': Valora3DIconSpec(
      '🚲', Color(0xFFEFFFF8), Color(0xFF7FDCBD), Color(0xFF407766), '单车'),
  'z3d:flight': Valora3DIconSpec(
      '✈️', Color(0xFFEAF6FF), Color(0xFF8CC8EC), Color(0xFF456E8A), '旅行'),
  'z3d:trophy': Valora3DIconSpec(
      '🏆', Color(0xFFFFF2C0), Color(0xFFF5BA42), Color(0xFF9A641C), '奖杯'),
  'z3d:magic': Valora3DIconSpec(
      '🪄', Color(0xFFF6ECFF), Color(0xFFC98CFF), Color(0xFF8052A8), '魔法'),
  'z3d:target': Valora3DIconSpec(
      '🎯', Color(0xFFFFEAE9), Color(0xFFFF8F86), Color(0xFFB4433D), '目标'),
  'z3d:clock': Valora3DIconSpec(
      '⏰', Color(0xFFFFF5E2), Color(0xFFFFC56C), Color(0xFFAA7232), '闹钟'),
  'z3d:tools': Valora3DIconSpec(
      '🧰', Color(0xFFFFEBE0), Color(0xFFEAA070), Color(0xFF7C4A32), '工具箱'),
  'z3d:gift': Valora3DIconSpec(
      '🎁', Color(0xFFFFEAF3), Color(0xFFFF96C4), Color(0xFF9D4A70), '礼物'),
  'z3d:jar': Valora3DIconSpec(
      '🫙', Color(0xFFEFFFFA), Color(0xFF9FEBD5), Color(0xFF5C9485), '罐子'),
  'z3d:tablet': Valora3DIconSpec(
      '📱', Color(0xFFE8F5FF), Color(0xFF8FD3F7), Color(0xFF4E7EA0), '平板'),
  'z3d:server': Valora3DIconSpec(
      '🗄️', Color(0xFFEFF4FA), Color(0xFFB4C3D8), Color(0xFF66758C), '服务器'),
  'z3d:microphone': Valora3DIconSpec(
      '🎙️', Color(0xFFF0F4FF), Color(0xFFAABAF3), Color(0xFF56658A), '麦克风'),
  'z3d:drone': Valora3DIconSpec(
      '🚁', Color(0xFFEAF6FF), Color(0xFF9CD2F1), Color(0xFF51748A), '无人机'),
  'z3d:coffee': Valora3DIconSpec(
      '☕', Color(0xFFFFF1E3), Color(0xFFD9A06E), Color(0xFF7B4C30), '咖啡'),
  'z3d:tea': Valora3DIconSpec(
      '🍵', Color(0xFFEFFFF3), Color(0xFF8EDC9A), Color(0xFF517A55), '茶具'),
  'z3d:toy': Valora3DIconSpec(
      '🧸', Color(0xFFFFEAD8), Color(0xFFE6A66F), Color(0xFF8B5D3D), '玩具'),
  'z3d:art': Valora3DIconSpec(
      '🎨', Color(0xFFFFF0FB), Color(0xFFFFA8DC), Color(0xFF925A88), '艺术'),
  'z3d:camp': Valora3DIconSpec(
      '⛺', Color(0xFFFFF3DB), Color(0xFFE7B967), Color(0xFF7D673D), '露营'),
  'z3d:fishing': Valora3DIconSpec(
      '🎣', Color(0xFFEAFBFF), Color(0xFF8FDCEC), Color(0xFF4F7D89), '钓具'),
  'z3d:ski': Valora3DIconSpec(
      '🎿', Color(0xFFEAF5FF), Color(0xFF9BC8F0), Color(0xFF496B88), '滑雪'),
  'z3d:pet': Valora3DIconSpec(
      '🐾', Color(0xFFFFF1E8), Color(0xFFE8AE8D), Color(0xFF7B5A4B), '宠物'),
  'z3d:medical': Valora3DIconSpec(
      '💊', Color(0xFFFFEFF2), Color(0xFFFF9AAA), Color(0xFF9A4F5E), '医药'),
  'z3d:cosmetic': Valora3DIconSpec(
      '💄', Color(0xFFFFEAF2), Color(0xFFFF8DBB), Color(0xFF98506D), '美妆'),
  'z3d:key': Valora3DIconSpec(
      '🔑', Color(0xFFFFF5D8), Color(0xFFEEC667), Color(0xFF9A742D), '钥匙'),
  'z3d:lock': Valora3DIconSpec(
      '🔐', Color(0xFFFFF0C8), Color(0xFFDDB24F), Color(0xFF7B622D), '锁具'),
  'z3d:briefcase': Valora3DIconSpec(
      '💼', Color(0xFFFFEAD8), Color(0xFFBD7F55), Color(0xFF70442F), '公文包'),
  'z3d:pen': Valora3DIconSpec(
      '🖋️', Color(0xFFEFF4FF), Color(0xFFAEBCE8), Color(0xFF4F5B78), '钢笔'),
  'z3d:lab': Valora3DIconSpec(
      '🔬', Color(0xFFEFFCFF), Color(0xFF9CE6EF), Color(0xFF4D7B83), '实验'),
  'z3d:ticket': Valora3DIconSpec(
      '🎫', Color(0xFFFFF0E4), Color(0xFFFFB67D), Color(0xFF986039), '票券'),
};

const Map<String, List<String>> kAlbumIconLibrary = {
  '相册': [
    '🖼️',
    '📸',
    '🌄',
    '🌇',
    '🌃',
    '🌌',
    '🏞️',
    '🏙️',
    '🏡',
    '🎞️',
    '🧾',
    '🗂️',
    '📋',
    '🧷',
    '🔖',
    '🏷️',
    '🛍️',
    '🎁',
    '🧸',
    '🪆'
  ],
  '票据': [
    '🧾',
    '📄',
    '📃',
    '📑',
    '🧮',
    '💳',
    '💵',
    '💴',
    '💶',
    '💷',
    '🪙',
    '🏦',
    '🏧',
    '📊',
    '📈'
  ],
  '风景': [
    '🌄',
    '🌅',
    '🌇',
    '🌆',
    '🌃',
    '🌌',
    '🌉',
    '🌁',
    '🏞️',
    '🏖️',
    '🏝️',
    '🏜️',
    '🏕️',
    '⛰️',
    '🌋',
    '🌊',
    '🌲',
    '🌳'
  ],
  '质感': [
    '◻️',
    '◼️',
    '⬜',
    '⬛',
    '⚪',
    '⚫',
    '🔘',
    '💠',
    '🔹',
    '🔸',
    '🟦',
    '🟩',
    '🟨',
    '🟧',
    '🟪',
    '🟫'
  ],
  '生活': [
    '☕',
    '🍵',
    '🧋',
    '🍽️',
    '🥣',
    '🍳',
    '🫖',
    '🧴',
    '🪥',
    '🧼',
    '🪒',
    '🧹',
    '🧺',
    '🪣',
    '🪴'
  ],
};

const Map<String, List<String>> kEmojiIconLibrary = {
  '全部': [
    '📦',
    '✨',
    '⭐',
    '💫',
    '🌟',
    '💎',
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🖤',
    '🤍',
    '🤎',
    '🔥',
    '⚡',
    '🌈',
    '☁️',
    '☀️',
    '🌙',
    '🌍',
    '🎯',
    '🏆',
    '🎁',
    '🧸',
    '🪄',
    '🔮',
    '🧿',
    '🪙',
    '💳',
    '💰',
    '💵',
    '💴',
    '💶',
    '💷',
    '🧾',
    '📌',
    '🔖',
    '🏷️',
    '🗃️',
    '🗂️',
    '🧰',
    '🧱',
    '🧵',
    '🪡',
    '🧶',
    '🧩',
    '🪩',
    '🔐',
    '🛡️',
    '📈',
    '📊'
  ],
  '数码': [
    '📱',
    '📲',
    '☎️',
    '📞',
    '📟',
    '💻',
    '🖥️',
    '🖥',
    '🖨️',
    '⌨️',
    '🖱️',
    '🖲️',
    '💽',
    '💾',
    '💿',
    '📀',
    '📷',
    '📸',
    '📹',
    '🎥',
    '📺',
    '📻',
    '🎧',
    '🎙️',
    '🎚️',
    '🎛️',
    '🕹️',
    '🎮',
    '⌚',
    '🔋',
    '🪫',
    '🔌',
    '📡',
    '🛰️',
    '💡',
    '🔦'
  ],
  '电器': [
    '🧊',
    '🧺',
    '🧹',
    '🧽',
    '🪣',
    '🧯',
    '🛁',
    '🚿',
    '🧴',
    '🪥',
    '🧼',
    '🪒',
    '🪭',
    '💡',
    '🔦',
    '🔋',
    '🪫',
    '🔌',
    '🍳',
    '🥘',
    '🫕',
    '🫖',
    '☕',
    '🥤',
    '🧋',
    '🍽️',
    '🥣',
    '🥄',
    '🔪',
    '🧂'
  ],
  '家居': [
    '🏠',
    '🏡',
    '🏘️',
    '🏢',
    '🏬',
    '🛋️',
    '🪑',
    '🛏️',
    '🚪',
    '🪟',
    '🪞',
    '🖼️',
    '🪴',
    '🌵',
    '🌱',
    '🌿',
    '🕯️',
    '🧸',
    '🪆',
    '🧺',
    '🪜',
    '🧱',
    '🧹',
    '🧽',
    '🧴',
    '🛁',
    '🚿'
  ],
  '交通': [
    '🚗',
    '🚕',
    '🚙',
    '🚌',
    '🚎',
    '🏎️',
    '🚓',
    '🚑',
    '🚒',
    '🚚',
    '🚛',
    '🚜',
    '🚲',
    '🛴',
    '🛵',
    '🏍️',
    '🚄',
    '🚅',
    '🚆',
    '🚇',
    '🚊',
    '✈️',
    '🛫',
    '🛬',
    '🚁',
    '⛵',
    '🚤',
    '🛥️',
    '🧳',
    '🛞'
  ],
  '穿搭': [
    '🎒',
    '👜',
    '👛',
    '💼',
    '🧳',
    '👟',
    '🥾',
    '👠',
    '🥿',
    '👞',
    '🩴',
    '🧢',
    '👒',
    '🎩',
    '🎓',
    '👑',
    '👓',
    '🕶️',
    '🥽',
    '⌚',
    '💍',
    '📿',
    '👕',
    '👖',
    '🧥',
    '🥼',
    '🦺',
    '👗',
    '👔',
    '🧣',
    '🧤',
    '🧦'
  ],
  '娱乐': [
    '🎮',
    '🕹️',
    '🎧',
    '🎤',
    '🎹',
    '🎸',
    '🎻',
    '🥁',
    '🎷',
    '🎺',
    '🪗',
    '🪕',
    '🎬',
    '🎞️',
    '🎥',
    '📚',
    '📖',
    '🖊️',
    '✒️',
    '🖋️',
    '🧩',
    '🎲',
    '🃏',
    '♟️',
    '🎯',
    '🎳',
    '🎨',
    '🖌️',
    '🪄',
    '🪩'
  ],
  '运动': [
    '⚽',
    '🏀',
    '🏈',
    '⚾',
    '🥎',
    '🎾',
    '🏐',
    '🏉',
    '🥏',
    '🎱',
    '🪀',
    '🏓',
    '🏸',
    '🥅',
    '🏒',
    '🏑',
    '🥍',
    '🏏',
    '🛹',
    '🛼',
    '⛸️',
    '🥊',
    '🥋',
    '🎽',
    '⛳',
    '🎣',
    '🤿',
    '🏹'
  ],
  '收藏': [
    '💎',
    '🪙',
    '🏆',
    '🎖️',
    '🏅',
    '🥇',
    '🥈',
    '🥉',
    '📷',
    '⌚',
    '🧸',
    '🪆',
    '🖼️',
    '📚',
    '🧿',
    '🔮',
    '🪄',
    '🧬',
    '🧭',
    '🗿',
    '⚱️',
    '🪩',
    '🎟️',
    '🎫',
    '🖋️',
    '🪶'
  ],
  '办公': [
    '📚',
    '📖',
    '📕',
    '📗',
    '📘',
    '📙',
    '📓',
    '📔',
    '📒',
    '🗒️',
    '📄',
    '📃',
    '📑',
    '📋',
    '📁',
    '📂',
    '🗂️',
    '🗃️',
    '✏️',
    '🖊️',
    '🖋️',
    '✒️',
    '🖌️',
    '📎',
    '🖇️',
    '📌',
    '📍',
    '📏',
    '📐',
    '🧮'
  ],
  '食品': [
    '🍎',
    '🍊',
    '🍋',
    '🍌',
    '🍉',
    '🍇',
    '🍓',
    '🫐',
    '🍒',
    '🍑',
    '🥭',
    '🍍',
    '🥥',
    '🥝',
    '🍅',
    '🥑',
    '🥦',
    '🥕',
    '🌽',
    '🥐',
    '🍞',
    '🥖',
    '🧀',
    '🍗',
    '🍔',
    '🍟',
    '🍕',
    '🍣',
    '🍰',
    '🍫',
    '☕',
    '🧋'
  ],
};

const Map<String, List<String>> kThreeDIconLibrary = {
  '全部': [
    'z3d:box',
    'z3d:phone',
    'z3d:laptop',
    'z3d:camera',
    'z3d:headphone',
    'z3d:watch',
    'z3d:game',
    'z3d:car',
    'z3d:house',
    'z3d:bag',
    'z3d:suitcase',
    'z3d:diamond',
    'z3d:coin',
    'z3d:wallet',
    'z3d:card',
    'z3d:receipt',
    'z3d:printer',
    'z3d:keyboard',
    'z3d:mouse',
    'z3d:monitor',
    'z3d:tv',
    'z3d:router',
    'z3d:battery',
    'z3d:plug',
    'z3d:bulb',
    'z3d:fridge',
    'z3d:washer',
    'z3d:broom',
    'z3d:plant',
    'z3d:sofa',
    'z3d:bed',
    'z3d:chair',
    'z3d:shoe',
    'z3d:shirt',
    'z3d:glasses',
    'z3d:ring',
    'z3d:book',
    'z3d:music',
    'z3d:guitar',
    'z3d:ball',
    'z3d:bike',
    'z3d:flight',
    'z3d:trophy',
    'z3d:magic',
    'z3d:target',
    'z3d:clock',
    'z3d:tools',
    'z3d:gift',
    'z3d:jar',
    'z3d:tablet',
    'z3d:server',
    'z3d:microphone',
    'z3d:drone',
    'z3d:coffee',
    'z3d:tea',
    'z3d:toy',
    'z3d:art',
    'z3d:camp',
    'z3d:fishing',
    'z3d:ski',
    'z3d:pet',
    'z3d:medical',
    'z3d:cosmetic',
    'z3d:key',
    'z3d:lock',
    'z3d:briefcase',
    'z3d:pen',
    'z3d:lab',
    'z3d:ticket'
  ],
  '数码': [
    'z3d:phone',
    'z3d:laptop',
    'z3d:monitor',
    'z3d:keyboard',
    'z3d:mouse',
    'z3d:headphone',
    'z3d:watch',
    'z3d:camera',
    'z3d:printer',
    'z3d:tv',
    'z3d:router',
    'z3d:battery',
    'z3d:plug',
    'z3d:game',
    'z3d:tablet',
    'z3d:server',
    'z3d:microphone',
    'z3d:drone'
  ],
  '电器': [
    'z3d:fridge',
    'z3d:washer',
    'z3d:broom',
    'z3d:bulb',
    'z3d:battery',
    'z3d:plug',
    'z3d:tv',
    'z3d:printer',
    'z3d:router'
  ],
  '生活': [
    'z3d:box',
    'z3d:bag',
    'z3d:suitcase',
    'z3d:plant',
    'z3d:sofa',
    'z3d:bed',
    'z3d:chair',
    'z3d:gift',
    'z3d:jar',
    'z3d:tablet',
    'z3d:server',
    'z3d:microphone',
    'z3d:drone',
    'z3d:coffee',
    'z3d:tea',
    'z3d:toy',
    'z3d:art',
    'z3d:camp',
    'z3d:fishing',
    'z3d:ski',
    'z3d:pet',
    'z3d:medical',
    'z3d:cosmetic',
    'z3d:key',
    'z3d:lock',
    'z3d:briefcase',
    'z3d:pen',
    'z3d:lab',
    'z3d:ticket'
  ],
  '穿搭': [
    'z3d:bag',
    'z3d:suitcase',
    'z3d:shoe',
    'z3d:shirt',
    'z3d:glasses',
    'z3d:ring',
    'z3d:watch',
    'z3d:cosmetic',
    'z3d:briefcase'
  ],
  '交通': ['z3d:car', 'z3d:bike', 'z3d:flight', 'z3d:suitcase', 'z3d:drone'],
  '价值': [
    'z3d:diamond',
    'z3d:coin',
    'z3d:wallet',
    'z3d:card',
    'z3d:receipt',
    'z3d:trophy',
    'z3d:target',
    'z3d:key',
    'z3d:lock',
    'z3d:ticket'
  ],
  '娱乐': [
    'z3d:game',
    'z3d:music',
    'z3d:guitar',
    'z3d:ball',
    'z3d:book',
    'z3d:magic',
    'z3d:toy',
    'z3d:art',
    'z3d:camp',
    'z3d:fishing',
    'z3d:ski'
  ],
};

Map<String, List<String>> _libraryForSource(int source) {
  if (source == 0) return kAlbumIconLibrary;
  if (source == 2) return kThreeDIconLibrary;
  return kEmojiIconLibrary;
}

bool isValoraImageIcon(String value) {
  final v = value.trim();
  return v.startsWith('file://') || v.startsWith('/');
}

bool isValora3DIcon(String value) {
  final v = value.trim();
  return v.startsWith('z3d:') && kThreeDIconSpecs.containsKey(v);
}

String valoraImagePath(String value) {
  final v = value.trim();
  return v.startsWith('file://') ? Uri.parse(v).toFilePath() : v;
}

bool isValoraStickerImage(String value) {
  final path = valoraImagePath(value).toLowerCase();
  final name = path.split('/').isEmpty ? path : path.split('/').last;
  // Restored media files are prefixed with restored_<time>_<index>_, so detection must
  // look at the basename instead of requiring the marker to appear immediately after '/'.
  return name.contains('cutout_') ||
      name.contains('ai_cutout_') ||
      name.contains('adjusted_sticker_') ||
      name.contains('manual_trace_sticker_') ||
      name.contains('framed_cover_') ||
      name.contains('sticker_');
}

Widget _noScaleText(BuildContext context, Widget child) {
  final media = MediaQuery.maybeOf(context);
  if (media == null) return child;
  return MediaQuery(data: media.copyWith(textScaleFactor: 1.0), child: child);
}

int? _iconCacheSide(BuildContext context, double emojiSize) {
  final ratio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
  final side = (emojiSize * 2.2 * ratio).round();
  if (side <= 0) return null;
  return side.clamp(72, 512).toInt();
}

Widget valora3DIconVisual(BuildContext context, String value,
    {double emojiSize = 42, double borderRadius = 999}) {
  final spec = kThreeDIconSpecs[value.trim()] ?? kThreeDIconSpecs['z3d:box']!;
  final glow = spec.b.withOpacity(context.isDark ? .26 : .20);
  return RepaintBoundary(
    child: Center(
      child: SizedBox.square(
        dimension: emojiSize * 1.62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: glow,
                  blurRadius: emojiSize * .34,
                  spreadRadius: emojiSize * .04),
              BoxShadow(
                  color: spec.c.withOpacity(context.isDark ? .16 : .10),
                  blurRadius: emojiSize * .22,
                  offset: Offset(0, emojiSize * .12)),
            ],
          ),
          child: _noScaleText(
            context,
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                spec.emoji,
                textAlign: TextAlign.center,
                strutStyle: StrutStyle(
                    fontSize: emojiSize, height: 1, forceStrutHeight: true),
                textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false),
                style: TextStyle(
                  fontSize: emojiSize,
                  height: 1,
                  shadows: [
                    Shadow(
                        color: spec.b.withOpacity(context.isDark ? .26 : .18),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                    Shadow(
                        color: Colors.black
                            .withOpacity(context.isDark ? .20 : .08),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget valoraIconVisual(BuildContext context, String value,
    {double emojiSize = 42, double borderRadius = 999}) {
  final v = value.trim();
  if (isValoraImageIcon(v)) {
    final sticker = isValoraStickerImage(v);
    final cacheSide = _iconCacheSide(context, emojiSize);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: sticker ? Colors.transparent : null,
          child: Image.file(
            File(valoraImagePath(v)),
            width: double.infinity,
            height: double.infinity,
            cacheWidth: cacheSide,
            cacheHeight: cacheSide,
            gaplessPlayback: true,
            filterQuality: sticker ? FilterQuality.medium : FilterQuality.low,
            fit: sticker ? BoxFit.contain : BoxFit.cover,
            errorBuilder: (_, __, ___) => _noScaleText(
                context,
                Center(
                    child: Text('📦',
                        style: TextStyle(fontSize: emojiSize, height: 1)))),
          ),
        ),
      ),
    );
  }
  if (isValora3DIcon(v)) {
    return valora3DIconVisual(context, v,
        emojiSize: emojiSize, borderRadius: borderRadius);
  }
  return RepaintBoundary(
    child: _noScaleText(
      context,
      Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.square(
            dimension: emojiSize * 1.18,
            child: Center(
              child: Text(
                v.isEmpty ? '📦' : v,
                textAlign: TextAlign.center,
                strutStyle: StrutStyle(
                    fontSize: emojiSize, height: 1, forceStrutHeight: true),
                textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false),
                style: TextStyle(fontSize: emojiSize, height: 1),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> pickValoraIcon(
    BuildContext context, TextEditingController controller,
    {VoidCallback? onChanged}) async {
  final selected = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => IconPickerSheet(
        initial:
            controller.text.trim().isEmpty ? '📦' : controller.text.trim()),
  );
  if (selected != null && selected.trim().isNotEmpty) {
    controller.text = selected;
    onChanged?.call();
  }
}

class IconPickerSheet extends StatefulWidget {
  final String initial;
  const IconPickerSheet({super.key, required this.initial});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  int source = 1;
  String group = '全部';
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final library = _libraryForSource(source);
    if (!library.containsKey(group)) group = library.keys.first;
    final groups = library.keys.toList();
    final icons = library[group] ?? library.values.first;
    return Container(
      height: MediaQuery.sizeOf(context).height * .90,
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: kMuted.withOpacity(.22),
                  borderRadius: BorderRadius.circular(99))),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr('common.cancel'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.normal))),
              Expanded(
                  child: IconSourceTabs(
                      index: source,
                      onChanged: (v) => setState(() {
                            source = v;
                            group = _libraryForSource(v).keys.first;
                          }))),
              TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: Text(tr('common.confirm'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.normal))),
            ]),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, i) => FilterPill(
                  label: tl(groups[i]),
                  active: group == groups[i],
                  onTap: () => setState(() => group = groups[i])),
            ),
          ),
          if (source == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = await NativeBridge.pickImage();
                        if (!context.mounted) return;
                        if (uri != null && uri.trim().isNotEmpty)
                          Navigator.pop(context, uri);
                      },
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(tr('iconPicker.fromGallery')),
                    ),
                    const SizedBox(height: 8),
                    Text(tr('iconPicker.galleryHint'),
                        style: TextStyle(color: kMuted, fontSize: 12)),
                  ]),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                return IconChoiceTile(
                  icon: icon,
                  source: source,
                  active: selected == icon,
                  onTap: () {
                    tapHaptic();
                    setState(() => selected = icon);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class IconChoiceTile extends StatelessWidget {
  final String icon;
  final int source;
  final bool active;
  final VoidCallback onTap;
  const IconChoiceTile(
      {super.key,
      required this.icon,
      required this.source,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final is3d = source == 2;
    final isAlbum = source == 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: is3d
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                      Colors.white.withOpacity(context.isDark ? .10 : .90),
                      kBrand.withOpacity(.28),
                      const Color(0xFFBDEB7E).withOpacity(.22)
                    ])
              : null,
          color: is3d
              ? null
              : context.isDark
                  ? Colors.white.withOpacity(.06)
                  : const Color(0xFFF5F5F6),
          borderRadius: BorderRadius.circular(isAlbum ? 18 : 20),
          border: Border.all(
              color: active ? kBrandStrong : Colors.transparent,
              width: active ? 2 : 1),
          boxShadow: is3d
              ? [
                  BoxShadow(
                      color: kBrand.withOpacity(.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8))
                ]
              : null,
        ),
        child: Stack(children: [
          Padding(
            padding: EdgeInsets.all(is3d ? 7 : 0),
            child: is3d
                ? valoraIconVisual(context, icon,
                    emojiSize: 31, borderRadius: 16)
                : Center(
                    child: Text(icon,
                        style: TextStyle(fontSize: isAlbum ? 28 : 31))),
          ),
          if (isAlbum)
            Positioned(
                right: 7,
                bottom: 7,
                child: Icon(Icons.image_outlined,
                    size: 14, color: kMuted.withOpacity(.80))),
          if (active)
            Positioned(
                right: 5,
                top: 5,
                child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: kBrand, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        size: 13, color: kBrandInk))),
        ]),
      ),
    );
  }
}

class IconSourceTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const IconSourceTabs(
      {super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = [
      tr('iconPicker.album'),
      'Emoji',
      tr('iconPicker.threeDIcon')
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withOpacity(.06)
              : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(18)),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(labels.length, (i) {
            final active = i == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  tapHaptic();
                  onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                      color: active
                          ? (context.isDark
                              ? Colors.white.withOpacity(.14)
                              : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14)),
                  child: Text(labels[i],
                      maxLines: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: active
                              ? (context.isDark ? Colors.white : kText)
                              : kMuted)),
                ),
              ),
            );
          })),
    );
  }
}

class SmartAssetImportBar extends StatelessWidget {
  final VoidCallback onPickCover;
  final VoidCallback onScanBarcode;
  final VoidCallback onOcrReceipt;
  final VoidCallback? onCutoutCover;
  final VoidCallback? onFramedCover;
  final VoidCallback? onTraceCover;
  const SmartAssetImportBar(
      {super.key,
      required this.onPickCover,
      required this.onScanBarcode,
      required this.onOcrReceipt,
      this.onCutoutCover,
      this.onFramedCover,
      this.onTraceCover});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(children: [
        TutorialTargetAnchor(
            id: 'compose.import.cover',
            child: _SmartImportChip(
                icon: Icons.photo_library_rounded,
                label: tr('compose.pickCover'),
                onTap: onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.frame',
            child: _SmartImportChip(
                icon: Icons.crop_rounded,
                label: tr('compose.frameCrop'),
                onTap: onFramedCover ?? onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.trace',
            child: _SmartImportChip(
                icon: Icons.gesture_rounded,
                label: tr('compose.manualTrace'),
                onTap: onTraceCover ?? onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.ai',
            child: _SmartImportChip(
                icon: Icons.auto_fix_high_rounded,
                label: tr('compose.aiSticker'),
                onTap: onCutoutCover ?? onPickCover)),
        _SmartImportChip(
            icon: Icons.qr_code_scanner_rounded,
            label: tr('compose.scanBarcode'),
            onTap: onScanBarcode),
        _SmartImportChip(
            icon: Icons.receipt_long_rounded,
            label: tr('compose.receiptOcr'),
            onTap: onOcrReceipt),
      ]),
    );
  }
}

class CoverImportBar extends StatelessWidget {
  final VoidCallback onPickCover;
  final VoidCallback? onCutoutCover;
  final VoidCallback? onFramedCover;
  final VoidCallback? onTraceCover;
  final String pickLabel;
  final String stickerLabel;
  final String framedLabel;
  final String traceLabel;
  const CoverImportBar({
    super.key,
    required this.onPickCover,
    this.onCutoutCover,
    this.onFramedCover,
    this.onTraceCover,
    this.pickLabel = '',
    this.stickerLabel = '',
    this.framedLabel = '',
    this.traceLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final p = pickLabel.isEmpty ? tr('compose.pickCover') : pickLabel;
    final s = stickerLabel.isEmpty ? tr('compose.aiSticker') : stickerLabel;
    final f = framedLabel.isEmpty ? tr('compose.frameCrop') : framedLabel;
    final t = traceLabel.isEmpty ? tr('compose.manualTrace') : traceLabel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(children: [
        TutorialTargetAnchor(
            id: 'compose.import.cover',
            child: _SmartImportChip(
                icon: Icons.photo_library_rounded,
                label: p,
                onTap: onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.frame',
            child: _SmartImportChip(
                icon: Icons.crop_rounded,
                label: f,
                onTap: onFramedCover ?? onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.trace',
            child: _SmartImportChip(
                icon: Icons.gesture_rounded,
                label: t,
                onTap: onTraceCover ?? onPickCover)),
        TutorialTargetAnchor(
            id: 'compose.import.ai',
            child: _SmartImportChip(
                icon: Icons.auto_fix_high_rounded,
                label: s,
                onTap: onCutoutCover ?? onPickCover)),
      ]),
    );
  }
}

class _SmartImportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SmartImportChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            tapHaptic();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(.07)
                  : Colors.white.withOpacity(.86),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: (context.isDark ? Colors.white : Colors.black)
                      .withOpacity(.06)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(context.isDark ? 0 : .04),
                    blurRadius: 12,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.normal))
            ]),
          ),
        ),
      );
}

class ComposeSegmentedTabs extends StatelessWidget {
  final ComposeTab value;
  final ValueChanged<ComposeTab> onChanged;
  const ComposeSegmentedTabs(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: ComposeTab.values.map((tab) {
          final active = tab == value;
          final label = tab == ComposeTab.asset
              ? tr('compose.asset')
              : tr('compose.wish');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 10,
                      width: active ? 54 : 0,
                      decoration: BoxDecoration(
                          color: kBrand.withOpacity(.95),
                          borderRadius: BorderRadius.circular(999))),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.normal,
                            color: active
                                ? (context.isDark ? Colors.white : kText)
                                : kMuted.withOpacity(.70))),
                  ),
                ],
              ),
            ),
          );
        }).toList());
  }
}

class EditableIconPreview extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const EditableIconPreview(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final icon = controller.text.trim().isEmpty ? '📦' : controller.text.trim();
    return GestureDetector(
      onTap: () => pickValoraIcon(context, controller, onChanged: onChanged),
      child: SizedBox(
        width: 132,
        height: 116,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withOpacity(.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: valoraIconVisual(context, icon,
                  emojiSize: 54, borderRadius: 30),
            ),
            Positioned(
              right: 7,
              bottom: 15,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: context.isDark
                        ? kDarkBlueSoft.withOpacity(.82)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6))
                    ]),
                child: const Icon(Icons.edit_rounded, size: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftFormCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const SoftFormCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(12)});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: context.isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: (context.isDark ? Colors.white : Colors.black)
                  .withOpacity(.03)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? 0 : .035),
                blurRadius: 26,
                offset: const Offset(0, 14))
          ],
        ),
        child: child,
      );
}

class FormLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  const FormLine(
      {super.key,
      required this.icon,
      required this.label,
      required this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap == null
          ? null
          : () {
              tapHaptic();
              onTap!.call();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(icon,
              size: 22,
              color: context.isDark
                  ? Colors.white.withOpacity(.86)
                  : kText.withOpacity(.86)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.normal))),
          const SizedBox(width: 10),
          Flexible(
              fit: FlexFit.loose,
              child: Align(alignment: Alignment.centerRight, child: trailing)),
        ]),
      ),
    );
  }
}

class SelectOption<T> {
  final T value;
  final String label;
  final String? iconText;
  const SelectOption({required this.value, required this.label, this.iconText});
}

class RoundedSelectField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<SelectOption<T>> options;
  final ValueChanged<T> onChanged;
  const RoundedSelectField(
      {super.key,
      required this.label,
      required this.value,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    SelectOption<T>? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }
    selected ??= options.isNotEmpty ? options.first : null;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        lightHaptic();
        appSheet(
          context,
          title: label,
          subtitle: tr('select.immediateApply'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((item) {
              final active = item.value == value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      mediumHaptic();
                      onChanged(item.value);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: active
                            ? kBrand.withOpacity(context.isDark ? .22 : .34)
                            : (context.isDark
                                ? Colors.white.withOpacity(.055)
                                : const Color(0xFFF4F5F6)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active
                                ? kBrandStrong.withOpacity(.55)
                                : Colors.transparent),
                      ),
                      child: Row(children: [
                        if (item.iconText != null) ...[
                          Text(item.iconText!,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10)
                        ],
                        Expanded(
                            child: Text(item.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15))),
                        if (active)
                          const Icon(Icons.check_circle_rounded,
                              color: kBrandStrong),
                      ]),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded)),
        child: Text(selected?.label ?? tr('common.unset'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.normal)),
      ),
    );
  }
}

Future<void> pickAndroidOfficialDate(
    BuildContext context, TextEditingController controller,
    {VoidCallback? onChanged, String? title}) async {
  final parsed = parseFlexibleDate(controller.text);
  final selected = await showValoraDatePicker(
    context,
    initialDate: parsed ?? DateTime.now(),
    title: title ?? tr('common.selectDate'),
  );
  if (selected == null) return;
  controller.text = dateText(selected);
  controller.selection =
      TextSelection.collapsed(offset: controller.text.length);
  onChanged?.call();
  selectionHaptic();
}

class DateFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool requiredField;
  final VoidCallback? onChanged;
  const DateFormField(
      {super.key,
      required this.controller,
      required this.label,
      this.requiredField = false,
      this.onChanged});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        validator: (v) {
          final text = (v ?? '').trim();
          if (text.isEmpty)
            return requiredField ? tr('date.selectOrEnter') : null;
          return parseFlexibleDate(text) == null ? tr('date.enterValid') : null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: 'YYYY-MM-DD',
          helperText: null,
          helperMaxLines: 1,
          errorMaxLines: 2,
          prefixIcon: const Icon(Icons.calendar_today_rounded),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
            if (controller.text.trim().isNotEmpty && !requiredField)
              ValoraGlassIconButton(
                tooltip: tr('date.clear'),
                icon: Icons.close_rounded,
                size: 34,
                onTap: () {
                  controller.clear();
                  onChanged?.call();
                },
              ),
            ValoraGlassIconButton(
              tooltip: tr('date.openPicker'),
              icon: Icons.calendar_month_rounded,
              size: 34,
              onTap: () => pickAndroidOfficialDate(context, controller,
                  onChanged: onChanged, title: label),
            ),
          ]),
        ),
        onChanged: (v) {
          final parsed = parseFlexibleDate(v);
          if (parsed != null) {
            controller.text = dateText(parsed);
            controller.selection =
                TextSelection.collapsed(offset: controller.text.length);
            onChanged?.call();
          }
        },
        onFieldSubmitted: (v) {
          final parsed = parseFlexibleDate(v);
          if (parsed != null) controller.text = dateText(parsed);
          onChanged?.call();
        },
      );
}

Future<DateTime?> showValoraDatePicker(BuildContext context,
    {required DateTime initialDate, required String title}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ValoraDatePickerSheet(
        initialDate: dateOnly(initialDate), title: title),
  );
}

class _ValoraDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final String title;
  const _ValoraDatePickerSheet(
      {required this.initialDate, required this.title});

  @override
  State<_ValoraDatePickerSheet> createState() => _ValoraDatePickerSheetState();
}

class _ValoraDatePickerSheetState extends State<_ValoraDatePickerSheet> {
  static const int minYear = 1900;
  static const int maxYear = 2100;
  late DateTime selected;
  late DateTime month;
  late FixedExtentScrollController yearCtl;
  late FixedExtentScrollController monthCtl;
  bool wheelMode = false;

  @override
  void initState() {
    super.initState();
    selected = dateOnly(widget.initialDate);
    month = DateTime(selected.year, selected.month);
    yearCtl = FixedExtentScrollController(
        initialItem:
            (selected.year - minYear).clamp(0, maxYear - minYear).toInt());
    monthCtl = FixedExtentScrollController(initialItem: selected.month - 1);
  }

  @override
  void dispose() {
    yearCtl.dispose();
    monthCtl.dispose();
    super.dispose();
  }

  int get daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  void shiftMonth(int delta) {
    final next = DateTime(month.year, month.month + delta);
    setState(() {
      month = DateTime(next.year, next.month);
      final day = math.min(selected.day, daysInMonth);
      selected = DateTime(month.year, month.month, day);
    });
    _syncWheels();
  }

  void _syncWheels() {
    if (yearCtl.hasClients)
      yearCtl.animateToItem(
          (month.year - minYear).clamp(0, maxYear - minYear).toInt(),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic);
    if (monthCtl.hasClients)
      monthCtl.animateToItem(month.month - 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic);
  }

  void setMonthYear({int? year, int? monthValue}) {
    final y = (year ?? month.year).clamp(minYear, maxYear).toInt();
    final m = (monthValue ?? month.month).clamp(1, 12).toInt();
    final maxDay = DateTime(y, m + 1, 0).day;
    setState(() {
      month = DateTime(y, m);
      selected = DateTime(y, m, math.min(selected.day, maxDay));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .86),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 14 + bottom),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0D2434) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(dark ? .34 : .12),
              blurRadius: 30,
              offset: const Offset(0, -8))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: kMuted.withOpacity(.22),
                  borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 10),
          Row(children: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('common.cancel'))),
            Expanded(
                child: Text(widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.normal))),
            TextButton(
                onPressed: () => Navigator.pop(context, dateOnly(selected)),
                child: Text(tr('common.done'))),
          ]),
          const SizedBox(height: 4),
          _DatePickerHeader(
            selected: selected,
            month: month,
            wheelMode: wheelMode,
            onToggleMode: () {
              setState(() => wheelMode = !wheelMode);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _syncWheels());
            },
            onPrev: () => shiftMonth(-1),
            onNext: () => shiftMonth(1),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: wheelMode
                ? _buildWheelMode(context)
                : _buildCalendarMode(context),
          ),
          const SizedBox(height: 10),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () {
                final now = dateOnly(DateTime.now());
                setState(() {
                  selected = now;
                  month = DateTime(now.year, now.month);
                });
                _syncWheels();
              },
              icon: const Icon(Icons.today_rounded, size: 18),
              label: Text(tr('date.today')),
            ),
            const Spacer(),
            Text(dateText(selected),
                style: TextStyle(
                    color: dark ? Colors.white.withOpacity(.72) : kMuted,
                    fontSize: 13)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCalendarMode(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final count = 42;
    final labels = [
      tr('date.weekday1Short'),
      tr('date.weekday2Short'),
      tr('date.weekday3Short'),
      tr('date.weekday4Short'),
      tr('date.weekday5Short'),
      tr('date.weekday6Short'),
      tr('date.weekday7Short')
    ];
    return Column(
      key: const ValueKey('calendar'),
      children: [
        const SizedBox(height: 8),
        Row(
            children: labels
                .map((e) => Expanded(
                    child: Center(
                        child: Text(e,
                            style:
                                const TextStyle(color: kMuted, fontSize: 12)))))
                .toList()),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.05),
          itemBuilder: (context, index) {
            final day = index - leading + 1;
            if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
            final date = DateTime(month.year, month.month, day);
            return _DateDayCell(
              date: date,
              selected: date.year == selected.year &&
                  date.month == selected.month &&
                  date.day == selected.day,
              today: dateText(date) == dateText(DateTime.now()),
              onTap: () => setState(() => selected = dateOnly(date)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWheelMode(BuildContext context) {
    final dark = context.isDark;
    return SizedBox(
      key: const ValueKey('wheels'),
      height: 244,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(tr('date.wheelHint'),
              style: TextStyle(
                  fontSize: 12,
                  color: dark ? Colors.white.withOpacity(.60) : kMuted)),
        ),
        Expanded(
          child: Row(children: [
            Expanded(
                child: _buildWheel(
              controller: yearCtl,
              itemCount: maxYear - minYear + 1,
              labelBuilder: (i) => datePickerYearWheelLabel(minYear + i),
              onSelectedItemChanged: (i) => setMonthYear(year: minYear + i),
            )),
            Expanded(
                child: _buildWheel(
              controller: monthCtl,
              itemCount: 12,
              labelBuilder: (i) => datePickerMonthWheelLabel(i + 1),
              onSelectedItemChanged: (i) => setMonthYear(monthValue: i + 1),
            )),
          ]),
        ),
        TextButton.icon(
            onPressed: () => setState(() => wheelMode = false),
            icon: const Icon(Icons.calendar_view_month_rounded),
            label: Text(tr('date.backToCalendar'))),
      ]),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) labelBuilder,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 42,
      diameterRatio: 1.45,
      perspective: .003,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) => Center(
            child: Text(labelBuilder(index),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.normal))),
      ),
    );
  }
}

class _DatePickerHeader extends StatelessWidget {
  final DateTime selected;
  final DateTime month;
  final bool wheelMode;
  final VoidCallback onToggleMode;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _DatePickerHeader(
      {required this.selected,
      required this.month,
      required this.wheelMode,
      required this.onToggleMode,
      required this.onPrev,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(.055) : const Color(0xFFF5FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBrand.withOpacity(dark ? .18 : .24)),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: onToggleMode,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  datePickerMonthTitle(month),
                  style: TextStyle(
                      fontSize: 21,
                      height: 1.05,
                      color: dark ? Colors.white : kText,
                      fontWeight: FontWeight.normal)),
              const SizedBox(height: 5),
              Text(
                  '${datePickerSelectedTitle(selected)} · ${_weekdayCn(selected)} · ${tr('date.tapToSwitchYearMonth')}',
                  style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white.withOpacity(.62) : kMuted)),
            ]),
          ),
        ),
        ValoraGlassIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
            size: 38,
            tooltip: tr('date.prevMonth')),
        const SizedBox(width: 6),
        ValoraGlassIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            size: 38,
            tooltip: tr('date.nextMonth')),
      ]),
    );
  }
}

class _DateDayCell extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool today;
  final VoidCallback onTap;
  const _DateDayCell(
      {required this.date,
      required this.selected,
      required this.today,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? kBrand
                : today
                    ? kBrand.withOpacity(dark ? .12 : .16)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: selected
                    ? kBrandStrong
                    : today
                        ? kBrandStrong.withOpacity(.65)
                        : Colors.transparent,
                width: 1),
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 15,
              color: selected
                  ? kBrandInk
                  : dark
                      ? Colors.white.withOpacity(.90)
                      : kText,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

String _weekdayCn(DateTime date) {
  final labels = [
    tr('date.monday'),
    tr('date.tuesday'),
    tr('date.wednesday'),
    tr('date.thursday'),
    tr('date.friday'),
    tr('date.saturday'),
    tr('date.sunday')
  ];
  return labels[(date.weekday - 1).clamp(0, 6).toInt()];
}

class ValoraGlassSaveContent extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ValueChanged<bool>? onPressChanged;
  const ValoraGlassSaveContent(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.onPressChanged});

  @override
  State<ValoraGlassSaveContent> createState() => _ValoraGlassSaveContentState();
}

class _ValoraGlassSaveContentState extends State<ValoraGlassSaveContent> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
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
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 320),
        curve: down ? Curves.easeOutBack : Curves.easeOutCubic,
        scale: down ? 1.055 : 1,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    size: 20,
                    color: dark
                        ? Colors.white.withOpacity(.96)
                        : kText.withOpacity(.95)),
                const SizedBox(width: 7),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.normal,
                  color: dark
                      ? Colors.white.withOpacity(.96)
                      : kText.withOpacity(.95),
                  letterSpacing: .08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiquidSaveButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  const LiquidSaveButton(
      {super.key, required this.label, required this.onPressed, this.icon});

  @override
  State<LiquidSaveButton> createState() => _LiquidSaveButtonState();
}

class _LiquidSaveButtonState extends State<LiquidSaveButton> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 320),
        curve: down ? Curves.easeOutBack : Curves.easeOutCubic,
        scale: down ? 1.055 : 1,
        child: ValoraLiquidGlassSurface(
          height: 58,
          radius: 999,
          distortion: .11,
          distortionWidth: 36,
          blurSigma: .55,
          pixelRatio: .52,
          tintOpacity: context.isDark ? .11 : .21,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    size: 19, color: context.isDark ? Colors.white : kText),
                const SizedBox(width: 6)
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.normal,
                      color: context.isDark
                          ? Colors.white.withOpacity(.94)
                          : kText.withOpacity(.94),
                      letterSpacing: .08)),
            ],
          ),
        ),
      ),
    );
  }
}
