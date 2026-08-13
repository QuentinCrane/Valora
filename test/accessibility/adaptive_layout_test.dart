import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    setActiveLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
  });

  test('window classes use the product width breakpoints', () {
    expect(valoraWindowClassForWidth(320), ValoraWindowClass.compact);
    expect(valoraWindowClassForWidth(599.9), ValoraWindowClass.compact);
    expect(valoraWindowClassForWidth(600), ValoraWindowClass.medium);
    expect(valoraWindowClassForWidth(839.9), ValoraWindowClass.medium);
    expect(valoraWindowClassForWidth(840), ValoraWindowClass.expanded);
  });

  testWidgets('page sections remain bounded at phone and tablet widths',
      (tester) async {
    for (final width in [320.0, 390.0, 600.0, 840.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: Scaffold(
            body: SliverPageFrame(
              sections: [
                (_) => Text(tr('analytics.title')),
                (_) => GridWrap(children: const [
                      DetailCell(label: '资产总值', value: '¥123,456.78'),
                      DetailCell(label: '平均日均成本', value: '¥1,234.56'),
                    ]),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.byType(ValoraAdaptiveContent), findsNWidgets(2));
    }
    addTearDown(tester.view.reset);
  });

  testWidgets('detail cells survive 200 percent text scaling', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: ListView(
              padding: EdgeInsets.zero,
              children: const [
                GridWrap(children: [
                  DetailCell(label: '当前资产总价值', value: '¥1,234,567.89'),
                  DetailCell(label: '平均每日成本', value: '¥12,345.67'),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('当前资产总价值'), findsOneWidget);
    addTearDown(tester.view.reset);
  });

  testWidgets('Dock exposes four selectable navigation targets',
      (tester) async {
    setActiveLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    final semantics = tester.ensureSemantics();
    final store = AppStore();
    await tester.pumpWidget(
      AppScope(
        store: store,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: LiquidDock(
                index: 0,
                onChanged: (_) {},
                useLiquidGlass: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in [
      tr('dock.assets'),
      tr('dock.wishes'),
      tr('dock.analytics'),
      tr('dock.settings'),
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
      expect(tester.getSize(find.bySemanticsLabel(label)).height,
          greaterThanOrEqualTo(kValoraMinimumTouchTarget));
    }
    semantics.dispose();
    addTearDown(tester.view.reset);
  });

  testWidgets('chart panels expose a spoken summary', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      AppScope(
        store: AppStore(),
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: Scaffold(
            body: ChartPanel(
              title: '趋势',
              subtitle: '摘要',
              semanticLabel: '趋势：两项，起点 ¥10，终点 ¥8',
              child: const SizedBox(height: 120),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('趋势：两项，起点 ¥10，终点 ¥8'), findsOneWidget);
    semantics.dispose();
  });
}
