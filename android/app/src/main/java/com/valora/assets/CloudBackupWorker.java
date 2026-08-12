package com.valora.assets;

import android.content.Context;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.work.BackoffPolicy;
import androidx.work.Constraints;
import androidx.work.ExistingWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Performs the automatic backup away from the Flutter UI isolate.
 *
 * The request is deliberately unique and conditional. A background retry may
 * wait for the network, but it never turns a stale ETag into an unconditional
 * overwrite.
 */
public final class CloudBackupWorker extends Worker {
    private static final String UNIQUE_WORK_NAME = "valora-cloud-backup";
    private static final int MAX_PAYLOAD_BYTES = 10 * 1024 * 1024;
    private static final int CONNECT_TIMEOUT_MILLIS = 16000;
    private static final int READ_TIMEOUT_MILLIS = 28000;

    public CloudBackupWorker(@NonNull Context context, @NonNull WorkerParameters params) {
        super(context, params);
    }

    public static void enqueue(Context context) {
        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();
        OneTimeWorkRequest request = new OneTimeWorkRequest.Builder(CloudBackupWorker.class)
                .setConstraints(constraints)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
                .build();
        WorkManager.getInstance(context.getApplicationContext()).enqueueUniqueWork(
                UNIQUE_WORK_NAME,
                ExistingWorkPolicy.REPLACE,
                request);
    }

    @NonNull
    @Override
    public Result doWork() {
        try {
            return uploadLatestSnapshot();
        } catch (ConflictException | WorkerFailureException e) {
            return Result.failure();
        } catch (IOException e) {
            return isStopped() ? Result.failure() : Result.retry();
        } catch (Exception e) {
            return Result.failure();
        }
    }

    private Result uploadLatestSnapshot() throws Exception {
        MainActivity.LocalStoreDb database = new MainActivity.LocalStoreDb(getApplicationContext());
        String json = database.loadJson();
        if (json == null || json.trim().isEmpty()) return Result.success();

        JSONObject root = new JSONObject(json);
        JSONObject settings = root.optJSONObject("settings");
        JSONObject cloud = settings == null ? null : settings.optJSONObject("cloudSync");
        if (cloud == null) return Result.success();
        String provider = cloud.optString("provider", "off");
        String serverUrl = cloud.optString("serverUrl", "").trim();
        String remotePath = cloud.optString("remotePath", "").trim();
        if ("off".equals(provider) || "manualFile".equals(provider)
                || serverUrl.isEmpty() || remotePath.isEmpty()) {
            return Result.success();
        }

        URL url = buildUrl(serverUrl, remotePath);
        Map<String, Object> credentials = MainActivity.loadSecureCredentials(getApplicationContext());
        String username = credentials.get("username") == null
                ? "" : credentials.get("username").toString();
        String password = credentials.get("password") == null
                ? "" : credentials.get("password").toString();
        byte[] payload = json.getBytes(StandardCharsets.UTF_8);
        if (payload.length > MAX_PAYLOAD_BYTES) {
            throw new WorkerFailureException("Cloud payload exceeds the 10 MB limit");
        }
        String contentHash = sha256(payload);
        String knownHash = clean(cloud.optString("remoteContentHash", null));
        String knownEtag = clean(cloud.optString("remoteEtag", null));
        if (contentHash.equals(knownHash) && knownEtag != null) return Result.success();

        Response head = request("HEAD", url, username, password, null, null);
        boolean exists = head.statusCode >= 200 && head.statusCode < 400;
        Map<String, String> headers = new HashMap<>();
        if (exists) {
            if (knownEtag == null) throw new ConflictException();
            if (head.etag != null && !sameEtag(knownEtag, head.etag)) {
                throw new ConflictException();
            }
            headers.put("If-Match", knownEtag);
        } else if (head.statusCode == HttpURLConnection.HTTP_NOT_FOUND) {
            headers.put("If-None-Match", "*");
        } else if (knownEtag != null) {
            headers.put("If-Match", knownEtag);
        } else {
            headers.put("If-None-Match", "*");
        }

        Response put = request("PUT", url, username, password, headers, payload);
        if (put.statusCode == 409 || put.statusCode == 412) throw new ConflictException();
        if (put.statusCode == 401 || put.statusCode == 403) {
            throw new WorkerFailureException("WebDAV authentication failed");
        }
        if (put.statusCode >= 500) throw new IOException("WebDAV server error");
        if (put.statusCode < 200 || put.statusCode >= 300) {
            throw new WorkerFailureException("WebDAV upload failed");
        }

        // Do not let an older worker overwrite a newer local revision.
        if (!json.equals(database.loadJson())) return Result.success();
        String etag = clean(put.etag);
        if (etag == null) etag = clean(head.etag);
        cloud.put("remoteEtag", etag == null ? JSONObject.NULL : etag);
        cloud.put("remoteContentHash", contentHash);
        cloud.put("remoteAssetCount", arrayLength(root.optJSONArray("assets")));
        cloud.put("remoteWishCount", arrayLength(root.optJSONArray("wishes")));
        cloud.put("remoteLastModifiedAt", JSONObject.NULL);
        cloud.put("lastUploadAt", java.time.Instant.now().toString());
        String updated = root.toString();
        if (!database.saveJsonIfCurrent(json, updated)) return Result.success();
        database.markValidated(updated);
        return Result.success();
    }

