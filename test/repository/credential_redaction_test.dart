import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('valora/local_store');

  const secret = 'B04-test-password-never-exported';
  var persistedJson = '';
  String? savedUsername;
  String? savedPassword;
  var clearCount = 0;

  setUp(() {
    persistedJson = jsonEncode({
      'version': 2,
      'settings': {
        'cloudSync': {
          'provider': 'webdav',
          'serverUrl': 'https://dav.example.com/dav/',
          'username': 'legacy-user',
          'password': secret,
        },
      },
      'categories': [],
      'tags': [],
      'assets': [],
      'wishes': [],
      'recoveryRecords': [],
      'snapshots': [],
    });
    savedUsername = null;
    savedPassword = null;
    clearCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'loadJson':
          return {
            'status': persistedJson.trim().isEmpty ? 'empty' : 'success',
            'json': persistedJson,
            if (persistedJson.trim().isNotEmpty)
              'lastValidatedJson': persistedJson,
          };
        case 'loadCredentials':
          return {'status': 'empty'};
        case 'saveCredentials':
          final args = call.arguments as Map<Object?, Object?>;
          savedUsername = args['username'] as String;
          savedPassword = args['password'] as String;
          return true;
        case 'clearCredentials':
          clearCount += 1;
          return true;
        case 'saveJson':
          persistedJson =
              (call.arguments as Map<Object?, Object?>)['json'] as String;
          return true;
        case 'markValidated':
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('legacy plaintext credentials migrate to secure storage and redact JSON',
      () async {
    final store = AppStore();

    await store.load();

    expect(savedUsername, 'legacy-user');
    expect(savedPassword, secret);
    expect(store.settings.cloudSync.hasCredentials, isTrue);
    expect(persistedJson, isNot(contains(secret)));
    expect(persistedJson, isNot(contains('"password"')));
    expect(store.exportJson(), isNot(contains(secret)));
    expect(store.exportJson(), isNot(contains('"username"')));
  });

  test('clearing secure credentials keeps asset data and redacted export',
      () async {
    final store = AppStore();
    await store.load();

    await store.clearCloudCredentials();

    expect(clearCount, 1);
    expect(store.settings.cloudSync.hasCredentials, isFalse);
    expect(store.exportJson(), isNot(contains(secret)));
    expect(store.assets, isEmpty);
  });

  test('cloud settings map exposes presence only, never credential values', () {
    final settings = const CloudSyncSettings(
      provider: CloudSyncProvider.webdav,
      username: 'user',
      password: secret,
    );

    final map = settings.toMap();

    expect(map['credentialsStored'], isTrue);
    expect(map.containsKey('username'), isFalse);
    expect(map.containsKey('password'), isFalse);
  });
}
