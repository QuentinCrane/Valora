package com.valora.assets;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public final class WidgetUtils {
    private WidgetUtils() {}

    public static SharedPreferences prefs(Context context) {
        return context.getSharedPreferences("valora_widget", Context.MODE_PRIVATE);
    }

    public static PendingIntent openApp(Context context, int requestCode) {
        Intent open = new Intent(context, MainActivity.class);
        return PendingIntent.getActivity(context, requestCode, open, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    public static PendingIntent openAction(Context context, String action, int requestCode) {
        Intent intent = new Intent(context, MainActivity.class).setAction(action);
        return PendingIntent.getActivity(context, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    public static void updateProvider(Context context, Class<?> providerClass, AppWidgetManager manager) {
        ComponentName component = new ComponentName(context, providerClass);
        int[] ids = manager.getAppWidgetIds(component);
        Intent intent = new Intent(context, providerClass);
        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        context.sendBroadcast(intent);
    }
}
