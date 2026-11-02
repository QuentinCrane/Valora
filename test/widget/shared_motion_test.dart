import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final mode in HomeViewMode.values) {
    testWidgets('asset $mode opens and returns through its shared surface',
        (tester) async {
      final store = _store();
      final asset = store.assets.firstWhere((item) => !item.isPriceless);
      await tester.pumpWidget(_harness(store, _assetCard(mode, asset, store)));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tapAt(tester.getTopLeft(find.byType(_assetType(mode))) +
          const Offset(30, 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AssetDetailPage), findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Hero &&
              widget.tag == ValoraMotionTag('asset', asset.id)),
          findsOneWidget);

      final route = ModalRoute.of(tester.element(find.byType(AssetDetailPage)))!
          as PageRoute<dynamic>;
      route.handleStartBackGesture(progress: 1);
      route.handleUpdateBackGestureProgress(progress: .55);
      await tester.pump();
      route.handleCancelBackGesture();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AssetDetailPage), findsOneWidget);

      Navigator.of(tester.element(find.byType(AssetDetailPage))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(_assetType(mode)), findsOneWidget);
    });
  }

  testWidgets('wish editing survives a cancelled shared return',
      (tester) async {
    final store = _store();
    final wish = store.wishes.first;
    await tester.pumpWidget(_harness(store, WishCard(wish: wish)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester
        .tapAt(tester.getTopLeft(find.byType(WishCard)) + const Offset(30, 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(WishEditorPage), findsOneWidget);

    final name = find.byType(TextFormField).first;
    await tester.enterText(name, 'changed without saving');
    final editableBefore = tester.state<EditableTextState>(
        find.descendant(of: name, matching: find.byType(EditableText)));
    expect(editableBefore.widget.focusNode.hasFocus, isTrue);
    final route = ModalRoute.of(tester.element(find.byType(WishEditorPage)))!
        as PageRoute<dynamic>;
    route.handleStartBackGesture(progress: 1);
    route.handleUpdateBackGestureProgress(progress: .6);
    await tester.pump();
    route.handleCancelBackGesture();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('changed without saving'), findsOneWidget);
    final editableAfter = tester.state<EditableTextState>(
        find.descendant(of: name, matching: find.byType(EditableText)));
    expect(identical(editableBefore, editableAfter), isTrue);
    expect(editableAfter.widget.focusNode.hasFocus, isTrue);
  });

  testWidgets('asset editor opens and returns to the same detail',
      (tester) async {
    final store = _store();
    final asset = store.assets.firstWhere((item) => !item.isPriceless);
    await tester
        .pumpWidget(_harness(store, AssetGridCard(asset: asset, store: store)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(
        tester.getTopLeft(find.byType(AssetGridCard)) + const Offset(30, 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byIcon(Icons.edit_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AssetEditorPage), findsOneWidget);
    Navigator.of(tester.element(find.byType(AssetEditorPage))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AssetDetailPage), findsOneWidget);
  });

  testWidgets('return remains usable if the source card disappears',
      (tester) async {
    final store = _store();
    final asset = store.assets.firstWhere((item) => !item.isPriceless);
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    await tester.pumpWidget(_harness(
      store,
      ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (_, show, __) => show
            ? AssetGridCard(asset: asset, store: store)
            : const Text('Source removed'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(
        tester.getTopLeft(find.byType(AssetGridCard)) + const Offset(30, 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    visible.value = false;
    await tester.pump();
    Navigator.of(tester.element(find.byType(AssetDetailPage))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Source removed'), findsOneWidget);
  });

  testWidgets('quick return during the opening transition remains usable',
      (tester) async {
    final store = _store();
    final asset = store.assets.firstWhere((item) => !item.isPriceless);
    await tester
        .pumpWidget(_harness(store, AssetGridCard(asset: asset, store: store)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(
        tester.getTopLeft(find.byType(AssetGridCard)) + const Offset(30, 30));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    Navigator.of(tester.element(find.byType(AssetDetailPage))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AssetGridCard), findsOneWidget);
  });

  testWidgets('chart opens its matching sheet and returns', (tester) async {
    final store = _store();
    await tester.pumpWidget(_harness(
      store,
      ChartPanel(
        title: 'Test trend',
        subtitle: 'Summary',
        onTap: (context) => appSheet(context,
            title: 'Trend details',
            subtitle: 'Details',
            child: const Text('Chart explanation')),
        child: const SizedBox(height: 60),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Test trend'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Chart explanation'), findsOneWidget);
    Navigator.of(tester.element(find.text('Chart explanation'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Test trend'), findsOneWidget);
  });

  for (final mode in [MotionMode.reduced, MotionMode.off]) {
    testWidgets('$mode does not create a shared flight', (tester) async {
      final store = _store();
      store.settings = store.settings.copyWith(motionMode: mode);
      final asset = store.assets.firstWhere((item) => !item.isPriceless);
      await tester.pumpWidget(
          _harness(store, AssetGridCard(asset: asset, store: store)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Hero &&
              widget.tag == ValoraMotionTag('asset', asset.id)),
          findsNothing);
      await tester.tapAt(
          tester.getTopLeft(find.byType(AssetGridCard)) + const Offset(30, 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AssetDetailPage), findsOneWidget);
    });
  }
}

AppStore _store() {
  final store = AppStore();
  store.importMap(ValoraPerformanceDataset(scale: ValoraBenchmarkScale.small)
      .toPersistedMap());
  store.settings = store.settings.copyWith(
    glassEffectMode: GlassEffectMode.classic,
    motionMode: MotionMode.full,
    onboardingCompleted: true,
  );
  return store;
}

Type _assetType(HomeViewMode mode) => switch (mode) {
      HomeViewMode.grid => AssetGridCard,
      HomeViewMode.list => AssetListTileCard,
      HomeViewMode.sticker => AssetStickerChip,
    };

Widget _assetCard(HomeViewMode mode, Asset asset, AppStore store) =>
    switch (mode) {
      HomeViewMode.grid => AssetGridCard(asset: asset, store: store),
      HomeViewMode.list => AssetListTileCard(asset: asset, store: store),
      HomeViewMode.sticker => AssetStickerChip(asset: asset, store: store),
    };

Widget _harness(AppStore store, Widget child) => AppScope(
      store: store,
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh'), Locale('en')],
        home: Scaffold(
          body: Center(child: SizedBox(width: 320, height: 180, child: child)),
        ),
      ),
    );
