import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel('valora/local_store');
  String persistedJson = '';

  setUp(() {
    persistedJson = '';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
      switch (call.method) {
        case 'saveJson':
          persistedJson =
              (call.arguments as Map<Object?, Object?>)['json'] as String;
          return true;
        case 'loadJson':
          return persistedJson;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  test('asInt rounds decimals instead of removing the decimal separator', () {
    expect(asInt('1.5'), 2);
    expect(asInt('1,000'), 1000);
    expect(asInt('not a number', fallback: 7), 7);
    expect(parseUserDouble('¥ 1,234.5 元'), 1234.5);
    expect(parseUserDouble('12abc'), isNull);
  });

  test('asset value trend stays ordered and observes lifecycle dates', () {
    final store = AppStore();
    store.settings = store.settings.copyWith(includeRetiredInTotal: false);
    final today = dateOnly(DateTime.now());
    final purchaseDate = today.subtract(const Duration(days: 10));
    store.assets.add(_asset(
      id: 'retired',
      purchaseDate: purchaseDate,
      status: AssetStatus.retired,
      retiredAt: today.subtract(const Duration(days: 5)),
    ));

    final points = store.assetValueTrend();
    final expectedOffsets = [0, 1, 3, 4, 6, 7, 9, 10];
    expect(
      points.map((point) => point.label),
      expectedOffsets.map((offset) {
        final date = purchaseDate.add(Duration(days: offset));
        return '${date.month}/${date.day}';
      }),
    );
    expect(points.first.value, 100);
    expect(points.last.value, 0);
  });

  test('deleting referenced records removes dangling relationships', () async {
    final store = AppStore();
    final now = DateTime.now();
    store.categories.add(Category(
      id: 'category',
      name: 'Category',
      icon: 'box',
      color: '#000000',
      sortOrder: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    ));
    store.tags.add(Tag(
      id: 'tag',
      name: 'Tag',
      color: '#000000',
      sortOrder: 0,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    ));
    store.assets.add(_asset(
      id: 'asset',
      purchaseDate: now,
      categoryId: 'category',
      tagIds: const ['tag'],
    ));
    store.wishes.add(Wish(
      id: 'wish',
      name: 'Wish',
      iconValue: 'star',
      expectedPrice: 100,
      note: '',
      categoryId: 'category',
      tagIds: const ['tag'],
      archived: true,
      convertedAt: now,
      convertedAssetId: 'asset',
      addons: const [],
      createdAt: now,
      updatedAt: now,
    ));
    store.recoveryRecords.add(ValueRecoveryRecord(
      id: 'recovery',
      title: 'Recovery',
      assetIds: const ['asset'],
      amount: 25,
      date: now,
      note: '',
      createdAt: now,
      updatedAt: now,
    ));

    await store.deleteCategory('category');
    await store.deleteTag('tag');
    await store.deleteAsset('asset');

    expect(store.wishes.single.categoryId, isNull);
    expect(store.wishes.single.tagIds, isEmpty);
    expect(store.wishes.single.archived, isFalse);
    expect(store.wishes.single.convertedAt, isNull);
    expect(store.wishes.single.convertedAssetId, isNull);
    expect(store.recoveryRecords, isEmpty);
  });
}

Asset _asset({
  required String id,
  required DateTime purchaseDate,
  String? categoryId,
  List<String> tagIds = const [],
  AssetStatus status = AssetStatus.serving,
  DateTime? retiredAt,
}) {
  return Asset(
    id: id,
    name: id,
    iconValue: 'box',
    price: 100,
    purchaseDate: purchaseDate,
    categoryId: categoryId,
    tagIds: tagIds,
    addons: const [],
    note: '',
    status: status,
    includeInTotal: true,
    includeInDailyCost: true,
    retiredAt: retiredAt,
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
}
