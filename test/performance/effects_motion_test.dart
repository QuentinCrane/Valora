import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  group('motion tier resolution', () {
    test('keeps the three user-selected tiers distinct', () {
      expect(
        resolveValoraMotionTier(MotionMode.full,
            systemDisableAnimations: false),
        ValoraMotionTier.full,
      );
      expect(
        resolveValoraMotionTier(MotionMode.reduced,
            systemDisableAnimations: false),
        ValoraMotionTier.reduced,
      );
      expect(
        resolveValoraMotionTier(MotionMode.off, systemDisableAnimations: false),
        ValoraMotionTier.off,
      );
    });

    test('system reduced-motion preference has final say', () {
      expect(
        resolveValoraMotionTier(MotionMode.full, systemDisableAnimations: true),
        ValoraMotionTier.off,
      );
      expect(
        resolveValoraMotionTier(MotionMode.reduced,
            systemDisableAnimations: true),
        ValoraMotionTier.off,
      );
    });
  });

  test('motion setting survives persisted settings round trip', () {
    const settings = AppSettings(motionMode: MotionMode.reduced);
    final restored = AppSettings.fromMap(settings.toMap());
    expect(restored.motionMode, MotionMode.reduced);
  });

  testWidgets('motion off avoids scene glass and realtime capture',
      (tester) async {
    final store = AppStore()
      ..settings = const AppSettings(motionMode: MotionMode.off);
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          store: store,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) => Text(
                '${valoraUseSceneLiquidGlass(context)}|'
                '${valoraLiquidGlassRealtimeCapture(context)}',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('false|false'), findsOneWidget);
  });
}