    private static int arrayLength(JSONArray array) {
        return array == null ? 0 : array.length();
    }

    private static URL buildUrl(String rawServerUrl, String remotePath) throws Exception {
        URI base = URI.create(rawServerUrl.endsWith("/") ? rawServerUrl : rawServerUrl + "/");
        validateUri(base);
        String safePath = remotePath.replaceFirst("^/+", "");
        if (safePath.isEmpty() || safePath.contains("..") || safePath.contains("\\")) {
            throw new WorkerFailureException("Remote path is invalid");
        }
        URI resolved = base.resolve(safePath);
        validateUri(resolved);
        return resolved.toURL();
    }

    private static void validateUri(URI uri) throws WorkerFailureException {
        if (!"https".equalsIgnoreCase(uri.getScheme())
                || uri.getHost() == null
                || uri.getHost().trim().isEmpty()
                || uri.getUserInfo() != null
                || uri.getQuery() != null
                || uri.getFragment() != null) {
            throw new WorkerFailureException("WebDAV requires HTTPS without embedded credentials");
        }
    }

    private static Response request(String method, URL url, String username, String password,
                                    Map<String, String> headers, byte[] body) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod(method);
        connection.setConnectTimeout(CONNECT_TIMEOUT_MILLIS);
        connection.setReadTimeout(READ_TIMEOUT_MILLIS);
        connection.setInstanceFollowRedirects(false);
        connection.setRequestProperty("User-Agent", "Valora-Assets/1.0 WorkManager");
        if (!username.trim().isEmpty() || !password.isEmpty()) {
            String token = Base64.encodeToString(
                    (username.trim() + ":" + password).getBytes(StandardCharsets.UTF_8),
                    Base64.NO_WRAP);
            connection.setRequestProperty("Authorization", "Basic " + token);
        }
        if (headers != null) {
            for (Map.Entry<String, String> entry : headers.entrySet()) {
                connection.setRequestProperty(entry.getKey(), entry.getValue());
            }
        }
        if (body != null) {
            connection.setDoOutput(true);
            connection.setFixedLengthStreamingMode(body.length);
            connection.setRequestProperty("Content-Type", "application/json; charset=utf-8");
            try (OutputStream output = connection.getOutputStream()) {
                output.write(body);
            }
        }
        int status = connection.getResponseCode();
        InputStream stream = status >= 400 ? connection.getErrorStream() : connection.getInputStream();
        if (stream != null) drainLimited(stream);
        String etag = clean(connection.getHeaderField("ETag"));
        connection.disconnect();
        return new Response(status, etag);
    }

    private static void drainLimited(InputStream stream) throws IOException {
        byte[] buffer = new byte[8192];
        int total = 0;
        int read;
        try (InputStream input = stream) {
            while ((read = input.read(buffer)) != -1) {
                total += read;
                if (total > MAX_PAYLOAD_BYTES) throw new IOException("Cloud response exceeds the 10 MB limit");
            }
        }
    }

    private static String sha256(byte[] bytes) throws Exception {
        byte[] digest = MessageDigest.getInstance("SHA-256").digest(bytes);
        StringBuilder builder = new StringBuilder(digest.length * 2);
        for (byte value : digest) builder.append(String.format("%02x", value & 0xff));
        return builder.toString();
    }

    private static String clean(String value) {
        if (value == null || value.trim().isEmpty() || "null".equals(value)) return null;
        return value.trim();
    }

    private static boolean sameEtag(String left, String right) {
        return left != null && right != null && left.trim().equals(right.trim());
    }

    private static final class Response {
        final int statusCode;
        final String etag;

        Response(int statusCode, String etag) {
            this.statusCode = statusCode;
            this.etag = etag;
        }
    }

    private static final class ConflictException extends Exception {}

    private static final class WorkerFailureException extends Exception {
        WorkerFailureException(String message) {
            super(message);
        }
    }
}
