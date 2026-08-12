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

  test('asset delete undo restores every linked relationship exactly',
      () async {
    final store = AppStore();
    final now = DateTime(2026, 8, 13);
    store.categories.add(_category(now));
    store.tags.add(_tag(now));
    store.assets.add(_asset(now));
    store.wishes.add(Wish(
      id: 'wish',
      name: 'Converted wish',
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
      title: 'Resale',
      assetIds: const ['asset'],
      amount: 20,
      date: now,
      note: '',
      createdAt: now,
      updatedAt: now,
    ));
    final before = store.exportJson();

    expect(store.assetDeleteImpact('asset').affectedWishes, 1);
    expect(store.assetDeleteImpact('asset').affectedRecoveryRecords, 1);
    expect(await store.deleteAssetWithUndo('asset'), isTrue);
    expect(store.assets, isEmpty);
    expect(store.wishes.single.convertedAssetId, isNull);
    expect(store.recoveryRecords, isEmpty);
    expect(store.canUndo, isTrue);

    expect(await store.undoLastAction(), isTrue);
    expect(store.exportJson(), before);
    expect(store.wishes.single.convertedAssetId, 'asset');
    expect(store.wishes.single.archived, isTrue);
    expect(store.recoveryRecords.single.assetIds, ['asset']);
    expect(store.canUndo, isFalse);
    expect(await store.undoLastAction(), isFalse);
  });

  test('repeated destructive requests commit only once', () async {
    final store = AppStore()..assets.add(_asset(DateTime(2026, 8, 13)));
    final results = await Future.wait([
      store.deleteAssetWithUndo('asset'),
      store.deleteAssetWithUndo('asset'),
    ]);

    expect(results.where((value) => value), hasLength(1));
    expect(store.assets, isEmpty);
  });

  test('restore creates a pre-restore snapshot and preserves snapshot history',
      () async {
    final store = AppStore()
      ..categories.add(_category(DateTime(2026, 8, 12)))
      ..tags.add(_tag(DateTime(2026, 8, 12)))
      ..assets.add(_asset(DateTime(2026, 8, 12)));
    final incoming = AppStore()
      ..categories.add(_category(DateTime(2026, 8, 13)))
      ..tags.add(_tag(DateTime(2026, 8, 13)))
      ..assets.add(_asset(DateTime(2026, 8, 13), id: 'incoming'));

    final restored = await store.restoreFromJson(
      incoming.exportJson(includeSnapshots: false),
      createPreRestoreSnapshot: true,
    );

    expect(restored, isTrue);
    expect(store.assets.single.id, 'incoming');
    expect(store.snapshots, hasLength(1));
    expect(store.snapshotPreview(store.snapshots.single).isValid, isTrue);
    expect(store.snapshotPreview(store.snapshots.single).assets, 1);
  });
}

Category _category(DateTime now) => Category(
      id: 'category',
      name: 'Category',
      icon: 'box',
      color: '#000000',
      sortOrder: 0,
      createdAt: dateTimeStorageText(now),
      updatedAt: dateTimeStorageText(now),
    );

Tag _tag(DateTime now) => Tag(
      id: 'tag',
      name: 'Tag',
      color: '#000000',
      sortOrder: 0,
      createdAt: dateTimeStorageText(now),
      updatedAt: dateTimeStorageText(now),
    );

Asset _asset(DateTime purchaseDate, {String id = 'asset'}) => Asset(
      id: id,
      name: id,
      iconValue: 'box',
      price: 100,
      purchaseDate: purchaseDate,
      categoryId: 'category',
      tagIds: const ['tag'],
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
