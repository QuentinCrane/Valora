import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart' as lge;
import 'package:valora_assets/main.dart';

void main() {
  testWidgets('glass navigation supports taps, dragging, add and semantics',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    final store = AppStore();
    var selected = 0;
    var added = 0;
    await tester.pumpWidget(AppScope(
        store: store,
        child: MaterialApp(
          home: Scaffold(
              body: lge.LiquidGlassView(
            realTimeCapture: false,
            backgroundWidget: const ColoredBox(color: Colors.white),
            child: StatefulBuilder(
                builder: (context, setState) => ValoraGlassNavigation(
                      index: selected,
                      onChanged: (value) => setState(() => selected = value),
                      onAdd: () => added++,
                      dockWidth: 196,
                      dockHeight: 76,
                      addSize: 66,
                      safeBottom: 0,
                    )),
          )),
        )));
    await tester.pump(const Duration(milliseconds: 100));
    for (final label in [
      tr('dock.assets'),
      tr('dock.wishes'),
      tr('dock.analytics'),
      tr('dock.settings')
    ]) {
      final finder = find.bySemanticsLabel(label);
      expect(finder, findsOneWidget);
      expect(tester.getSize(finder).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
      expect(
          tester
              .getSemantics(finder)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue);
    }
    final bar = find.byKey(const ValueKey('valora.shell.library-tab-bar'));
    final origin = tester.getTopLeft(bar);
    await tester.tapAt(origin + const Offset(74, 38));
    await tester.pump(const Duration(milliseconds: 100));
    expect(selected, 1);
    await tester.dragFrom(origin + const Offset(25, 38), const Offset(150, 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(selected, 3);
    await tester.tap(find.byKey(const ValueKey('valora.shell.library-add')));
    await tester.pump();
    expect(added, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('small surfaces follow glass and reduced-motion settings',
      (tester) async {
    final store = AppStore();
    Widget page() => AppScope(
        store: store,
        child: const MaterialApp(
          home: Scaffold(
              body: ValoraLiquidGlassSurface(
                  width: 80, height: 48, radius: 24, child: Text('control'))),
        ));
    await tester.pumpWidget(page());
    await tester.pump();
    expect(find.byType(lge.LiquidGlassLens), findsOneWidget);
    store.settings =
        store.settings.copyWith(glassEffectMode: GlassEffectMode.classic);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(page());
    await tester.pump();
    expect(find.byType(lge.LiquidGlassLens), findsNothing);
    expect(find.byType(BackdropFilter), findsWidgets);
  });

  testWidgets('glass settings controls remain interactive and accessible',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final store = AppStore();
    var enabled = false;
    var value = .5;
    var commits = 0;
    await tester.pumpWidget(AppScope(
      store: store,
      child: MaterialApp(
        home: Scaffold(body: StatefulBuilder(builder: (context, update) {
          return Column(children: [
            SettingSwitchRow(
              icon: Icons.blur_on,
              iconBg: Colors.blue,
              label: 'Glass switch',
              description: 'Test',
              value: enabled,
              onChanged: (v) => update(() => enabled = v),
            ),
            ValoraAdaptiveSlider(
              value: value,
              semanticLabel: 'Glass slider',
              onChanged: (v) => update(() => value = v),
              onChangeEnd: (_) => commits++,
            ),
          ]);
        })),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(lge.LiquidGlassSwitch), findsOneWidget);
    expect(find.byType(lge.LiquidGlassSlider), findsOneWidget);
    expect(find.bySemanticsLabel('Glass slider'), findsOneWidget);
    expect(
        tester
            .getSemantics(find.bySemanticsLabel('Glass slider'))
            .getSemanticsData()
            .hasAction(SemanticsAction.increase),
        isTrue);
    await tester.tap(find.byType(lge.LiquidGlassSwitch));
    await tester.pump(const Duration(milliseconds: 100));
    expect(enabled, isTrue);
    final switchSemantics = find.bySemanticsLabel('Glass switch');
    expect(tester.getSize(switchSemantics).height, greaterThanOrEqualTo(48));
    await tester
        .tapAt(tester.getTopLeft(switchSemantics) + const Offset(35, 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(enabled, isFalse);
    await tester.drag(find.byType(lge.LiquidGlassSlider), const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(value, greaterThan(.5));
    expect(commits, 1);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
