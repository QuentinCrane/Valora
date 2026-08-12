import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';
import 'package:valora_assets/performance_metrics.dart';

void main() {
  test('benchmark scales are fixed and deterministic', () {
    expect(ValoraBenchmarkScale.empty.assetCount, 0);
    expect(ValoraBenchmarkScale.small.assetCount, 50);
    expect(ValoraBenchmarkScale.medium.assetCount, 500);
    expect(ValoraBenchmarkScale.large.assetCount, 2000);
    expect(ValoraBenchmarkScale.small.mediaCount, 100);
    expect(ValoraBenchmarkScale.large.mediaCount, 500);

    final first = ValoraPerformanceDataset(
      scale: ValoraBenchmarkScale.small,
    ).toJson();
    final second = ValoraPerformanceDataset(
      scale: ValoraBenchmarkScale.small,
    ).toJson();
    expect(first, second);
    final decoded = jsonDecode(first) as Map<String, dynamic>;
    expect((decoded['assets'] as List), hasLength(50));
    expect((decoded['benchmarkMedia'] as List), hasLength(100));
  });

  test('generated data imports into the real store model', () {
    final store = AppStore();
    store.importMap(ValoraPerformanceDataset(
      scale: ValoraBenchmarkScale.small,
    ).toPersistedMap());

    expect(store.assets, hasLength(50));
    expect(store.wishes, hasLength(5));
    expect(store.categories, hasLength(8));
    expect(store.tags, hasLength(16));
    expect(
        store.assets.any((asset) => asset.status == AssetStatus.sold), isTrue);
  });

  test('archive padding reaches the requested byte budget', () {
    final json = ValoraPerformanceDataset(
      scale: ValoraBenchmarkScale.small,
    ).toJson(targetBytes: 256 * 1024);
    expect(utf8.encode(json).length, greaterThanOrEqualTo(256 * 1024));
  });

  test('benchmark summaries use nearest-rank p50 and p95', () {
    final summary = ValoraBenchmarkSummary.fromValues([1, 2, 3, 4, 5]);
    expect(summary.count, 5);
    expect(summary.p50, 3);
    expect(summary.p95, 5);
    expect(summary.max, 5);
  });
}
