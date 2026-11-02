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
    var activated = false;
    await tester.pumpWidget(_harness(
      store,
      ChartPanel(
        title: 'Test trend',
        subtitle: 'Summary',
        onTap: (context) => appSheet(context,
            title: 'Trend details',
            subtitle: 'Details',
            child: TextButton(
                onPressed: () => activated = true,
                child: const Text('Chart explanation'))),
        child: const SizedBox(height: 60),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Test trend'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tap(find.text('Chart explanation'), warnIfMissed: false);
    expect(activated, isFalse);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Chart explanation'), findsOneWidget);
    await tester.tap(find.text('Chart explanation'));
    expect(activated, isTrue);
    Navigator.of(tester.element(find.text('Chart explanation'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Test trend'), findsOneWidget);
  });

  for (final scenario in <String, void Function(BuildContext, AppStore)>{
    'service duration': showServiceDurationDetail,
    'daily cost ranking': showDailyCostRankingDetail,
    'value quadrant': showValueQuadrantDetail,
  }.entries) {
    testWidgets('${scenario.key} asset returns to the chart details',
        (tester) async {
      final store = _store();
      await tester.pumpWidget(_harness(
        store,
        ChartPanel(
          title: 'Source chart',
          subtitle: 'Summary',
          onTap: (context) => scenario.value(context, store),
          child: const SizedBox(height: 60),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Source chart'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final row = find.byType(ListTile).first;
      expect(row, findsOneWidget);
      await tester.ensureVisible(row);
      await tester.pump();
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AssetDetailPage), findsOneWidget);

      Navigator.of(tester.element(find.byType(AssetDetailPage))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ListTile), findsWidgets);
      Navigator.of(tester.element(find.byType(ListTile).first)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Source chart'), findsOneWidget);
    });
  }

  testWidgets('asset metadata opens and returns without nesting Heroes',
      (tester) async {
    final store = _store();
    final asset = store.assets.firstWhere((item) => !item.isPriceless);
    await tester
        .pumpWidget(_harness(store, AssetGridCard(asset: asset, store: store)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byType(HomeAssetMetaLine));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tr('home.durationDetail')), findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Hero && widget.tag == ValoraMotionTag('asset', asset.id)),
        findsOneWidget);
    Navigator.of(tester.element(find.text(tr('home.durationDetail')))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(AssetGridCard), findsOneWidget);
  });

  testWidgets('select field morphs into its options and applies a choice',
      (tester) async {
    final store = _store();
    var selected = 'first';
    await tester.pumpWidget(_harness(
      store,
      RoundedSelectField<String>(
        label: 'Choose value',
        value: selected,
        options: const [
          SelectOption(value: 'first', label: 'First option'),
          SelectOption(value: 'second', label: 'Second option'),
        ],
        onChanged: (value) => selected = value,
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    final source = find.ancestor(
        of: find.byType(RoundedSelectField<String>),
        matching: find.byType(Hero));
    expect(source, findsNothing);
    final hero = find.descendant(
        of: find.byType(RoundedSelectField<String>),
        matching: find.byType(Hero));
    final tag = tester.widget<Hero>(hero).tag;
    await tester.tap(find.byType(RoundedSelectField<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byWidgetPredicate((w) => w is Hero && w.tag == tag),
        findsOneWidget);
    await tester.tap(find.text('Second option'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(selected, 'second');
    expect(find.byType(RoundedSelectField<String>), findsOneWidget);
  });

  testWidgets('home sort button opens its matching sheet and returns',
      (tester) async {
    final store = _store();
    await tester.pumpWidget(_harness(store, StatusAndViewRow(store: store)));
    await tester.pump(const Duration(milliseconds: 400));
    final button = find.byIcon(Icons.sort_rounded);
    final source = find.ancestor(of: button, matching: find.byType(Hero));
    final tag = tester.widget<Hero>(source).tag;
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tr('home.sortAndDisplayStyle')), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Hero && w.tag == tag),
        findsOneWidget);
    Navigator.of(tester.element(find.text(tr('home.sortAndDisplayStyle'))))
        .pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
  });

  testWidgets('settings group and manager return to their tapped rows',
      (tester) async {
    final store = _store();
    setActiveLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
    await tester.pumpWidget(
        _pageHarness(store, const Scaffold(body: SettingsHomePage())));
    await tester.pump(const Duration(milliseconds: 400));
    final group = find.text(tr('settings.dataBackup'));
    await tester.scrollUntilVisible(group, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();
    await tester.tap(group);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byWidgetPredicate((w) => w is SettingsHomePage && w.asSubPage),
        findsOneWidget);
    final manager = find.text(tr('settings.categoryManage'));
    await tester.scrollUntilVisible(manager, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();
    await tester.tap(manager);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tr('settings.categoryManage')), findsWidgets);
    final category = find.descendant(
        of: find.byType(CategoryManager),
        matching: find.text(store.categoryName(store.categories.first.id)));
    await tester.scrollUntilVisible(category, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();
    await tester.tap(category);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tl('编辑分类')), findsWidgets);
    Navigator.of(tester.element(find.text(tl('编辑分类')).first)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CategoryManager), findsOneWidget);
    Navigator.of(tester.element(find.text(tr('settings.categoryManage')).first))
        .pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byWidgetPredicate((w) => w is SettingsHomePage && w.asSubPage),
        findsOneWidget);
    Navigator.of(tester.element(find.byType(SettingsHomePage))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tr('settings.dataBackup')), findsOneWidget);
  });

  testWidgets('compose category row opens and returns to the form',
      (tester) async {
    final store = _store();
    setActiveLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
    await tester.pumpWidget(
        _pageHarness(store, const ComposePage(initialTab: ComposeTab.asset)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextFormField).first, 'draft asset');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    final category = find.text(tr('compose.category'));
    await tester.scrollUntilVisible(category, 200,
        scrollable: find.byType(Scrollable).first);
    await Scrollable.ensureVisible(tester.element(category), alignment: .5);
    await tester.pump();
    await tester.tap(category);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(tr('compose.selectCategory')), findsOneWidget);
    Navigator.of(tester.element(find.text(tr('compose.selectCategory')))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ComposePage), findsOneWidget);
    expect(find.text('draft asset'), findsOneWidget);
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

    testWidgets('$mode keeps small selection controls usable', (tester) async {
      final store = _store();
      store.settings = store.settings.copyWith(motionMode: mode);
      var selected = 'first';
      await tester.pumpWidget(_harness(
        store,
        RoundedSelectField<String>(
          label: 'Choose value',
          value: selected,
          options: const [
            SelectOption(value: 'first', label: 'First option'),
            SelectOption(value: 'second', label: 'Second option'),
          ],
          onChanged: (value) => selected = value,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(Hero), findsNothing);
      await tester.tap(find.byType(RoundedSelectField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Second option'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(selected, 'second');
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

Widget _pageHarness(AppStore store, Widget child) => AppScope(
      store: store,
      child: MaterialApp(
        locale: const Locale('zh'),
        theme: buildAppTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh'), Locale('en')],
        home: child,
      ),
    );
