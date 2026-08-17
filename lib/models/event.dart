import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String judul;

  @HiveField(2)
  late String? deskripsi;

  @HiveField(3)
  late DateTime tanggal;

  @HiveField(4)
  late String jamMulai;

  @HiveField(5)
  late String jamSelesai;

  @HiveField(6)
  late String warna;

  Event({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.warna,
  });
}