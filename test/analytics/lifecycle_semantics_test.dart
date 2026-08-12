import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('service days are inclusive and stop at lifecycle end', () {
    final purchase = DateTime(2026, 8, 1);
    final retired = DateTime(2026, 8, 4);
    final asset = _asset(
      id: 'retired',
      price: 100,
      purchaseDate: purchase,
      status: AssetStatus.retired,
      retiredAt: retired,
    );

    expect(asset.serviceDaysAt(DateTime(2026, 8, 1)), 1);
    expect(asset.serviceDaysAt(DateTime(2026, 8, 3)), 3);
    expect(asset.serviceDaysAt(DateTime(2026, 8, 12)), 4);
    expect(asset.serviceDaysAt(DateTime(2026, 7, 31)), 0);
  });

  test('sold and zero-cost assets use explicit lifecycle formulas', () {
    final purchase = DateTime(2026, 8, 1);
    final sold = DateTime(2026, 8, 3);
    final asset = _asset(
      id: 'sold',
      price: 100,
      purchaseDate: purchase,
      status: AssetStatus.sold,
      soldAt: sold,
      soldPrice: 150,
    );
    final free = _asset(
      id: 'free',
      price: 0,
      purchaseDate: purchase,
    );

    expect(asset.serviceDaysAt(DateTime(2026, 8, 12)), 3);
    expect(asset.netCostAt(DateTime(2026, 8, 2)), 100);
    expect(asset.netCostAt(DateTime(2026, 8, 3)), -50);
    expect(asset.dailyCostAt(DateTime(2026, 8, 12)), closeTo(-50 / 3, 0.0001));
    expect(free.acquisitionCost, 0);
    expect(free.dailyCostAt(DateTime(2026, 8, 12)), 0);
  });

  test(
      'lifecycle net cost preserves over-recovery and allocates shared records',
      () {
    final store = AppStore();
    final purchase = DateTime(2026, 8, 1);
    store.assets.addAll([
      _asset(id: 'asset-a', price: 100, purchaseDate: purchase),
      _asset(id: 'asset-b', price: 100, purchaseDate: purchase),
    ]);
    store.recoveryRecords.add(_recovery(
      id: 'recovery-1',
      date: DateTime(2026, 8, 2),
      amount: 260,
      assetIds: const ['asset-a', 'asset-b'],
    ));

    expect(store.getAssetRecoveryIncome('asset-a'), 130);
    expect(store.getAssetRecoveryIncome('asset-b'), 130);
    expect(store.getAssetNetConsumptionAfterRecovery(store.assets[0]), -30);
    expect(store.getLifecycleRecoveredValue(), 260);
    expect(store.getLifecycleNetConsumption(), -60);
  });

  test('daily cost trend keeps the final lifecycle denominator', () {
    final today = dateOnly(DateTime.now());
    final purchase = today.subtract(const Duration(days: 10));
    final retired = today.subtract(const Duration(days: 4));
    final store = AppStore();
    store.assets.add(_asset(
      id: 'trend',
      price: 140,
      purchaseDate: purchase,
      status: AssetStatus.retired,
      retiredAt: retired,
      addons: [
        AddonItem(
          id: 'addon',
          name: 'Addon',
          price: 20,
          purchaseDate: purchase,
        ),
      ],
    ));

    final points = store.dailyCostTrend(segments: 32);

    expect(points, isNotEmpty);
    expect(points.last.value, closeTo(160 / 7, 0.0001));
  });

  test('same-day lifecycle events have deterministic ordering', () {
    final day = DateTime(2026, 8, 12);
    final store = AppStore();
    store.assets.add(_asset(
      id: 'asset-a',
      price: 100,
      purchaseDate: day,
      status: AssetStatus.sold,
      soldAt: day,
      soldPrice: 80,
    ));
    store.recoveryRecords.add(_recovery(
      id: 'recovery-a',
      date: day,
      amount: 10,
      assetIds: const ['asset-a'],
    ));

    final events = store.lifecycleEvents();

    expect(
      events.take(3).map((event) => event.sortKey),
      <String>[
        'asset:asset-a:purchase',
        'asset:asset-a:sold',
        'recovery:recovery-a',
      ],
    );
  });

  test('analytics distributions keep stable IDs when display names collide',
      () {
    final now = DateTime.now();
    final store = AppStore();
    store.categories.addAll([
      _category('category-a', 'Same name', now),
      _category('category-b', 'Same name', now),
    ]);
    store.tags.addAll([
      _tag('tag-a', 'Same tag', now),
      _tag('tag-b', 'Same tag', now),
    ]);
    store.assets.addAll([
      _asset(
        id: 'asset-a',
        price: 100,
        categoryId: 'category-a',
        tagIds: const ['tag-a'],
        purchaseDate: now,
      ),
      _asset(
        id: 'asset-b',
        price: 200,
        categoryId: 'category-b',
        tagIds: const ['tag-b'],
        purchaseDate: now,
      ),
    ]);

    expect(store.categoryDistribution().keys,
        containsAll(<String>['category-a', 'category-b']));
    expect(store.categoryDistribution(), hasLength(2));
    expect(
        store.tagDistribution().keys, containsAll(<String>['tag-a', 'tag-b']));
    expect(store.tagDistribution(), hasLength(2));
  });
}

Asset _asset({
  required String id,
  required double price,
  required DateTime purchaseDate,
  AssetStatus status = AssetStatus.serving,
  DateTime? retiredAt,
  DateTime? soldAt,
  double? soldPrice,
  String? categoryId,
  List<String> tagIds = const [],
  List<AddonItem> addons = const [],
}) {
  return Asset(
    id: id,
    name: id,
    iconValue: 'box',
    price: price,
    purchaseDate: purchaseDate,
    categoryId: categoryId,
    tagIds: tagIds,
    addons: addons,
    note: '',
    status: status,
    includeInTotal: true,
    includeInDailyCost: true,
    retiredAt: retiredAt,
    soldAt: soldAt,
    soldPrice: soldPrice,
    targetMode: TargetMode.none,
    targetDailyCost: null,
    targetDate: null,
    targetCustomDays: null,
    expiresAt: null,
    remindBeforeDays: null,
    createdAt: purchaseDate,
    updatedAt: purchaseDate,
  );
}

ValueRecoveryRecord _recovery({
  required String id,
  required DateTime date,
  required double amount,
  required List<String> assetIds,
}) {
  return ValueRecoveryRecord(
    id: id,
    title: id,
    assetIds: assetIds,
    amount: amount,
    date: date,
    note: '',
    createdAt: date,
    updatedAt: date,
  );
}

Category _category(String id, String name, DateTime now) => Category(
      id: id,
      name: name,
      icon: 'box',
      color: '#7cc6f2',
      sortOrder: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

Tag _tag(String id, String name, DateTime now) => Tag(
      id: id,
      name: name,
      color: '#7cc6f2',
      sortOrder: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
