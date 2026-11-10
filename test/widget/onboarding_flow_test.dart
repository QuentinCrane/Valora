import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel('valora/local_store');
  const nativeChannel = MethodChannel('valora/native');
  String persistedJson = '';

  setUp(() {
    persistedJson = '';
    // Fast-fail every native bridge call: without a handler the test
    // messenger never replies and each call waits out its 30s timeout.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, (call) async => null);
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
    TestWidgetsFlutterBinding.instance.platformDispatcher.localesTestValue = [
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    ];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(nativeChannel, null);
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocalesTestValue();
  });

  Map<String, dynamic> persistedSettings() =>
      ((jsonDecode(persistedJson) as Map<String, dynamic>)['settings']
          as Map<String, dynamic>);

  /// The shell runs continuous liquid-glass animations, so tests must never
  /// pumpAndSettle once it is mounted; pump fixed durations instead.
  Future<void> pumpWelcomeFlow(WidgetTester tester) async {
    await tester.pumpWidget(const ValoraApp());
    await tester.pumpAndSettle();
  }

  void usePhoneSurface(WidgetTester tester) {
    // The default 800x600 test surface makes the real home cards overflow;
    // the app targets phone screens, so emulate one.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpPastWelcomeCompletion(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('fresh install lands on the welcome flow first', (tester) async {
    await pumpWelcomeFlow(tester);

    expect(find.text(tr('onboarding.welcome.title')), findsOneWidget);
    expect(find.text(tr('onboarding.skip')), findsOneWidget);
    expect(find.byType(OnboardingFlowPage), findsOneWidget);
    expect(find.byType(ShellPage), findsNothing);
  });

  testWidgets('welcome pages expose brand, concept and features',
      (tester) async {
    await pumpWelcomeFlow(tester);

    expect(find.text(tr('onboarding.welcome.slogan')), findsOneWidget);
    expect(find.byIcon(Icons.verified_user_rounded), findsOneWidget);

    await tester.tap(find.text(tr('onboarding.next')));
    await tester.pumpAndSettle();
    expect(find.text(tr('onboarding.concept.title')), findsOneWidget);

    await tester.tap(find.text(tr('onboarding.next')));
    await tester.pumpAndSettle();
    expect(find.text(tr('onboarding.features.assets')), findsOneWidget);
    expect(find.text(tr('onboarding.features.analytics')), findsOneWidget);
    expect(find.text(tr('onboarding.start')), findsOneWidget);
  });

  testWidgets('completing the flow lands on the shell with the tutorial prompt',
      (tester) async {
    await pumpWelcomeFlow(tester);

    await tester.tap(find.text(tr('onboarding.next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('onboarding.next')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('onboarding.start')));
    await pumpPastWelcomeCompletion(tester);

    expect(find.byType(OnboardingFlowPage), findsNothing);
    expect(find.byType(ShellPage), findsOneWidget);
    expect(persistedSettings()['welcomeCompleted'], true);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(tr('shell.tutorial.promptTitle')), findsOneWidget);
  });

  testWidgets('skipping the flow still marks it seen', (tester) async {
    await pumpWelcomeFlow(tester);

    await tester.tap(find.text(tr('onboarding.skip')));
    await pumpPastWelcomeCompletion(tester);

    expect(find.byType(OnboardingFlowPage), findsNothing);
    expect(find.byType(ShellPage), findsOneWidget);
    expect(persistedSettings()['welcomeCompleted'], true);
  });

  testWidgets('upgraded users with data go straight to the shell',
      (tester) async {
    usePhoneSurface(tester);
    persistedJson = jsonEncode({
      'storageSchemaVersion': 1,
      'settings': <String, dynamic>{},
      'categories': <Map<String, dynamic>>[],
      'tags': <Map<String, dynamic>>[],
      'assets': <Map<String, dynamic>>[
        {
          'id': 'a1',
          'name': 'Camera',
          'price': 1200,
          'purchaseDateYmd': '2026-01-10',
        },
      ],
      'wishes': <Map<String, dynamic>>[],
    });

    await tester.pumpWidget(const ValoraApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingFlowPage), findsNothing);
    expect(find.byType(ShellPage), findsOneWidget);
  });

  testWidgets('users who already saw the flow never see it again',
      (tester) async {
    usePhoneSurface(tester);
    persistedJson = jsonEncode({
      'storageSchemaVersion': 1,
      'settings': <String, dynamic>{'welcomeCompleted': true},
      'categories': <Map<String, dynamic>>[],
      'tags': <Map<String, dynamic>>[],
      'assets': <Map<String, dynamic>>[],
      'wishes': <Map<String, dynamic>>[],
    });

    await tester.pumpWidget(const ValoraApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingFlowPage), findsNothing);
    expect(find.byType(ShellPage), findsOneWidget);
  });

  testWidgets('upgraded users with an empty store skip the welcome flow',
      (tester) async {
    usePhoneSurface(tester);
    persistedJson = jsonEncode({
      'storageSchemaVersion': 1,
      'settings': <String, dynamic>{},
      'categories': <Map<String, dynamic>>[],
      'tags': <Map<String, dynamic>>[],
      'assets': <Map<String, dynamic>>[],
      'wishes': <Map<String, dynamic>>[],
    });

    await tester.pumpWidget(const ValoraApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingFlowPage), findsNothing);
    expect(find.byType(ShellPage), findsOneWidget);
  });
}
