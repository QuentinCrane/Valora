package com.valora.assets;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

final class ReminderScheduler {
    static final String ACTION_REMINDER = "com.valora.assets.action.REMINDER";
    private static final String PREFS_NAME = "valora_reminders";
    private static final String KEY_SCHEDULED = "scheduled_json";
    private static final String KEY_LAST_STATUS = "last_status_json";

    private ReminderScheduler() {}

    static final class ReminderSpec {
        final String id;
        final String sourceId;
        final String type;
        final long triggerAtMillis;
        final String title;
        final String body;
        final int notificationId;

        ReminderSpec(String id, String sourceId, String type, long triggerAtMillis,
                     String title, String body) {
            this.id = id;
            this.sourceId = sourceId;
            this.type = type;
            this.triggerAtMillis = triggerAtMillis;
            this.title = title;
            this.body = body;
            this.notificationId = notificationIdFor(id);
        }

        JSONObject toJson() {
            JSONObject json = new JSONObject();
            try {
                json.put("id", id);
                json.put("sourceId", sourceId);
                json.put("type", type);
                json.put("triggerAtMillis", triggerAtMillis);
                json.put("title", title);
                json.put("body", body);
                json.put("notificationId", notificationId);
            } catch (JSONException ignored) {
                // All values above are primitive and cannot fail in practice.
            }
            return json;
        }

        static ReminderSpec fromJson(JSONObject json) {
            String id = json.optString("id", "").trim();
            if (id.isEmpty()) return null;
            long triggerAt = json.optLong("triggerAtMillis", 0L);
            if (triggerAt <= 0L) return null;
            return new ReminderSpec(
                    id,
                    json.optString("sourceId", ""),
                    json.optString("type", "asset_expiry"),
                    triggerAt,
                    json.optString("title", "Valora"),
                    json.optString("body", ""));
        }
    }

    static final class ReminderInput {
        final String id;
        final String sourceId;
        final String type;
        final String triggerDate;
        final long triggerAtMillis;
        final String title;
        final String body;
        final boolean enabled;

        ReminderInput(String id, String sourceId, String type, long triggerAtMillis,
                      String title, String body, boolean enabled) {
            this(id, sourceId, type, "", triggerAtMillis, title, body, enabled);
        }

        ReminderInput(String id, String sourceId, String type, String triggerDate,
                      long triggerAtMillis, String title, String body, boolean enabled) {
            this.id = id;
            this.sourceId = sourceId;
            this.type = type;
            this.triggerDate = triggerDate;
            this.triggerAtMillis = triggerAtMillis;
            this.title = title;
            this.body = body;
            this.enabled = enabled;
        }
    }

    static List<ReminderSpec> buildSpecs(String payload, long nowMillis)
            throws JSONException {
        if (payload == null || payload.trim().isEmpty()) {
            return new ArrayList<>();
        }
        JSONObject root = new JSONObject(payload);
        JSONObject settings = root.optJSONObject("settings");
        boolean reminderEnabled = settings != null
                && settings.optBoolean("reminderEnabled", false);
        JSONArray reminders = root.optJSONArray("reminders");
        List<ReminderInput> inputs = new ArrayList<>();
        if (reminders == null) return buildSpecs(reminderEnabled, inputs, nowMillis);
        for (int index = 0; index < reminders.length(); index++) {
            JSONObject reminder = reminders.optJSONObject(index);
            if (reminder == null) continue;
            String id = reminder.optString("id", "").trim();
            String triggerDate = reminder.optString("triggerDate", "").trim();
            String triggerText = reminder.optString("triggerAt", "").trim();
            long triggerAt = triggerDate.isEmpty()
                    ? parseIsoMillis(triggerText)
                    : parseLocalDateMillis(triggerDate, 9);
            inputs.add(new ReminderInput(
                    id,
                    reminder.optString("sourceId", ""),
                    reminder.optString("type", "asset_expiry"),
                    triggerDate,
                    triggerAt,
                    reminder.optString("title", "Valora"),
                    reminder.optString("body", ""),
                    reminder.optBoolean("enabled", false)));
        }
        return buildSpecs(reminderEnabled, inputs, nowMillis);
    }

    static List<ReminderSpec> buildSpecs(boolean reminderEnabled,
                                         List<ReminderInput> inputs,
                                         long nowMillis) {
        List<ReminderSpec> specs = new ArrayList<>();
        if (!reminderEnabled || inputs == null) return specs;
        Set<String> ids = new HashSet<>();
        for (ReminderInput input : inputs) {
            if (input == null || !input.enabled || input.id == null
                    || input.id.trim().isEmpty()
                    || input.triggerAtMillis <= nowMillis
                    || !ids.add(input.id)) continue;
            specs.add(new ReminderSpec(
                    input.id,
                    input.sourceId,
                    input.type,
                    input.triggerAtMillis,
                    input.title,
                    input.body));
        }
        return specs;
    }

    static int notificationIdFor(String reminderId) {
        int value = reminderId == null ? 1 : reminderId.hashCode() & 0x7fffffff;
        return value == 0 ? 1 : value;
    }

    static Map<String, Object> sync(Context context) {
        long now = System.currentTimeMillis();
        try {
            MainActivity.LocalStoreDb db = new MainActivity.LocalStoreDb(context);
            String payload = db.loadJson();
            db.close();
            List<ReminderSpec> desired = buildSpecs(payload, now);
            List<ReminderSpec> previous = readSpecs(context);
            AlarmManager alarm = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (alarm == null) {
                return persistStatus(context, status(false, "unavailable", 0, permissionState(context), now));
            }
            for (ReminderSpec spec : previous) cancel(context, alarm, spec);

            String permission = permissionState(context);
            if ("denied".equals(permission)) {
                return persistStatus(context, status(false, "permission_denied", 0, permission, now));
            }

            for (ReminderSpec spec : desired) schedule(context, alarm, spec);
            saveSpecs(context, desired);
            String result = desired.isEmpty()
                    ? (isReminderEnabled(payload) ? "no_reminders" : "disabled")
                    : "scheduled";
            return persistStatus(context,
                    status(true, result, desired.size(), permission, now));
        } catch (Exception error) {
            return persistStatus(context,
                    status(false, "invalid_format", 0, permissionState(context), now));
        }
    }

