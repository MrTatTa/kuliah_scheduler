import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/quest.dart';
import 'dart:typed_data';
import '../models/event.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'jadwalin';
  static const _channelName = 'Jadwalin';
  static bool _initialized = false;

  // ── Init ───────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _createNotificationChannel();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> _createNotificationChannel() async {
    // Hapus 'const', ganti dengan 'final'
    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifikasi deadline tugas',
      importance: Importance.high,
      playSound: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);
  }

  // ── Notifikasi Quest ───────────────────────────────────────────────────────

  static Future<void> scheduleQuestReminders(Quest quest) async {
    await cancelQuestReminders(quest.id);

    final now = DateTime.now();

    // H-2: jam 08:00 dua hari sebelum deadline
    final h2 = DateTime(
      quest.deadline.year,
      quest.deadline.month,
      quest.deadline.day,
      8,
      0,
    ).subtract(const Duration(days: 2));

    // H-1: jam 08:00 satu hari sebelum deadline
    final h1 = DateTime(
      quest.deadline.year,
      quest.deadline.month,
      quest.deadline.day,
      8,
      0,
    ).subtract(const Duration(days: 1));

    try {
      if (h2.isAfter(now)) {
        await _scheduleNotification(
          id: quest.id.hashCode.abs(),
          title: '⚠️ Deadline 2 hari lagi!',
          body: '${quest.judul} — ${quest.matkul}',
          scheduledDate: h2,
        );
        debugPrint('Notif H-2 dijadwalkan: $h2');
      }

      if (h1.isAfter(now)) {
        await _scheduleNotification(
          id: (quest.id.hashCode + 1).abs(),
          title: '🚨 Deadline besok!',
          body: '${quest.judul} — ${quest.matkul}',
          scheduledDate: h1,
        );
        debugPrint('Notif H-1 dijadwalkan: $h1');
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  static Future<void> cancelQuestReminders(String questId) async {
    try {
      await _plugin.cancel(questId.hashCode.abs());
      await _plugin.cancel((questId.hashCode + 1).abs());
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  // ── Notifikasi Event ───────────────────────────────────────────────────────

  static Future<void> scheduleEventReminder(Event event) async {
    await cancelEventReminder(event.id);

    final now = DateTime.now();

    // Parse jam mulai event
    final parts = event.jamMulai.split(':');
    final eventStart = DateTime(
      event.tanggal.year,
      event.tanggal.month,
      event.tanggal.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // 15 menit sebelum mulai
    final reminderTime = eventStart.subtract(const Duration(minutes: 15));

    if (reminderTime.isAfter(now)) {
      try {
        await _scheduleNotification(
          id: event.id.hashCode.abs(),
          title: '🗓️ Kegiatan mulai 15 menit lagi!',
          body: '${event.judul} — ${event.jamMulai}',
          scheduledDate: reminderTime,
        );
        debugPrint('Notif event dijadwalkan: $reminderTime');
      } catch (e) {
        debugPrint('Event notification error: $e');
      }
    }
  }

  static Future<void> cancelEventReminder(String eventId) async {
    try {
      await _plugin.cancel(eventId.hashCode.abs());
    } catch (e) {
      debugPrint('Cancel event notification error: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        // Hapus 'const' di sini
        android: AndroidNotificationDetails(
          // Hapus 'const' di sini
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
