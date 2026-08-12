import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('valora/local_store');

  String persistedJson = '';
  String? validatedJson;
  var saveCount = 0;
  var markValidatedCount = 0;

  setUp(() {
    persistedJson = '';
    validatedJson = null;
    saveCount = 0;
    markValidatedCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'loadJson':
          return {
            'status': persistedJson.trim().isEmpty ? 'empty' : 'success',
            'json': persistedJson,
            if (validatedJson != null) 'lastValidatedJson': validatedJson,
          };
        case 'saveJson':
          saveCount += 1;
          persistedJson =
              (call.arguments as Map<Object?, Object?>)['json'] as String;
          return true;
        case 'markValidated':
          markValidatedCount += 1;
          validatedJson =
              (call.arguments as Map<Object?, Object?>)['json'] as String;
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('first install creates an empty validated snapshot', () async {
    final store = AppStore();

    final result = await store.load();

    expect(result.status, StorageLoadStatus.success);
    expect(store.storageLoadResult.status, StorageLoadStatus.success);
    expect(store.assets, isEmpty);
    expect(saveCount, 1);
    expect(markValidatedCount, 1);
    expect(store.lastValidatedSnapshot, isNotNull);
  });

  test('corrupted JSON enters recoverable mode without writing', () async {
    persistedJson = '{not valid json';
    validatedJson = '{"version":2,"assets":[]}';
    final store = AppStore();

    final result = await store.load();

    expect(result.status, StorageLoadStatus.recoverableFailure);
    expect(result.errorCode, 'storage_payload_invalid');
    expect(result.hasValidatedSnapshot, isTrue);
    expect(store.storageLoadResult.isFailure, isTrue);
    expect(store.assets, isEmpty);
    expect(saveCount, 0);
    expect(markValidatedCount, 0);
  });

  test('SQLite read exceptions enter fatal mode without writing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'loadJson') {
        throw PlatformException(
          code: 'storage_read_failed',
          message: 'database is unavailable',
        );
      }
      fail('No write should be attempted after a storage read failure');
    });
    final store = AppStore();

    final result = await store.load();

    expect(result.status, StorageLoadStatus.fatalFailure);
    expect(result.errorCode, 'storage_read_failed');
    expect(store.isStorageReadOnly, isTrue);
    expect(saveCount, 0);
    expect(markValidatedCount, 0);
  });

  test('missing storage channel enters fatal mode without writing', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'loadJson') {
        throw MissingPluginException('storage channel unavailable');
      }
      fail('No write should be attempted after a channel failure');
    });
    final store = AppStore();

    final result = await store.load();

    expect(result.status, StorageLoadStatus.fatalFailure);
    expect(result.errorCode, 'storage_channel_unavailable');
    expect(store.isStorageReadOnly, isTrue);
    expect(saveCount, 0);
    expect(markValidatedCount, 0);
  });
}
