import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  Map<String, dynamic> fixture(String name) {
    final file = File('test/fixtures/persisted/$name.json');
    return Map<String, dynamic>.from(jsonDecode(file.readAsStringSync()));
  }

  void expectDataError(Map<String, dynamic> data, String code) {
    try {
      migratePersistedMap(data);
      fail('Expected PersistedDataException($code)');
    } on PersistedDataException catch (error) {
      expect(error.code, code);
    }
  }

  test('v1 fixture migrates and remains readable', () {
    final store = AppStore();

    store.importMap(fixture('v1'));

    expect(store.assets, isEmpty);
    final exported = store.exportMap();
    expect(exported['storageSchemaVersion'], kCurrentStorageSchemaVersion);
    expect(exported['exportSchemaVersion'], kCurrentExportSchemaVersion);
    expect(exported['appVersion'], kValoraAppVersion);
  });

  test('v2 fixture migrates and preserves same-day audit order', () {
    final store = AppStore();

    store.importMap(fixture('v2'));

    expect(store.assets, hasLength(2));
    expect(
        store.assets[1].updatedAt.isAfter(store.assets[0].updatedAt), isTrue);
    final migrated = migratePersistedMap(fixture('v2'));
    final firstAsset = (migrated['assets'] as List).first as Map;
    expect((firstAsset['updatedAt'] as String).endsWith('Z'), isTrue);
    expect(firstAsset['purchaseDate'], '2026-08-01');
  });

  test('migrating the same fixture twice is idempotent', () {
    final once = migratePersistedMap(fixture('v2'));
    final twice = migratePersistedMap(once);

    expect(jsonEncode(twice), jsonEncode(once));
  });

  test('future schema is rejected before it can replace current data', () {
    final store = AppStore();
    final before = jsonEncode(store.exportMap());

    expectDataError(fixture('future'), 'data_future_schema');
    expect(jsonEncode(store.exportMap()), before);
  });

  test('duplicate primary keys, dangling references, and unknown enums fail',
      () {
    final duplicate = fixture('v2');
    (duplicate['tags'] as List).add((duplicate['tags'] as List).first);
    expectDataError(duplicate, 'data_duplicate_primary_key');

    final dangling = fixture('v2');
    ((dangling['assets'] as List).first as Map)['categoryId'] = 'missing';
    expectDataError(dangling, 'data_invalid_reference');

    final unknownEnum = fixture('v2');
    ((unknownEnum['assets'] as List).first as Map)['status'] = 'lost';
    expectDataError(unknownEnum, 'data_invalid_enum');
  });
}
