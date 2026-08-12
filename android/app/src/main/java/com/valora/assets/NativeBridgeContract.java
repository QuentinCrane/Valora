package com.valora.assets;

import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

/**
 * Wire contract for the valora/native MethodChannel.
 *
 * Every native success is encoded as:
 * {"protocolVersion":1,"status":"success","data":...}
 *
 * Platform errors remain MethodChannel errors so Flutter can preserve the
 * transport-level distinction, but their code is normalized and their detail
 * is deliberately not forwarded. User-facing wording belongs to Dart.
 */
public final class NativeBridgeContract {
    public static final int PROTOCOL_VERSION = 1;
    public static final String STATUS_SUCCESS = "success";
    public static final String STATUS_CANCELLED = "cancelled";
    public static final String STATUS_ERROR = "error";

    private NativeBridgeContract() {}

    public static Map<String, Object> success(Object data) {
        final Map<String, Object> envelope = new LinkedHashMap<>();
        envelope.put("protocolVersion", PROTOCOL_VERSION);
        envelope.put("status", STATUS_SUCCESS);
        envelope.put("data", data);
        return envelope;
    }

    public static Map<String, Object> cancelled(String code) {
        final Map<String, Object> envelope = new LinkedHashMap<>();
        envelope.put("protocolVersion", PROTOCOL_VERSION);
        envelope.put("status", STATUS_CANCELLED);
        envelope.put("error", error(code == null ? "cancelled" : code));
        return envelope;
    }

    public static Map<String, Object> failure(String code) {
        final Map<String, Object> envelope = new LinkedHashMap<>();
        envelope.put("protocolVersion", PROTOCOL_VERSION);
        envelope.put("status", STATUS_ERROR);
        envelope.put("error", error(code));
        return envelope;
    }

    private static Map<String, Object> error(String code) {
        final Map<String, Object> value = new LinkedHashMap<>();
        value.put("code", normalizeCode(code));
        return value;
    }

    public static MethodChannel.Result wrap(final MethodChannel.Result delegate) {
        return new MethodChannel.Result() {
            @Override
            public void success(Object result) {
                delegate.success(NativeBridgeContract.success(result));
            }

            @Override
            public void error(String code, String message, Object details) {
                delegate.error(normalizeCode(code), safeMessage(code), null);
            }

            @Override
            public void notImplemented() {
                delegate.error("not_implemented", safeMessage("not_implemented"), null);
            }
        };
    }

    public static String normalizeCode(String rawCode) {
        final String code = rawCode == null ? "unknown" : rawCode.trim().toLowerCase(Locale.US);
        switch (code) {
            case "cancel":
            case "cancelled":
            case "canceled":
                return "cancelled";
            case "busy":
                return "busy";
            case "permission":
            case "permission_denied":
            case "security_exception":
                return "permission_denied";
            case "storage_full":
            case "no_space":
            case "insufficient_storage":
                return "insufficient_storage";
            case "format":
            case "invalid_format":
                return "invalid_format";
            case "model":
            case "model_unavailable":
                return "model_unavailable";
            case "timeout":
                return "timeout";
            case "not_implemented":
                return "not_implemented";
            case "native_intent_error":
                return "unavailable";
            case "native_result_error":
                return "native_failure";
            case "barcode_scan_error":
            case "ocr_error":
            case "cutout_error":
                return "processing_failed";
            default:
                return code.isEmpty() ? "unknown" : code;
        }
    }

    public static String safeMessage(String code) {
        // Error codes are translated by Dart. Never send exception messages,
        // local paths, account names, or server responses over the bridge.
        return "Native operation failed: " + normalizeCode(code);
    }
}
