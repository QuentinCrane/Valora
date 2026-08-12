import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings slider commits only after the drag ends',
      (tester) async {
    final committed = <double>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingSliderRow(
            icon: Icons.blur_on_rounded,
            iconBg: Colors.blue,
            label: 'Glass softness',
            description: 'Test value',
            value: .5,
            valueLabel: 'Soft',
            onChangeEnd: committed.add,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Slider)),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();
    expect(committed, isEmpty);

    await gesture.up();
    await tester.pump();
    expect(committed, hasLength(1));
    expect(committed.single, greaterThan(.5));
  });

  test('settings widget targets exclude unrelated display changes', () {
    const base = AppSettings();
    final themeTargets = widgetRefreshTargetsForSettings(
      base,
      base.copyWith(theme: ThemeSetting.dark),
    );
    expect(themeTargets, isEmpty);

    final currencyTargets = widgetRefreshTargetsForSettings(
      base,
      base.copyWith(currencyUnit: '\$'),
    );
    expect(
        currencyTargets,
        containsAll(const [
          WidgetRefreshTarget.total,
          WidgetRefreshTarget.daily,
          WidgetRefreshTarget.mini,
        ]));
    expect(currencyTargets, hasLength(3));

    final retiredTargets = widgetRefreshTargetsForSettings(
      base,
      base.copyWith(includeRetiredInTotal: false),
    );
    expect(
        retiredTargets,
        containsAll(const [
          WidgetRefreshTarget.total,
          WidgetRefreshTarget.mini,
        ]));
    expect(retiredTargets, hasLength(2));
  });
}
