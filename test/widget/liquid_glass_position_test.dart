import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart' as lge;
import 'package:valora_assets/main.dart';

void main() {
  testWidgets(
      'positioned glass preserves layout and passes taps between lenses',
      (tester) async {
    var first = 0;
    var second = 0;
    var background = 0;
    await tester.pumpWidget(MaterialApp(
        home: Center(
            child: SizedBox(
      width: 300,
      height: 200,
      child: Stack(children: [
        Positioned.fill(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque, onTap: () => background++)),
        ValoraPositionedGlass(
            width: 60,
            height: 40,
            position: const lge.LiquidGlassAlignPosition(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 10, top: 15)),
            style: const lge.LiquidGlassStyle(liteGlass: true),
            child: GestureDetector(
                key: const Key('first'),
                behavior: HitTestBehavior.opaque,
                onTap: () => first++)),
        ValoraPositionedGlass(
            width: 50,
            height: 40,
            position: const lge.LiquidGlassAlignPosition(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(right: 20, bottom: 10)),
            style: const lge.LiquidGlassStyle(liteGlass: true),
            child: GestureDetector(
                key: const Key('second'),
                behavior: HitTestBehavior.opaque,
                onTap: () => second++)),
      ]),
    ))));
    final origin = tester.getTopLeft(find.byType(Stack).first);
    expect(tester.getTopLeft(find.byKey(const Key('first'))) - origin,
        const Offset(10, 15));
    expect(tester.getTopLeft(find.byKey(const Key('second'))) - origin,
        const Offset(230, 150));
    await tester.tap(find.byKey(const Key('first')));
    await tester.tap(find.byKey(const Key('second')));
    await tester.tapAt(origin + const Offset(150, 100));
    expect([first, second, background], [1, 1, 1]);
  });
}
