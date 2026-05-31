package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraDueWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraDueWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        int dueSoon = prefs.getInt("dueSoonCount", 0);
        int assetCount = prefs.getInt("assetCount", 0);
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_due);
        views.setTextViewText(R.id.widget_due_count, String.valueOf(dueSoon));
        views.setTextViewText(R.id.widget_due_meta, dueSoon == 0 ? assetCount + " 件资产暂无临期" : dueSoon + " 件资产需要复盘");
        views.setOnClickPendingIntent(R.id.widget_due_root, WidgetUtils.openApp(context, 7407));
        manager.updateAppWidget(id, views);
    }
}
