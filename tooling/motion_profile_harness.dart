import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';

/// Runs synthetic asset-card round trips in an isolated profile build.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore()
    ..importMap(ValoraPerformanceDataset(scale: ValoraBenchmarkScale.small)
        .toPersistedMap());
  store.settings = store.settings.copyWith(
    glassEffectMode: GlassEffectMode.classic,
    motionMode: MotionMode.full,
    onboardingCompleted: true,
  );
  runApp(AppScope(
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
      home: _MotionProfilePage(store: store),
    ),
  ));
}

class _MotionProfilePage extends StatefulWidget {
  final AppStore store;
  const _MotionProfilePage({required this.store});

  @override
  State<_MotionProfilePage> createState() => _MotionProfilePageState();
}

class _MotionProfilePageState extends State<_MotionProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_run()));
  }

  Future<void> _run() async {
    final asset = widget.store.assets.firstWhere((item) => !item.isPriceless);
    final navigator = Navigator.of(context);
    Future<void> roundTrip() async {
      unawaited(navigator.push(valoraSharedRoute<void>(
          context, AssetDetailPage(assetId: asset.id, sharedFromHome: true))));
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      navigator.pop();
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    await Future<void>.delayed(const Duration(seconds: 3));
    for (var i = 0; i < 2; i++) {
      await roundTrip();
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    final frames = <FrameTiming>[];
    void onTimings(List<FrameTiming> batch) => frames.addAll(batch);
    WidgetsBinding.instance.addTimingsCallback(onTimings);
    for (var i = 0; i < 8; i++) {
      await roundTrip();
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    WidgetsBinding.instance.removeTimingsCallback(onTimings);

    double percentile(List<double> values) {
      if (values.isEmpty) return 0;
      values.sort();
      return values[((values.length - 1) * .95).ceil()];
    }

    final ui =
        frames.map((f) => f.buildDuration.inMicroseconds / 1000).toList();
    final raster =
        frames.map((f) => f.rasterDuration.inMicroseconds / 1000).toList();
    final span = frames.map((f) => f.totalSpan.inMicroseconds / 1000).toList();
    final result = <String, Object>{
      'scenario': 'asset_card_roundtrip',
      'run': const String.fromEnvironment('VALORA_PROFILE_RUN',
          defaultValue: 'unspecified'),
      'roundTrips': 8,
      'frames': frames.length,
      'uiP95Ms': percentile(ui),
      'rasterP95Ms': percentile(raster),
      'totalSpanP95Ms': percentile(span),
      'framesOver16_67Ms': span.where((v) => v > 16.67).length,
      'framesOver8_33Ms': span.where((v) => v > 8.33).length,
    };
    debugPrint('VALORA_MOTION_PROFILE ${jsonEncode(result)}');
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.store.assets.firstWhere((item) => !item.isPriceless);
    return Scaffold(
      appBar: AppBar(title: const Text('Valora Motion Profile')),
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 180,
          height: 176,
          child: AssetGridCard(asset: asset, store: widget.store),
        ),
      ),
    );
  }
}
