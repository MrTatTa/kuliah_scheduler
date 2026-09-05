import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';

class WidgetService {
  static const _channel = MethodChannel(
    'com.example.kuliah_scheduler/widget',
  );

  static Future<void> updateWidget() async {
    try {
      final now = DateTime.now();
      final hariIndex = now.weekday - 1;

      final kelasList = DatabaseService.getKelasByHari(hariIndex);
      final eventList = DatabaseService.getEventsByDate(now);

      final days = [
        'Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'
      ];
      final months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Ags','Sep','Okt','Nov','Des'
      ];

      final tanggal =
          '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

      final kelasStr = kelasList.isEmpty
          ? 'Tidak ada kelas'
          : kelasList
              .map((k) => '• ${k.namaMatkul}  ${k.jamMulai}–${k.jamSelesai}')
              .join('\n');

      final eventStr = eventList.isEmpty
          ? 'Tidak ada kegiatan'
          : eventList
              .map((e) => '• ${e.judul}  ${e.jamMulai}–${e.jamSelesai}')
              .join('\n');

      await _channel.invokeMethod('updateWidget', {
        'tanggal': tanggal,
        'kelas': kelasStr,
        'event': eventStr,
      });
    } catch (e) {
      // Widget belum dipasang atau tidak didukung — skip
      debugPrint('Widget update skipped: $e');
    }
  }
}