    static Map<String, Object> status(Context context) {
        Map<String, Object> result = new LinkedHashMap<>();
        String raw = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_LAST_STATUS, "");
        if (raw != null && !raw.trim().isEmpty()) {
            try {
                JSONObject json = new JSONObject(raw);
                result.put("ok", json.optBoolean("ok", false));
                result.put("result", json.optString("result", "pending"));
                result.put("scheduledCount", json.optInt("scheduledCount", 0));
                result.put("permissionState", json.optString("permissionState", permissionState(context)));
                result.put("lastSyncAtMillis", json.optLong("lastSyncAtMillis", 0L));
                return result;
            } catch (JSONException ignored) {
                // Fall through to a safe pending status.
            }
        }
        return status(false, "pending", 0, permissionState(context), 0L);
    }

    private static boolean isReminderEnabled(String payload) {
        if (payload == null || payload.trim().isEmpty()) return false;
        try {
            JSONObject settings = new JSONObject(payload).optJSONObject("settings");
            return settings != null && settings.optBoolean("reminderEnabled", false);
        } catch (JSONException ignored) {
            return false;
        }
    }

    private static Map<String, Object> status(boolean ok, String result,
                                              int scheduledCount,
                                              String permissionState,
                                              long nowMillis) {
        Map<String, Object> value = new LinkedHashMap<>();
        value.put("ok", ok);
        value.put("result", result);
        value.put("scheduledCount", scheduledCount);
        value.put("permissionState", permissionState);
        value.put("lastSyncAtMillis", nowMillis);
        return value;
    }

    private static Map<String, Object> persistStatus(Context context,
                                                      Map<String, Object> value) {
        JSONObject json = new JSONObject(value);
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_LAST_STATUS, json.toString())
                .apply();
        return value;
    }

    private static String permissionState(Context context) {
        if (Build.VERSION.SDK_INT < 24) return "not_required";
        NotificationManager manager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        if (manager == null || !manager.areNotificationsEnabled()) return "denied";
        return Build.VERSION.SDK_INT >= 33 ? "granted" : "not_required";
    }

    private static List<ReminderSpec> readSpecs(Context context) {
        List<ReminderSpec> specs = new ArrayList<>();
        String raw = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_SCHEDULED, "[]");
        try {
            JSONArray array = new JSONArray(raw == null ? "[]" : raw);
            for (int index = 0; index < array.length(); index++) {
                JSONObject json = array.optJSONObject(index);
                ReminderSpec spec = json == null ? null : ReminderSpec.fromJson(json);
                if (spec != null) specs.add(spec);
            }
        } catch (JSONException ignored) {
            // A malformed local cache can be safely replaced on the next sync.
        }
        return specs;
    }

    private static void saveSpecs(Context context, List<ReminderSpec> specs) {
        JSONArray array = new JSONArray();
        for (ReminderSpec spec : specs) array.put(spec.toJson());
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_SCHEDULED, array.toString())
                .apply();
    }

    private static void schedule(Context context, AlarmManager alarm,
                                 ReminderSpec spec) {
        PendingIntent pendingIntent = pendingIntent(context, spec);
        // AlarmManager.set() is inexact on API 19+; do not opt into exact-alarm
        // permission for date-level reminders.
        alarm.set(AlarmManager.RTC_WAKEUP, spec.triggerAtMillis, pendingIntent);
    }

    private static void cancel(Context context, AlarmManager alarm,
                               ReminderSpec spec) {
        alarm.cancel(pendingIntent(context, spec));
    }

    private static PendingIntent pendingIntent(Context context, ReminderSpec spec) {
        Intent intent = new Intent(context, ReminderReceiver.class)
                .setAction(ACTION_REMINDER)
                .setData(Uri.parse("valora://reminder/" + Uri.encode(spec.id)))
                .putExtra("reminderId", spec.id)
                .putExtra("notificationId", spec.notificationId)
                .putExtra("title", spec.title)
                .putExtra("text", spec.body);
        return PendingIntent.getBroadcast(
                context,
                spec.notificationId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    private static long parseIsoMillis(String raw) {
        if (raw == null || raw.isEmpty()) return 0L;
        String[] patterns = {
                "yyyy-MM-dd'T'HH:mm:ss.SSSX",
                "yyyy-MM-dd'T'HH:mm:ssX",
                "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        };
        for (String pattern : patterns) {
            try {
                SimpleDateFormat format = new SimpleDateFormat(pattern, Locale.US);
                format.setLenient(false);
                Date parsed = format.parse(raw);
                if (parsed != null) return parsed.getTime();
            } catch (ParseException ignored) {
                // Try the next canonical ISO-8601 shape.
            }
        }
        return 0L;
    }

    private static long parseLocalDateMillis(String raw, int hourOfDay) {
        if (raw == null || raw.isEmpty()) return 0L;
        try {
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
            format.setLenient(false);
            Date parsed = format.parse(raw);
            if (parsed == null) return 0L;
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(parsed);
            calendar.set(Calendar.HOUR_OF_DAY, hourOfDay);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
            return calendar.getTimeInMillis();
        } catch (ParseException ignored) {
            return 0L;
        }
    }
}
