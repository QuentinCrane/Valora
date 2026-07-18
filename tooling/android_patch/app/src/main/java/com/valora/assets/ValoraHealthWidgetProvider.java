package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraHealthWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraHealthWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        int leakCount = prefs.getInt("leakCount", 0);
        int dueSoon = prefs.getInt("dueSoonCount", 0);
        int retired = prefs.getInt("retiredCount", 0);
        RemoteViews views = new RemoteViews(context.getPackageName(), WidgetUtils.layout(context, R.layout.widget_health, R.layout.widget_health_hyperos));
        views.setTextViewText(R.id.widget_health_score, context.getString(leakCount == 0 && dueSoon == 0 ? R.string.widget_health_good : R.string.widget_health_review));
        views.setTextViewText(R.id.widget_health_meta, context.getString(R.string.widget_health_meta_format, leakCount, dueSoon, retired));
        views.setOnClickPendingIntent(R.id.widget_health_root, WidgetUtils.openApp(context, 7403));
        manager.updateAppWidget(id, views);
    }
}
