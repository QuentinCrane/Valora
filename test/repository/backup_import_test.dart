import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> fixture(String name) => Map<String, dynamic>.from(
        jsonDecode(
            File('test/fixtures/persisted/$name.json').readAsStringSync()),
      );

  test(
      'restore preflight normalizes a supported fixture without mutating state',
      () {
    final store = AppStore();
    final before = jsonEncode(store.exportMap());

    final prepared = store.prepareRestoreJson(jsonEncode(fixture('v2')));

    expect(prepared['storageSchemaVersion'], kCurrentStorageSchemaVersion);
    expect(prepared['exportSchemaVersion'], kCurrentExportSchemaVersion);
    expect(jsonEncode(store.exportMap()), before);
  });

  test(
      'invalid restore JSON is rejected before current state or storage changes',
      () async {
    final store = AppStore();
    final before = jsonEncode(store.exportMap());
    final writes = <String>[];

    final channel = const MethodChannel('valora/local_store');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'saveJson') {
        writes.add((call.arguments as Map<Object?, Object?>)['json'] as String);
        return true;
      }
      if (call.method == 'loadJson') {
        return {
          'status': 'success',
          'json': before,
          'lastValidatedJson': before
        };
      }
      if (call.method == 'markValidated') return true;
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    expect(await store.restoreFromJson('{not-json'), isFalse);
    expect(jsonEncode(store.exportMap()), before);
    expect(writes, isEmpty);
  });

  test('CSV cells neutralize formula prefixes and markdown escapes cell syntax',
      () {
    final store = AppStore();
    final now = DateTime(2026, 8, 12);
    store.assets.add(Asset(
      id: 'formula',
      name: '=1+1 | `danger`',
      iconValue: 'box',
      price: 10,
      purchaseDate: now,
      categoryId: null,
      tagIds: const [],
      addons: const [],
      note: '+payload',
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
      createdAt: now,
      updatedAt: now,
    ));

    final csv = buildAssetsCsv(store);

    expect(csv, contains("\"'=1+1 | `danger`\""));
    expect(csv, contains("\"'+payload\""));
    expect(markdownInlineText('a | `b` *c* [d]'), r'a \| \`b\` \*c\* \[d\]');
  });
}
