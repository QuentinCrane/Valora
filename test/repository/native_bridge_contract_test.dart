import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('valora/native');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('unwraps the versioned success envelope', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'pickImage');
      return {
        'protocolVersion': 1,
        'status': 'success',
        'data': 'file:///private/cover.png',
      };
    });

    final result = await NativeBridge.pickImageResult();

    expect(result.isSuccess, isTrue);
    expect(result.value, 'file:///private/cover.png');
  });

  test('maps an empty picker result to cancellation, not success', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) async => {
                  'protocolVersion': 1,
                  'status': 'success',
                  'data': null,
                });

    final result = await NativeBridge.pickImageResult();

    expect(result.isCancelled, isTrue);
    expect(result.isSuccess, isFalse);
    expect(result.error?.code, NativeBridgeErrorCode.cancelled);
  });

  test('maps platform errors without exposing native exception details',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(
        code: 'permission_denied',
        message: '/data/user/0/com.valora.assets/files/private-token',
      );
    });

    final result = await NativeBridge.requestNotificationPermissionResult();

    expect(result.isFailure, isTrue);
    expect(result.error?.code, NativeBridgeErrorCode.permissionDenied);
    expect(result.error?.safeDetail, isNull);
    expect(nativeBridgeErrorText(result.error),
        tr('native.error.permissionDenied'));
  });

  test('rejects a successful response with the wrong Dart type', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) async => {
                  'protocolVersion': 1,
                  'status': 'success',
                  'data': 'true',
                });

    final result = await NativeBridge.createShortcutsResult();

    expect(result.isFailure, isTrue);
    expect(result.error?.code, NativeBridgeErrorCode.invalidFormat);
  });

  test('maps stable error names independently of platform casing', () {
    expect(NativeBridgeErrorCodeX.fromWire('SECURITY_EXCEPTION'),
        NativeBridgeErrorCode.permissionDenied);
    expect(NativeBridgeErrorCodeX.fromWire('no_space'),
        NativeBridgeErrorCode.insufficientStorage);
    expect(NativeBridgeErrorCodeX.fromWire('model_unavailable'),
        NativeBridgeErrorCode.modelUnavailable);
    expect(NativeBridgeErrorCodeX.fromWire('unknown_future_code'),
        NativeBridgeErrorCode.unknown);
  });
}
