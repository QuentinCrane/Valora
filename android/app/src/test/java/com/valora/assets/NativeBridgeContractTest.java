package com.valora.assets;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Map;

import org.junit.Test;

public class NativeBridgeContractTest {
    @Test
    public void successEnvelopeContainsProtocolAndPayload() {
        Map<String, Object> envelope = NativeBridgeContract.success("file:///tmp/image.png");

        assertEquals(1, envelope.get("protocolVersion"));
        assertEquals("success", envelope.get("status"));
        assertEquals("file:///tmp/image.png", envelope.get("data"));
    }

    @Test
    public void errorCodesAreNormalizedToStableWireNames() {
        assertEquals("cancelled", NativeBridgeContract.normalizeCode("CANCEL"));
        assertEquals("permission_denied", NativeBridgeContract.normalizeCode("security_exception"));
        assertEquals("insufficient_storage", NativeBridgeContract.normalizeCode("no_space"));
        assertEquals("processing_failed", NativeBridgeContract.normalizeCode("ocr_error"));
        assertEquals("unavailable", NativeBridgeContract.normalizeCode("native_intent_error"));
    }

    @Test
    public void errorMessagesDoNotForwardNativeExceptionDetails() {
        String message = NativeBridgeContract.safeMessage("storage_write_failed");

        assertTrue(message.contains("storage_write_failed"));
        assertFalse(message.contains("/data/user/0"));
        assertFalse(message.contains("password"));
    }
}
