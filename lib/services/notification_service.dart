import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/quest.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'kuliah_scheduler';
  static const _channelName = 'Kuliah Scheduler';

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifikasi jadwal dan deadline tugas',
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);
  }

  // ── Notifikasi Quest ──────────────────────────────────────────────────────

  static Future<void> scheduleQuestReminders(Quest quest) async {
    // Batalkan notifikasi lama kalau ada
    await cancelQuestReminders(quest.id);

    final deadline = quest.deadline;
    final now = DateTime.now();

    // H-2
    final h2 = DateTime(
      deadline.year,
      deadline.month,
      deadline.day - 2,
      8,
      0, // jam 08:00
    );
    if (h2.isAfter(now)) {
      await _scheduleNotification(
        id: quest.id.hashCode,
        title: '⚠️ Deadline 2 hari lagi!',
        body: '${quest.judul} — ${quest.matkul}',
        scheduledDate: h2,
      );
    }

    // H-1
    final h1 = DateTime(
      deadline.year,
      deadline.month,
      deadline.day - 1,
      8,
      0, // jam 08:00
    );
    if (h1.isAfter(now)) {
      await _scheduleNotification(
        id: quest.id.hashCode + 1,
        title: '🚨 Deadline besok!',
        body: '${quest.judul} — ${quest.matkul}',
        scheduledDate: h1,
      );
    }
  }

  static Future<void> cancelQuestReminders(String questId) async {
    await _plugin.cancel(questId.hashCode);
    await _plugin.cancel(questId.hashCode + 1);
  }

  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

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
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
