import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';
import 'package:valora_assets/performance_dataset.dart';

// 说明：日敏感指标的按天缓存以 dateEpochDay(DateTime.now()) 为失效键。
// 仓库没有时钟注入点（fake_async 只拦截 Timer，不拦截 DateTime.now()），
// 因此“跨午夜后重算”这一分支无法在单测中驱动，只能通过
// “缓存值与逐次重算恒等”来锁定行为口径；失效键本身由实现约束保证。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ValoraPerformanceDataset smallDataset() => ValoraPerformanceDataset(
        scale: ValoraBenchmarkScale.small,
        seed: 7,
      );

  Asset pricedAsset(DateTime purchaseDate) => Asset(
        id: 'memo-asset',
        name: 'Camera',
        iconValue: '📦',
        price: 1000,
        purchaseDate: purchaseDate,
        categoryId: null,
        tagIds: const [],
        addons: const [],
        note: '',
        status: AssetStatus.serving,
        includeInTotal: true,
        includeInDailyCost: true,
        retiredAt: null,
        soldAt: null,
        soldPrice: null,
        targetMode: TargetMode.none,
        targetDailyCost: null,
        targetDate: null,
        targetCustomDays: null,
        expiresAt: null,
        remindBeforeDays: null,
        createdAt: purchaseDate,
        updatedAt: purchaseDate,
      );

  test('memoized day metrics are numerically identical to eager computation',
      () {
    final purchase = DateTime(2026, 1, 1);
    final asset = pricedAsset(purchase);

    final days = asset.serviceDays;
    expect(days, asset.serviceDaysAt(DateTime.now()));
    // 同一天内重复读取保持稳定（缓存命中且不改变口径）。
    expect(asset.serviceDays, days);
    expect(asset.dailyCost, asset.dailyCostAt(DateTime.now()));
    expect(asset.dailyCost, isNonZero);
  });

  test('copyWith produces a fresh instance without inheriting cached metrics',
      () {
    final purchase = DateTime(2026, 1, 1);
    final asset = pricedAsset(purchase);

    // 先让原实例写入当日缓存，再验证新实例不串用旧值。
    expect(asset.dailyCost, isNonZero);
    final edited = asset.copyWith(price: 2000);

    expect(edited.dailyCost, edited.dailyCostAt(DateTime.now()));
    expect(edited.dailyCost, greaterThan(asset.dailyCost));
    // 原实例不受新实例影响。
    expect(asset.dailyCost, asset.dailyCostAt(DateTime.now()));
  });

  test('empty query keeps filtering semantics identical to the eager haystack',
      () {
    final store = AppStore();
    store.importMap(smallDataset().toPersistedMap());

    final all = [...store.assets];
    final filtered = store.filteredAssets;

    expect(filtered, hasLength(all.length));
    expect(filtered.every(all.contains), isTrue);
    // 排序口径保持不变：默认按日均成本降序。
    for (var i = 1; i < filtered.length; i++) {
      expect(filtered[i - 1].dailyCost,
          greaterThanOrEqualTo(filtered[i].dailyCost));
    }
  });

  test('non-empty query still matches the name/note/category/tag haystack', () {
    final store = AppStore();
    store.importMap(smallDataset().toPersistedMap());

    final target = store.assets.first;
    // 无价资产会在 haystack 中部注入 priceless 关键词，整串 join 不稳定，
    // 因此只查询单个字段，同样能覆盖非空查询的 haystack 路径。
    store.setQuery(target.name.toLowerCase());
    expect(store.filteredAssets.map((a) => a.id), contains(target.id));

    if (target.note.isNotEmpty) {
      store.setQuery(target.note.toLowerCase());
      expect(store.filteredAssets.map((a) => a.id), contains(target.id));
    }

    if (target.tagIds.isNotEmpty) {
      store.setQuery(store.tagName(target.tagIds.first).toLowerCase());
      expect(
        store.filteredAssets.map((a) => a.id),
        contains(target.id),
      );
    }

    final categoryName = store.categoryName(target.categoryId).toLowerCase();
    if (categoryName.isNotEmpty) {
      store.setQuery(categoryName);
      expect(store.filteredAssets, isNotEmpty);
    }

    store.setQuery('');
    expect(store.filteredAssets, hasLength(store.assets.length));
  });
}
