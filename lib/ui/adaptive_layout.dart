import 'package:flutter/material.dart';

/// Window breakpoints used by the Flutter surfaces.
///
/// The thresholds match the product's compact phone, medium tablet/foldable,
/// and expanded desktop-like layout contracts. They are intentionally based on
/// logical width so the same behavior works across device pixel ratios.
enum ValoraWindowClass { compact, medium, expanded }

ValoraWindowClass valoraWindowClassForWidth(double width) {
  if (width < 600) return ValoraWindowClass.compact;
  if (width < 840) return ValoraWindowClass.medium;
  return ValoraWindowClass.expanded;
}

ValoraWindowClass valoraWindowClass(BuildContext context) =>
    valoraWindowClassForWidth(MediaQuery.sizeOf(context).width);

bool valoraIsCompact(BuildContext context) =>
    valoraWindowClass(context) == ValoraWindowClass.compact;

bool valoraIsExpanded(BuildContext context) =>
    valoraWindowClass(context) == ValoraWindowClass.expanded;

const double kValoraMinimumTouchTarget = 48;
const double kValoraContentMaxWidth = 840;

/// Centers page content on large windows while keeping compact windows full
/// width. Individual feature sections keep their own responsive layout rules.
class ValoraAdaptiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ValoraAdaptiveContent({
    super.key,
    required this.child,
    this.maxWidth = kValoraContentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Keeps a visual control compact while guaranteeing an accessible hit box.
class ValoraMinimumTouchTarget extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;

  const ValoraMinimumTouchTarget({
    super.key,
    required this.child,
    this.minWidth = kValoraMinimumTouchTarget,
    this.minHeight = kValoraMinimumTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: child,
    );
  }
}
