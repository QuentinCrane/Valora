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

  test('decodes subject segmentation readiness as a typed status map',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getSubjectSegmentationStatus');
      return {
        'protocolVersion': 1,
        'status': 'success',
        'data': '{"status":"ready","detail":"ready","updatedAt":123}',
      };
    });

    final result = await NativeBridge.getSubjectSegmentationStatusResult();

    expect(result.isSuccess, isTrue);
    expect(result.value?['status'], 'ready');
    expect(result.value?['updatedAt'], 123);
  });

  test('sends targeted widget refreshes instead of an implicit full refresh',
      () async {
    Map<Object?, Object?>? receivedArgs;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'updateHomeWidget');
      receivedArgs = Map<Object?, Object?>.from(call.arguments as Map);
      return {
        'protocolVersion': 1,
        'status': 'success',
        'data': true,
      };
    });

    final result = await NativeBridge.updateHomeWidgetResult(
      assetCount: 1,
      wishCount: 2,
      totalAssetValue: 3,
      averageDailyCost: 4,
      currency: '¥',
      targets: const {
        WidgetRefreshTarget.total,
        WidgetRefreshTarget.mini,
      },
    );

    expect(result.isSuccess, isTrue);
    expect(receivedArgs?['targets'], containsAll(<String>['total', 'mini']));
    expect(receivedArgs?['targets'], hasLength(2));
  });

  test('decodes background native progress without requiring a known total',
      () {
    final progress = NativeOperationProgress.fromWire({
      'operationId': 'archive_import_1',
      'operation': 'archive_import',
      'status': 'running',
      'processed': 4,
      'total': -1,
      'message': 'archive media',
    });

    expect(progress.operationId, 'archive_import_1');
    expect(progress.operation, 'archive_import');
    expect(progress.processed, 4);
    expect(progress.total, -1);
    expect(progress.fraction, isNull);
    expect(progress.isTerminal, isFalse);
  });

  test('routes native progress events through the shared channel handler',
      () async {
    NativeOperationProgress? received;
    NativeBridge.listenIncomingIntents((_) {}, onProgress: (value) {
      received = value;
    });

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(
        'nativeOperationProgress',
        <String, Object>{
          'operationId': 'archive_export_1',
          'operation': 'archive_export',
          'status': 'completed',
          'processed': 1,
          'total': 1,
        },
      )),
      (_) {},
    );

    expect(received?.operationId, 'archive_export_1');
    expect(received?.isTerminal, isTrue);
    expect(received?.fraction, 1);
  });

  test('exposes cancellation through the native operation contract', () async {
    Map<Object?, Object?>? receivedArgs;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'cancelNativeOperation');
      receivedArgs = Map<Object?, Object?>.from(call.arguments as Map);
      return {
        'protocolVersion': 1,
        'status': 'success',
        'data': true,
      };
    });

    final result =
        await NativeBridge.cancelNativeOperationResult('archive_import_1');

    expect(result.isSuccess, isTrue);
    expect(result.value, isTrue);
    expect(receivedArgs?['operationId'], 'archive_import_1');
  });
}
