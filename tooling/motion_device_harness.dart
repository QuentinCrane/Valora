import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';

/// Synthetic data only. Run in an isolated Android application ID when testing.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setActiveLocale(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
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
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh'), Locale('en')],
      home: _MotionDeviceHarness(store: store),
    ),
  ));
}

class _MotionDeviceHarness extends StatefulWidget {
  final AppStore store;
  const _MotionDeviceHarness({required this.store});

  @override
  State<_MotionDeviceHarness> createState() => _MotionDeviceHarnessState();
}

class _MotionDeviceHarnessState extends State<_MotionDeviceHarness> {
  var selected = 0;

  @override
  Widget build(BuildContext context) {
    final asset = widget.store.assets.firstWhere((item) => !item.isPriceless);
    final wish = widget.store.wishes.first;
    final Widget sample = switch (selected) {
      0 => SizedBox(
          width: 180,
          height: 176,
          child: AssetGridCard(asset: asset, store: widget.store)),
      1 => AssetListTileCard(asset: asset, store: widget.store),
      2 => SizedBox(
          width: 180,
          height: 166,
          child: AssetStickerChip(asset: asset, store: widget.store)),
      3 => WishCard(wish: wish),
      _ => ChartPanel(
          title: '测试图表',
          subtitle: '合成数据',
          onTap: (context) => appSheet(context,
              title: '测试图表详情', subtitle: '合成数据', child: const Text('图表详情测试内容')),
          child: const SizedBox(height: 100, child: Center(child: Text('图表'))),
        ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Valora Motion 测试')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('独立测试数据，不读取或修改正式应用资料'),
        Wrap(spacing: 8, children: [
          ChoiceChip(
            label: const Text('经典'),
            selected: widget.store.settings.glassEffectMode ==
                GlassEffectMode.classic,
            onSelected: (_) => _updateSettings(widget.store.settings
                .copyWith(glassEffectMode: GlassEffectMode.classic)),
          ),
          ChoiceChip(
            label: const Text('液态'),
            selected:
                widget.store.settings.glassEffectMode == GlassEffectMode.liquid,
            onSelected: (_) => _updateSettings(widget.store.settings
                .copyWith(glassEffectMode: GlassEffectMode.liquid)),
          ),
          for (final mode in MotionMode.values)
            ChoiceChip(
              label: Text(mode.localizedLabel),
              selected: widget.store.settings.motionMode == mode,
              onSelected: (_) => _updateSettings(
                  widget.store.settings.copyWith(motionMode: mode)),
            ),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List<Widget>.generate(5, (index) {
            const labels = ['卡片', '列表', '便利贴', '心愿', '图表'];
            return ChoiceChip(
              label: Text(labels[index]),
              selected: selected == index,
              onSelected: (_) => setState(() => selected = index),
            );
          }),
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerLeft, child: sample),
      ]),
    );
  }

  Future<void> _updateSettings(AppSettings settings) async {
    await widget.store.updateSettings(settings);
    if (mounted) setState(() {});
  }
}
