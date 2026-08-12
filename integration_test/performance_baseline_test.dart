import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';
import 'package:valora_assets/performance_metrics.dart';

void main() {
  definePerformanceBaselineTests();
}

void definePerformanceBaselineTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel('valora/local_store');
  var persistedJson = '';
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(storageChannel, (call) async {
    switch (call.method) {
      case 'saveJson':
        persistedJson =
            (call.arguments as Map<Object?, Object?>)['json'] as String;
        return true;
      case 'loadJson':
        return {
          'status': persistedJson.trim().isEmpty ? 'empty' : 'success',
          'json': persistedJson,
          if (persistedJson.trim().isNotEmpty)
            'lastValidatedJson': persistedJson,
        };
      case 'markValidated':
        return true;
    }
    return null;
  });
  const nativeChannel = MethodChannel('valora/native');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(nativeChannel, (call) async {
    if (call.method == 'getInitialIntentInfo') {
      return <String, dynamic>{'status': 'success', 'data': ''};
    }
    return <String, dynamic>{'status': 'success', 'data': true};
  });

  testWidgets('Valora reproducible performance baseline', (tester) async {
    final records = <Map<String, dynamic>>[];
    for (final scale in _selectedScales()) {
      final dataset = ValoraPerformanceDataset(scale: scale);
      final store = AppStore();
      store.importMap(dataset.toPersistedMap());
      store.settings = store.settings.copyWith(
        onboardingCompleted: true,
        glassEffectMode: GlassEffectMode.classic,
        language: AppLanguageSetting.zhHant,
      );
      configureRuntimeSettings(store.settings);

      await _measure(
        tester,
        dataset,
        'cold_start',
        records,
        () async {
          await tester.pumpWidget(_harness(store));
          await _pumpStable(tester);
        },
      );
      await _measure(
        tester,
        dataset,
        'home_scroll_list_grid_sticker',
        records,
        () => _scrollHomeModes(tester),
      );
      await _measure(
        tester,
        dataset,
        'continuous_search_and_clear',
        records,
        () => _searchAndClear(tester),
      );
      await _measure(
        tester,
        dataset,
        'tab_round_trip_x10',
        records,
        () => _roundTripTabs(tester),
      );
      await _measure(
        tester,
        dataset,
        'analytics_and_details',
        records,
        () => _openAnalyticsAndScroll(tester),
      );
      await _measure(
        tester,
        dataset,
        'settings_slider',
        records,
        () => _dragSettingsSliders(tester),
      );
      await _measure(
        tester,
        dataset,
        'asset_edit_delete_restore_and_save',
        records,
        () => _mutateAndPersist(store),
      );
      await _measure(
        tester,
        dataset,
        'archive_import_10mb_or_100mb',
        records,
        () => _importArchive(store, dataset),
      );
      await _measure(
        tester,
        dataset,
        'sticker_preview_parameter_adjustment',
        records,
        () => _adjustStickerParameters(store),
      );
    }
    expect(records, isNotEmpty);
  });
}

List<ValoraBenchmarkScale> _selectedScales() {
  final requested = Platform.environment['VALORA_BENCHMARK_SCALE'] ?? 'small';
  if (requested == 'all') return ValoraBenchmarkScale.values;
  final selected = ValoraBenchmarkScale.values
      .where((scale) => scale.name == requested)
      .toList();
  return selected.isEmpty ? [ValoraBenchmarkScale.small] : selected;
}

Widget _harness(AppStore store) => AppScope(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale:
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          Locale('en'),
        ],
        theme: buildAppTheme(Brightness.light),
        home: const ShellPage(),
      ),
    );

Future<void> _measure(
  WidgetTester tester,
  ValoraPerformanceDataset dataset,
  String scenario,
  List<Map<String, dynamic>> records,
  Future<void> Function() action,
) async {
  final frames = <FrameTiming>[];
  final callback = frames.addAll;
  WidgetsBinding.instance.addTimingsCallback(callback);
  final beforeMemory = ProcessInfo.currentRss;
  final stopwatch = Stopwatch()..start();
  final frameworkExceptions = <String>[];
  Object? error;
  try {
    _drainFrameworkExceptions(tester, frameworkExceptions);
    await action();
    await tester.pump(const Duration(milliseconds: 200));
    _drainFrameworkExceptions(tester, frameworkExceptions);
  } catch (caught) {
    error = caught;
  } finally {
    _drainFrameworkExceptions(tester, frameworkExceptions);
    stopwatch.stop();
    WidgetsBinding.instance.removeTimingsCallback(callback);
  }
  final afterMemory = ProcessInfo.currentRss;
  final ui = frames
      .map((timing) => timing.buildDuration.inMicroseconds / 1000)
      .toList();
  final raster = frames
      .map((timing) => timing.rasterDuration.inMicroseconds / 1000)
      .toList();
  final missed = frames
      .where((timing) =>
          timing.buildDuration.inMicroseconds > 16667 ||
          timing.rasterDuration.inMicroseconds > 16667)
      .length;
  final record = ValoraBenchmarkRecord(
    scenario: scenario,
    dataset: dataset.scale.name,
    metrics: {
      'wall_ms': ValoraBenchmarkSummary.fromValues(
          [stopwatch.elapsedMicroseconds / 1000]),
      'ui_ms': ValoraBenchmarkSummary.fromValues(ui),
      'raster_ms': ValoraBenchmarkSummary.fromValues(raster),
    },
    counters: {
      'frameCount': frames.length,
      'missedFrameBudget': missed,
      'memoryBeforeMb': beforeMemory / (1024 * 1024),
      'memoryAfterMb': afterMemory / (1024 * 1024),
      'buildLayoutPaint': 'timeline_required_for_breakdown',
      'gc': 'timeline_required_for_breakdown',
      'frameworkExceptionCount': frameworkExceptions.length,
      if (frameworkExceptions.isNotEmpty)
        'frameworkExceptions': frameworkExceptions,
      if (error != null) 'error': error.toString(),
    },
  );
  final map = record.toMap();
  records.add(map);
  // JSONL output is intentionally easy to pipe into performance_report.dart.
  // ignore: avoid_print
  print(jsonEncode(map));
}

