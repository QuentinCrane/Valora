import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('destructive sheet is readable and cancel leaves the action idle',
      (tester) async {
    setActiveLocale(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
    bool? confirmed;
    await tester.pumpWidget(_harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            confirmed = await showDestructiveActionSheet(
              context,
              title: '删除资产',
              message: '确认删除「Camera」吗？',
              impactSummary: '目标 1 项 · 资产 1 项',
              actionLabel: '删除',
            );
          },
          child: const Text('Open'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text(tr('destructive.impact')), findsOneWidget);
    expect(find.text(tr('destructive.cancelNoChange')), findsOneWidget);
    expect(find.bySemanticsLabel('删除资产'), findsWidgets);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
    expect(find.text(tr('destructive.impact')), findsNothing);
  });
}

Widget _harness(Widget child) => MaterialApp(
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
      home: Scaffold(body: Center(child: child)),
    );
