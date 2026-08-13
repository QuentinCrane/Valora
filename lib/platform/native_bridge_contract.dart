/// Pure Dart types shared by the Flutter native bridge and its callers.
///
/// MethodChannel transport and UI error presentation stay in the platform
/// adapter. These types describe only the stable wire-level contract.
library;

enum NativeBridgeStatus { success, cancelled, failure }

enum WidgetRefreshTarget {
  total,
  wish,
  daily,
  health,
  quick,
  due,
  snapshot,
  mini,
}

extension WidgetRefreshTargetX on WidgetRefreshTarget {
  String get wireName => name;
}

const Set<WidgetRefreshTarget> kAllWidgetRefreshTargets = {
  WidgetRefreshTarget.total,
  WidgetRefreshTarget.wish,
  WidgetRefreshTarget.daily,
  WidgetRefreshTarget.health,
  WidgetRefreshTarget.quick,
  WidgetRefreshTarget.due,
  WidgetRefreshTarget.snapshot,
  WidgetRefreshTarget.mini,
};

enum NativeBridgeErrorCode {
  cancelled,
  busy,
  permissionDenied,
  insufficientStorage,
  invalidFormat,
  modelUnavailable,
  timeout,
  unavailable,
  processingFailed,
  notImplemented,
  nativeFailure,
  unknown,
}

extension NativeBridgeErrorCodeX on NativeBridgeErrorCode {
  static NativeBridgeErrorCode fromWire(Object? raw) {
    switch (raw?.toString().trim().toLowerCase()) {
      case 'cancel':
      case 'cancelled':
      case 'canceled':
        return NativeBridgeErrorCode.cancelled;
      case 'busy':
        return NativeBridgeErrorCode.busy;
      case 'permission':
      case 'permission_denied':
      case 'security_exception':
        return NativeBridgeErrorCode.permissionDenied;
      case 'storage_full':
      case 'no_space':
      case 'insufficient_storage':
        return NativeBridgeErrorCode.insufficientStorage;
      case 'format':
      case 'invalid_format':
        return NativeBridgeErrorCode.invalidFormat;
      case 'model':
      case 'model_unavailable':
        return NativeBridgeErrorCode.modelUnavailable;
      case 'timeout':
        return NativeBridgeErrorCode.timeout;
      case 'not_implemented':
        return NativeBridgeErrorCode.notImplemented;
      case 'native_intent_error':
      case 'unavailable':
        return NativeBridgeErrorCode.unavailable;
      case 'barcode_scan_error':
      case 'ocr_error':
      case 'cutout_error':
      case 'archive_export_error':
      case 'archive_import_error':
      case 'archive_commit_failed':
      case 'archive_discard_failed':
      case 'archive_rollback_failed':
      case 'archive_finalize_failed':
      case 'persist_image_error':
      case 'text_import_failed':
      case 'text_export_failed':
      case 'processing_failed':
        return NativeBridgeErrorCode.processingFailed;
      case 'native_result_error':
      case 'native_failure':
        return NativeBridgeErrorCode.nativeFailure;
      default:
        return NativeBridgeErrorCode.unknown;
    }
  }

  String get wireName {
    switch (this) {
      case NativeBridgeErrorCode.cancelled:
        return 'cancelled';
      case NativeBridgeErrorCode.busy:
        return 'busy';
      case NativeBridgeErrorCode.permissionDenied:
        return 'permission_denied';
      case NativeBridgeErrorCode.insufficientStorage:
        return 'insufficient_storage';
      case NativeBridgeErrorCode.invalidFormat:
        return 'invalid_format';
      case NativeBridgeErrorCode.modelUnavailable:
        return 'model_unavailable';
      case NativeBridgeErrorCode.timeout:
        return 'timeout';
      case NativeBridgeErrorCode.unavailable:
        return 'unavailable';
      case NativeBridgeErrorCode.processingFailed:
        return 'processing_failed';
      case NativeBridgeErrorCode.notImplemented:
        return 'not_implemented';
      case NativeBridgeErrorCode.nativeFailure:
        return 'native_failure';
      case NativeBridgeErrorCode.unknown:
        return 'unknown';
    }
  }
}

class NativeBridgeError {
  final NativeBridgeErrorCode code;
  final String? safeDetail;

  const NativeBridgeError(this.code, {this.safeDetail});
}

class NativeOperationProgress {
  final String operationId;
  final String operation;
  final String status;
  final int processed;
  final int total;
  final String? message;

  const NativeOperationProgress({
    required this.operationId,
    required this.operation,
    required this.status,
    required this.processed,
    required this.total,
    this.message,
  });

  factory NativeOperationProgress.fromWire(Object? raw) {
    final map = raw is Map ? Map<Object?, Object?>.from(raw) : const {};
    int integer(Object? value, [int fallback = 0]) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return NativeOperationProgress(
      operationId: map['operationId']?.toString() ?? '',
      operation: map['operation']?.toString() ?? 'native',
      status: map['status']?.toString() ?? 'running',
      processed: integer(map['processed']),
      total: integer(map['total'], -1),
      message: map['message']?.toString(),
    );
  }

  bool get isTerminal =>
      status == 'completed' || status == 'failed' || status == 'cancelled';

  double? get fraction {
    if (total <= 0) return null;
    return (processed / total).clamp(0, 1).toDouble();
  }
}

class NativeBridgeResult<T> {
  final NativeBridgeStatus status;
  final T? value;
  final NativeBridgeError? error;

  const NativeBridgeResult._({
    required this.status,
    this.value,
    this.error,
  });

  const NativeBridgeResult.success([T? value])
      : this._(status: NativeBridgeStatus.success, value: value);

  const NativeBridgeResult.cancelled()
      : this._(
            status: NativeBridgeStatus.cancelled,
            error: const NativeBridgeError(NativeBridgeErrorCode.cancelled));

  const NativeBridgeResult.failure(NativeBridgeError error)
      : this._(status: NativeBridgeStatus.failure, error: error);

  bool get isSuccess => status == NativeBridgeStatus.success;
  bool get isCancelled => status == NativeBridgeStatus.cancelled;
  bool get isFailure => status == NativeBridgeStatus.failure;
}
