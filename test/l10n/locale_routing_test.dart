import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/l10n/generated/valora_localizations.dart';
import 'package:valora_assets/main.dart';

const _supportedLocales = <Locale>[
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('en'),
];

void main() {
  tearDown(() {
    setActiveLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
  });

  test('system locales resolve to the matching generated locale', () {
    final zhCn = resolveAppLocale(const Locale('zh', 'CN'), _supportedLocales);
    expect(zhCn.scriptCode, 'Hans');
    expect(tr('app.name'), '值谱');
    expect(tr('language.zhHant'), '繁体中文');

    final zhTw = resolveAppLocale(const Locale('zh', 'TW'), _supportedLocales);
    expect(zhTw.scriptCode, 'Hant');
    expect(tr('language.zhHant'), '繁體中文');

    final english =
        resolveAppLocale(const Locale('en', 'US'), _supportedLocales);
    expect(english.languageCode, 'en');
    expect(tr('app.name'), 'Valora');
    expect(tr('language.zhHans'), 'Simplified Chinese');
    expect(tl('千位分隔'), 'Thousands separator');
  });

  test('explicit language settings persist stable locale codes', () {
    expect(AppLanguageSetting.zhHans.locale?.scriptCode, 'Hans');
    expect(AppLanguageSetting.zhHant.locale?.scriptCode, 'Hant');
    expect(AppLanguageSetting.en.locale, const Locale('en'));
    expect(AppLanguageSettingX.fromValue('zhHans'), AppLanguageSetting.zhHans);
    expect(AppLanguageSettingX.fromValue('unknown'), AppLanguageSetting.system);
  });

  test('generated localization classes expose all three locale variants', () {
    final hans = lookupValoraLocalizations(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    final hant = lookupValoraLocalizations(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    final english = lookupValoraLocalizations(const Locale('en'));

    expect(hans.message_app_name, '值谱');
    expect(hant.message_app_name, '值譜');
    expect(english.message_app_name, 'Valora');
    expect(hans.message_time_day, isNotEmpty);
    expect(hant.message_time_day, isNotEmpty);
    expect(english.message_time_day, isNotEmpty);
  });

  test('date and user-configured currency formatting stay stable by locale',
      () {
    final settings = AppSettings(
      currencyUnit: '¥',
      decimalPlaces: 2,
      useThousandsSeparator: true,
    );
    for (final locale in _supportedLocales) {
      setActiveLocale(locale);
      expect(dateText(DateTime(2026, 8, 13)), '2026-08-13');
      expect(money(1234567.8, settings), '¥1,234,567.80');
      expect(tr('time.day'), isNotEmpty);
    }
  });

  testWidgets('three-language selector fits a 320dp width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 200);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AppScope(
        store: AppStore(),
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: MiniChoiceBar<AppLanguageSetting>(
                value: AppLanguageSetting.zhHans,
                values: AppLanguageSetting.values,
                labelOf: (value) => value.label,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final selector = find.byWidgetPredicate(
      (widget) => widget is MiniChoiceBar<AppLanguageSetting>,
    );
    expect(
      tester.getSize(selector).width,
      lessThanOrEqualTo(320),
    );
  });
}
