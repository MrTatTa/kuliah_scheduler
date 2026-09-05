package com.example.kuliah_scheduler

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class ScheduleWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "jadwalin_widget_prefs"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs: SharedPreferences =
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val tanggal = prefs.getString("widget_tanggal", "Hari ini") ?: "Hari ini"
            val kelas   = prefs.getString("widget_kelas",   "Tidak ada kelas") ?: "Tidak ada kelas"
            val event   = prefs.getString("widget_event",   "Tidak ada kegiatan") ?: "Tidak ada kegiatan"

            val views = RemoteViews(context.packageName, R.layout.schedule_widget)
            views.setTextViewText(R.id.widget_date,  tanggal)
            views.setTextViewText(R.id.widget_kelas, kelas)
            views.setTextViewText(R.id.widget_event, event)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}