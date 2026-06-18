package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraMiniWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraMiniWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        String currency = prefs.getString("currency", "¥");
        String total = prefs.getString("totalAssetValue", "0.00");
        String daily = prefs.getString("averageDailyCost", "0.00");
        RemoteViews views = new RemoteViews(context.getPackageName(), WidgetUtils.layout(context, R.layout.widget_mini, R.layout.widget_mini_hyperos));
        views.setTextViewText(R.id.widget_mini_total, currency + total);
        views.setTextViewText(R.id.widget_mini_daily, context.getString(R.string.widget_mini_daily_format, currency, daily));
        views.setOnClickPendingIntent(R.id.widget_mini_root, WidgetUtils.openApp(context, 7410));
        manager.updateAppWidget(id, views);
    }
}
