package com.valora.assets;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager appWidgetManager) {
        ComponentName component = new ComponentName(context, ValoraWidgetProvider.class);
        int[] ids = appWidgetManager.getAppWidgetIds(component);
        for (int id : ids) updateWidget(context, appWidgetManager, id);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = context.getSharedPreferences("valora_widget", Context.MODE_PRIVATE);
        String currency = prefs.getString("currency", "¥");
        String total = prefs.getString("totalAssetValue", "0.00");
        String daily = prefs.getString("averageDailyCost", "0.00");
        int assetCount = prefs.getInt("assetCount", 0);
        int wishCount = prefs.getInt("wishCount", 0);
        int serving = prefs.getInt("servingCount", 0);
        int sold = prefs.getInt("soldCount", 0);

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_valora);
        views.setTextViewText(R.id.widget_total, currency + total);
        views.setTextViewText(R.id.widget_meta, assetCount + " 件资产 · " + serving + " 服役 · " + sold + " 已卖 · 日均 " + currency + daily);

        Intent open = new Intent(context, MainActivity.class);
        PendingIntent pi = PendingIntent.getActivity(context, 7301, open, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.widget_root, pi);
        manager.updateAppWidget(id, views);
    }
}
