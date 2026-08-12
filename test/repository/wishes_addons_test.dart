import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel('valora/local_store');
  var failWrites = false;
  var persistedJson = '';

  setUp(() {
    failWrites = false;
    persistedJson = '';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
      switch (call.method) {
        case 'saveJson':
          if (failWrites) {
            throw PlatformException(code: 'write_failed');
          }
          persistedJson =
              (call.arguments as Map<Object?, Object?>)['json'] as String;
          return true;
        case 'loadJson':
          return {
            'status': persistedJson.trim().isEmpty ? 'empty' : 'success',
            'json': persistedJson,
            if (persistedJson.trim().isNotEmpty)
              'lastValidatedJson': persistedJson,
          };
        case 'markValidated':
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  test('wish and addon persistence keeps order, dates, and old payloads', () {
    final first = AddonItem(
      id: 'addon-follow',
      name: 'Protection plan',
      price: 12,
      followParentPurchaseDate: true,
      includeInTotal: false,
    );
    final second = AddonItem(
      id: 'addon-date',
      name: 'Case',
      price: 30,
      purchaseDate: DateTime(2026, 8, 3),
      includeInDailyCost: false,
    );
    final wish = Wish(
      id: 'wish-round-trip',
      name: 'Camera',
      iconValue: '📷',
      expectedPrice: 1000,
      note: 'Travel',
      categoryId: 'photo',
      tagIds: const ['travel'],
      archived: false,
      convertedAt: null,
      convertedAssetId: null,
      addons: [first, second],
      createdAt: DateTime(2026, 8, 1, 9),
      updatedAt: DateTime(2026, 8, 1, 9),
    );

    final restored = Wish.fromMap(wish.toMap());
    expect(
        restored.addons.map((item) => item.id), ['addon-follow', 'addon-date']);
    expect(restored.addons.first.followParentPurchaseDate, isTrue);
    expect(restored.addons.first.includeInTotal, isFalse);
    expect(restored.addons[1].purchaseDate, DateTime(2026, 8, 3));
    expect(restored.addons[1].includeInDailyCost, isFalse);

    final legacy = Wish.fromMap({
      'id': 'legacy-wish',
      'name': 'Legacy',
      'expectedPrice': 50,
      'emoji': '✨',
      'reason': 'old payload',
      'done': true,
    });
    expect(legacy.archived, isTrue);
    expect(legacy.addons, isEmpty);
  });

  test('wish conversion preserves relationship and time fields', () async {
    final createdAt = DateTime(2026, 8, 1, 9);
    final explicitAddonDate = DateTime(2026, 8, 3);
    final wish = _wish(
      addons: [
        const AddonItem(
          id: 'follow',
          name: 'Warranty',
          price: 20,
          followParentPurchaseDate: true,
        ),
        AddonItem(
          id: 'case',
          name: 'Case',
          price: 30,
          purchaseDate: explicitAddonDate,
        ),
      ],
      createdAt: createdAt,
    );
    final store = AppStore()..wishes.add(wish);

    final assetId = await store.convertWishToAsset(wish.id);
    expect(assetId, isNotNull);
    final asset = store.assets.single;
    final convertedWish = store.wishes.single;
    expect(convertedWish.archived, isTrue);
    expect(convertedWish.convertedAssetId, asset.id);
    expect(dateOnly(convertedWish.convertedAt!), dateOnly(DateTime.now()));
    expect(asset.createdAt, createdAt);
    expect(asset.purchaseDate, explicitAddonDate);
    expect(asset.addons.map((item) => item.id), ['follow', 'case']);
    expect(asset.addons.first.followParentPurchaseDate, isTrue);
    expect(asset.addons[1].purchaseDate, explicitAddonDate);
  });

  test('failed wish conversion restores both collections', () async {
    final wish = _wish();
    final store = AppStore()..wishes.add(wish);
    final before = store.exportJson();
    failWrites = true;

    await expectLater(store.convertWishToAsset(wish.id), throwsA(anything));

    expect(store.assets, isEmpty);
    expect(store.wishes.single.toMap(), wish.toMap());
    expect(store.exportJson(), before);
  });

  test('legacy non-sold records cannot retain a stale sold price', () {
    final asset = Asset.fromMap({
      'id': 'legacy-asset',
      'name': 'Camera',
      'price': 100,
      'purchaseDate': '2026-08-01',
      'status': 'serving',
      'soldAt': '2026-08-05',
      'soldPrice': 80,
    });

    expect(asset.status, AssetStatus.serving);
    expect(asset.soldAt, isNull);
    expect(asset.soldPrice, isNull);
  });
}

Wish _wish({
  List<AddonItem> addons = const [],
  DateTime? createdAt,
}) {
  final now = createdAt ?? DateTime(2026, 8, 1, 9);
  return Wish(
    id: 'wish-convert',
    name: 'Camera',
    iconValue: '📷',
    expectedPrice: 1000,
    note: 'Travel',
    categoryId: 'photo',
    tagIds: const ['travel'],
    archived: false,
    convertedAt: null,
    convertedAssetId: null,
    addons: addons,
    createdAt: now,
    updatedAt: now,
  );
}
