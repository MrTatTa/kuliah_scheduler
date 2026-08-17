import 'package:hive/hive.dart';

part 'presensi.g.dart';

enum StatusPresensi { hadir, izin, sakit, alpa }

@HiveType(typeId: 2)
class Presensi extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kelasId;

  @HiveField(2)
  late DateTime tanggal;

  @HiveField(3)
  late int statusIndex;

  @HiveField(4)
  late int pertemuanKe;

  StatusPresensi get status => StatusPresensi.values[statusIndex];
  set status(StatusPresensi s) => statusIndex = s.index;

  Presensi({
    required this.id,
    required this.kelasId,
    required this.tanggal,
    required this.pertemuanKe,
    StatusPresensi status = StatusPresensi.hadir, // opsional, default hadir
  }) {
    statusIndex = status.index;
  }
}