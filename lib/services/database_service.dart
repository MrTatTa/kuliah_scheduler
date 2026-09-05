import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/kelas.dart';
import '../models/event.dart';
import '../models/presensi.dart';
import '../models/jurnal.dart';
import '../models/quest.dart';

class DatabaseService {
  static const _uuid = Uuid();

  // Box names
  static const String _kelasBox = 'kelas';
  static const String _eventBox = 'events';
  static const String _presensiBox = 'presensi';
  static const String _jurnalBox = 'jurnal';
  static const String _questBox = 'quests';

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    Hive.registerAdapter(KelasAdapter());
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(PresensiAdapter());
    Hive.registerAdapter(JurnalAdapter());
    Hive.registerAdapter(QuestAdapter());

    await Hive.openBox<Kelas>(_kelasBox);
    await Hive.openBox<Event>(_eventBox);
    await Hive.openBox<Presensi>(_presensiBox);
    await Hive.openBox<Jurnal>(_jurnalBox);
    await Hive.openBox<Quest>(_questBox);
  }

  static String generateId() => _uuid.v4();

  // ── Kelas ─────────────────────────────────────────────────────────────────

  static Box<Kelas> get _kelas => Hive.box<Kelas>(_kelasBox);

  static List<Kelas> getAllKelas() => _kelas.values.toList();

  static List<Kelas> getKelasByHari(int hariIndex) =>
      _kelas.values.where((k) => k.hariIndex == hariIndex).toList()
        ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));

  static Future<void> saveKelas(Kelas kelas) async =>
      await _kelas.put(kelas.id, kelas);

  static Future<void> deleteKelas(String id) async => await _kelas.delete(id);

  // ── Event ─────────────────────────────────────────────────────────────────

  static Box<Event> get _event => Hive.box<Event>(_eventBox);

  static List<Event> getAllEvents() => _event.values.toList();

  static List<Event> getEventsByDate(DateTime date) {
    final now = DateTime.now();
    return _event.values.where((e) {
      // Cek apakah tanggal sama
      final sameDay =
          e.tanggal.year == date.year &&
          e.tanggal.month == date.month &&
          e.tanggal.day == date.day;

      if (!sameDay) return false;

      // Parse jam selesai
      final parts = e.jamSelesai.split(':');
      final jamSelesai = DateTime(
        e.tanggal.year,
        e.tanggal.month,
        e.tanggal.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // Tampilkan hanya kalau belum selesai
      return jamSelesai.isAfter(now);
    }).toList()..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
  }

  static Future<void> saveEvent(Event event) async =>
      await _event.put(event.id, event);

  static Future<void> deleteEvent(String id) async {
    await _event.delete(id);
    // Notif dibatalkan dari caller, tidak di sini
    // supaya tidak perlu import NotificationService di DatabaseService
  }

  // ── Presensi ──────────────────────────────────────────────────────────────

  static Box<Presensi> get _presensi => Hive.box<Presensi>(_presensiBox);

  static List<Presensi> getPresensiByKelas(String kelasId) =>
      _presensi.values.where((p) => p.kelasId == kelasId).toList()
        ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

  static Map<StatusPresensi, int> getRekapPresensi(String kelasId) {
    final list = getPresensiByKelas(kelasId);
    return {
      StatusPresensi.hadir: list
          .where((p) => p.status == StatusPresensi.hadir)
          .length,
      StatusPresensi.izin: list
          .where((p) => p.status == StatusPresensi.izin)
          .length,
      StatusPresensi.sakit: list
          .where((p) => p.status == StatusPresensi.sakit)
          .length,
      StatusPresensi.alpa: list
          .where((p) => p.status == StatusPresensi.alpa)
          .length,
    };
  }

  static Future<void> savePresensi(Presensi presensi) async =>
      await _presensi.put(presensi.id, presensi);

  static Future<void> deletePresensi(String id) async =>
      await _presensi.delete(id);

  // ── Jurnal ────────────────────────────────────────────────────────────────

  static Box<Jurnal> get _jurnal => Hive.box<Jurnal>(_jurnalBox);

  static List<Jurnal> getJurnalByKelas(String kelasId) =>
      _jurnal.values.where((j) => j.kelasId == kelasId).toList()
        ..sort((a, b) => a.pertemuanKe.compareTo(b.pertemuanKe));

  static Future<void> saveJurnal(Jurnal jurnal) async =>
      await _jurnal.put(jurnal.id, jurnal);

  static Future<void> deleteJurnal(String id) async => await _jurnal.delete(id);

  // ── Quest ─────────────────────────────────────────────────────────────────

  static Box<Quest> get _quest => Hive.box<Quest>(_questBox);

  static List<Quest> getAllQuests() =>
      _quest.values.toList()..sort((a, b) => a.deadline.compareTo(b.deadline));

  static List<Quest> getActiveQuests() =>
      _quest.values.where((q) => q.status != StatusQuest.selesai).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  static List<Quest> getCompletedQuests() =>
      _quest.values.where((q) => q.status == StatusQuest.selesai).toList();

  static Future<void> saveQuest(Quest quest) async =>
      await _quest.put(quest.id, quest);

  static Future<void> deleteQuest(String id) async => await _quest.delete(id);
}
