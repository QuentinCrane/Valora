package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraSnapshotWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraSnapshotWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        int snapshots = prefs.getInt("snapshotCount", 0);
        int wishCount = prefs.getInt("wishCount", 0);
        RemoteViews views = new RemoteViews(context.getPackageName(), WidgetUtils.layout(context, R.layout.widget_snapshot, R.layout.widget_snapshot_hyperos));
        views.setTextViewText(R.id.widget_snapshot_count, String.valueOf(snapshots));
        views.setTextViewText(R.id.widget_snapshot_meta, wishCount + " 个心愿 · 点击查看资产时光机");
        views.setOnClickPendingIntent(R.id.widget_snapshot_root, WidgetUtils.openApp(context, 7408));
        manager.updateAppWidget(id, views);
    }
}
