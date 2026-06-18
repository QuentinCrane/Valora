package com.valora.assets;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Locale;

public final class WidgetUtils {
    private WidgetUtils() {}

    private static Boolean hyperOsCached;

    public static SharedPreferences prefs(Context context) {
        return context.getSharedPreferences("valora_widget", Context.MODE_PRIVATE);
    }

    public static PendingIntent openApp(Context context, int requestCode) {
        Intent open = new Intent(context, MainActivity.class);
        open.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return PendingIntent.getActivity(context, requestCode, open, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    public static PendingIntent openAction(Context context, String action, int requestCode) {
        Intent intent = new Intent(context, MainActivity.class).setAction(action);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return PendingIntent.getActivity(context, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    public static void updateProvider(Context context, Class<?> providerClass, AppWidgetManager manager) {
        ComponentName component = new ComponentName(context, providerClass);
        int[] ids = manager.getAppWidgetIds(component);
        if (ids == null || ids.length == 0) return;
        Intent intent = new Intent(context, providerClass);
        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        context.sendBroadcast(intent);
    }

    public static boolean isHyperOsOrMiuiDevice() {
        if (hyperOsCached != null) return hyperOsCached.booleanValue();
        String maker = (Build.MANUFACTURER + " " + Build.BRAND + " " + Build.DEVICE + " " + Build.MODEL).toLowerCase(Locale.ROOT);
        boolean xiaomiFamily = maker.contains("xiaomi") || maker.contains("redmi") || maker.contains("poco");
        boolean hyper = false;
        if (xiaomiFamily) {
            String osName = readSystemProperty("ro.mi.os.version.name") + " " + readSystemProperty("ro.miui.ui.version.name");
            String lower = osName.toLowerCase(Locale.ROOT);
            hyper = lower.contains("hyper") || lower.contains("miui") || osName.trim().length() > 0;
        }
        hyperOsCached = Boolean.valueOf(xiaomiFamily || hyper);
        return hyperOsCached.booleanValue();
    }

    private static String readSystemProperty(String key) {
        Process process = null;
        try {
            process = new ProcessBuilder("getprop", key).redirectErrorStream(true).start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String value = reader.readLine();
                return value == null ? "" : value.trim();
            }
        } catch (Exception ignored) {
            return "";
        } finally {
            if (process != null) process.destroy();
        }
    }

    public static int layout(Context context, int defaultLayout, int hyperOsLayout) {
        return isHyperOsOrMiuiDevice() ? hyperOsLayout : defaultLayout;
    }

    public static String appName(Context context) {
        return context.getString(R.string.app_name);
    }
}
