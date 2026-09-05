package com.example.kuliah_scheduler

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.kuliah_scheduler/widget"
    private val PREFS_NAME = "jadwalin_widget_prefs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val tanggal = call.argument<String>("tanggal") ?: "Hari ini"
                val kelas   = call.argument<String>("kelas")   ?: "Tidak ada kelas"
                val event   = call.argument<String>("event")   ?: "Tidak ada kegiatan"

                // Simpan ke SharedPreferences
                val prefs: SharedPreferences =
                    getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("widget_tanggal", tanggal)
                    .putString("widget_kelas", kelas)
                    .putString("widget_event", event)
                    .apply()

                // Update semua instance widget
                val manager = AppWidgetManager.getInstance(this)
                val ids = manager.getAppWidgetIds(
                    ComponentName(this, ScheduleWidgetProvider::class.java)
                )
                for (id in ids) {
                    ScheduleWidgetProvider.updateWidget(this, manager, id)
                }

                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}