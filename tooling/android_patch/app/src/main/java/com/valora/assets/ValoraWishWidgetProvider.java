package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraWishWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraWishWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        int wishCount = prefs.getInt("wishCount", 0);
        int snapshotCount = prefs.getInt("snapshotCount", 0);
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_wish);
        views.setTextViewText(R.id.widget_wish_count, String.valueOf(wishCount));
        views.setTextViewText(R.id.widget_wish_meta, snapshotCount + " 份快照 · 点击打开心愿");
        views.setOnClickPendingIntent(R.id.widget_wish_root, WidgetUtils.openApp(context, 7401));
        manager.updateAppWidget(id, views);
    }
}
