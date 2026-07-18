package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class ValoraDailyWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraDailyWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        SharedPreferences prefs = WidgetUtils.prefs(context);
        String currency = prefs.getString("currency", "¥");
        String daily = prefs.getString("averageDailyCost", "0.00");
        int serving = prefs.getInt("servingCount", 0);
        RemoteViews views = new RemoteViews(context.getPackageName(), WidgetUtils.layout(context, R.layout.widget_daily, R.layout.widget_daily_hyperos));
        views.setTextViewText(R.id.widget_daily_cost, currency + daily);
        views.setTextViewText(R.id.widget_daily_meta, context.getString(R.string.widget_daily_meta_format, serving));
        views.setOnClickPendingIntent(R.id.widget_daily_root, WidgetUtils.openApp(context, 7402));
        manager.updateAppWidget(id, views);
    }
}
