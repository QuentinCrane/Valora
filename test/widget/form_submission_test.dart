import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel('valora/local_store');
  String persistedJson = '';
  late Completer<void> saveGate;

  setUp(() {
    setActiveLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
    persistedJson = '';
    saveGate = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
      switch (call.method) {
        case 'saveJson':
          await saveGate.future;
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets('asset editor double save creates one asset', (tester) async {
    final store = _testStore();
    await tester.pumpWidget(_harness(store, const AssetEditorPage()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Camera');
    await tester.enterText(fields.at(1), '1200');
    await _tapTwice(
      tester,
      find.byWidgetPredicate((widget) =>
          widget is ValoraGlassSaveContent &&
          widget.label == tr('editor.addToAssets')),
    );
    saveGate.complete();
    await tester.pumpAndSettle();

    expect(store.assets, hasLength(1));
    expect(store.assets.single.name, 'Camera');
  });

  testWidgets('quick-create asset form saves through the shared path',
      (tester) async {
    final store = _testStore();
    await tester.pumpWidget(
        _harness(store, const ComposePage(initialTab: ComposeTab.asset)));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Desk');
    await tester.enterText(fields.at(1), '80');
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is ValoraGlassSaveContent && widget.label == tr('common.save')));
    saveGate.complete();
    await tester.pumpAndSettle();

    expect(store.assets, hasLength(1));
    expect(store.wishes, isEmpty);
  });

  testWidgets('wish editor saves through the shared path', (tester) async {
    final store = _testStore();
    await tester.pumpWidget(_harness(store, const WishEditorPage()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Lamp');
    await tester.enterText(fields.at(1), '60');
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is ValoraGlassSaveContent && widget.label == tr('wish.save')));
    saveGate.complete();
    await tester.pumpAndSettle();

    expect(store.wishes, hasLength(1));
    expect(store.wishes.single.name, 'Lamp');
  });
}

AppStore _testStore() {
  return AppStore()
    ..settings = AppSettings(
      language: AppLanguageSetting.zhHant,
      glassEffectMode: GlassEffectMode.classic,
    );
}

Widget _harness(AppStore store, Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(Brightness.light),
    locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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
    home: AppScope(store: store, child: child),
  );
}

Future<void> _tapTwice(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.tap(finder);
}
