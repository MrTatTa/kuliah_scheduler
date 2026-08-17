import 'package:hive/hive.dart';

part 'jurnal.g.dart';

@HiveType(typeId: 3)
class Jurnal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String kelasId;

  @HiveField(2)
  late DateTime tanggal;

  @HiveField(3)
  late int pertemuanKe;

  @HiveField(4)
  late String materi;

  @HiveField(5)
  late String? catatan;

  Jurnal({
    required this.id,
    required this.kelasId,
    required this.tanggal,
    required this.pertemuanKe,
    required this.materi,
    this.catatan,
  });
}