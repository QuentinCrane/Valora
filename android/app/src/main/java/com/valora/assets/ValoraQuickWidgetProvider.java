package com.valora.assets;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.widget.RemoteViews;

public class ValoraQuickWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int id : appWidgetIds) updateWidget(context, appWidgetManager, id);
    }

    public static void updateAll(Context context, AppWidgetManager manager) {
        WidgetUtils.updateProvider(context, ValoraQuickWidgetProvider.class, manager);
    }

    private static void updateWidget(Context context, AppWidgetManager manager, int id) {
        RemoteViews views = new RemoteViews(context.getPackageName(), WidgetUtils.layout(context, R.layout.widget_quick, R.layout.widget_quick_hyperos));
        views.setOnClickPendingIntent(R.id.widget_quick_root, WidgetUtils.openApp(context, 7404));
        views.setOnClickPendingIntent(R.id.widget_quick_asset, WidgetUtils.openAction(context, "com.valora.assets.ADD_ASSET", 7405));
        views.setOnClickPendingIntent(R.id.widget_quick_wish, WidgetUtils.openAction(context, "com.valora.assets.ADD_WISH", 7406));
        manager.updateAppWidget(id, views);
    }
}