void _drainFrameworkExceptions(
  WidgetTester tester,
  List<String> destination,
) {
  for (var index = 0; index < 64; index++) {
    final exception = tester.takeException();
    if (exception == null) return;
    final summary = exception.toString().split('\n').first.trim();
    destination.add(summary);
  }
}

Future<void> _scrollHomeModes(WidgetTester tester) async {
  for (final mode in [
    'HomeViewMode.grid',
    'HomeViewMode.list',
    'HomeViewMode.sticker',
  ]) {
    final filter = find.byIcon(Icons.keyboard_arrow_down_rounded).first;
    if (filter.evaluate().isEmpty) continue;
    await tester.tap(filter);
    await _pumpStable(tester);
    final choice = find.text(tr(mode));
    if (choice.evaluate().isNotEmpty) await tester.tap(choice.last);
    final done = find.text(tr('common.done'));
    if (done.evaluate().isNotEmpty) await tester.tap(done.last);
    await _pumpStable(tester);
    for (var index = 0; index < 6; index++) {
      final scrollable = find.byType(Scrollable).first;
      if (scrollable.evaluate().isEmpty) break;
      await tester.fling(
        scrollable,
        const Offset(0, -480),
        1000,
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 80));
    }
  }
}

Future<void> _pumpStable(WidgetTester tester, {int frames = 4}) async {
  for (var index = 0; index < frames; index++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> _searchAndClear(WidgetTester tester) async {
  final search = find.byIcon(Icons.search_rounded).first;
  if (search.evaluate().isEmpty) return;
  await tester.tap(search);
  await _pumpStable(tester);
  final field = find.byType(TextField).last;
  if (field.evaluate().isNotEmpty) {
    await tester.enterText(field, 'benchmark');
    await tester.enterText(field, 'benchmark asset 1');
  }
  final clear = find.text(tr('home.clearSearch'));
  if (clear.evaluate().isNotEmpty) await tester.tap(clear);
  final done = find.text(tr('common.done'));
  if (done.evaluate().isNotEmpty) await tester.tap(done.last);
  await _pumpStable(tester);
}

Future<void> _roundTripTabs(WidgetTester tester) async {
  final icons = [
    Icons.shopping_bag_rounded,
    Icons.pie_chart_rounded,
    Icons.settings_rounded,
    Icons.home_rounded,
  ];
  for (var cycle = 0; cycle < 10; cycle++) {
    for (final icon in icons) {
      final finder = find.byIcon(icon).last;
      if (finder.evaluate().isEmpty) continue;
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 90));
    }
  }
  await _pumpStable(tester);
}

Future<void> _openAnalyticsAndScroll(WidgetTester tester) async {
  final analytics = find.byIcon(Icons.pie_chart_rounded).last;
  if (analytics.evaluate().isEmpty) return;
  await tester.tap(analytics);
  await _pumpStable(tester);
  for (var index = 0; index < 8; index++) {
    final scrollable = find.byType(Scrollable).last;
    if (scrollable.evaluate().isEmpty) break;
    await tester.fling(
      scrollable,
      const Offset(0, -420),
      900,
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  final home = find.byIcon(Icons.home_rounded).last;
  if (home.evaluate().isNotEmpty) await tester.tap(home);
  await _pumpStable(tester);
}

Future<void> _dragSettingsSliders(WidgetTester tester) async {
  final settings = find.byIcon(Icons.settings_rounded).last;
  if (settings.evaluate().isEmpty) return;
  await tester.tap(settings);
  await _pumpStable(tester);
  for (final slider in find.byType(Slider).evaluate()) {
    await tester.drag(find.byWidget(slider.widget), const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 60));
  }
  final home = find.byIcon(Icons.home_rounded).last;
  if (home.evaluate().isNotEmpty) await tester.tap(home);
  await _pumpStable(tester);
}

Future<void> _mutateAndPersist(AppStore store) async {
  if (store.assets.isNotEmpty) {
    final original = store.assets.first;
    await store.upsertAsset(original.copyWith(name: '${original.name} edited'));
    await store.deleteAssetWithUndo(original.id);
    await store.undoLastAction();
  }
  await store.save();
}

Future<void> _importArchive(
    AppStore store, ValoraPerformanceDataset dataset) async {
  final json = dataset.toJson(
      targetBytes: dataset.scale.archiveTargetBytes ?? 10 * 1024 * 1024);
  store.importMap(Map<String, dynamic>.from(jsonDecode(json) as Map));
}

Future<void> _adjustStickerParameters(AppStore store) async {
  for (var index = 0; index < 80; index++) {
    store.settings = store.settings.copyWith(
        liquidGlassSoftness: (index % 100) / 100,
        homeMetaFontScale: 1 + (index % 10) / 100);
    store.notifyListeners();
  }
}
