import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/platform/native_bridge_contract.dart';

void main() {
  test('keeps widget targets and error codes stable on the wire', () {
    expect(WidgetRefreshTarget.snapshot.wireName, 'snapshot');
    expect(
        NativeBridgeErrorCode.permissionDenied.wireName, 'permission_denied');
    expect(NativeBridgeErrorCodeX.fromWire('SECURITY_EXCEPTION'),
        NativeBridgeErrorCode.permissionDenied);
    expect(NativeBridgeErrorCodeX.fromWire('future_code'),
        NativeBridgeErrorCode.unknown);
  });

  test('models native cancellation and failures without Flutter types', () {
    const cancelled = NativeBridgeResult<String>.cancelled();
    const failure = NativeBridgeResult<String>.failure(
      NativeBridgeError(NativeBridgeErrorCode.timeout),
    );

    expect(cancelled.isCancelled, isTrue);
    expect(cancelled.error?.code, NativeBridgeErrorCode.cancelled);
    expect(failure.isFailure, isTrue);
    expect(failure.error?.code, NativeBridgeErrorCode.timeout);
  });

  test('progress contract handles indeterminate and terminal work', () {
    final running = NativeOperationProgress.fromWire({
      'operationId': 'archive_1',
      'operation': 'archive_import',
      'processed': '4',
      'total': -1,
    });
    const completed = NativeOperationProgress(
      operationId: 'archive_1',
      operation: 'archive_import',
      status: 'completed',
      processed: 10,
      total: 10,
    );

    expect(running.fraction, isNull);
    expect(running.isTerminal, isFalse);
    expect(completed.fraction, 1);
    expect(completed.isTerminal, isTrue);
  });
}
