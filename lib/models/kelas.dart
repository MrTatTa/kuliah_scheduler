import 'package:hive/hive.dart';

part 'kelas.g.dart';

@HiveType(typeId: 0)
class Kelas extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String namaMatkul;

  @HiveField(2)
  late String dosen;

  @HiveField(3)
  late String ruang;

  @HiveField(4)
  late int hariIndex; // 0=Senin, 1=Selasa, dst

  @HiveField(5)
  late String jamMulai; // format "08:00"

  @HiveField(6)
  late String jamSelesai; // format "09:40"

  @HiveField(7)
  late String warna; // hex color, misal "0xFF6C63FF"

  Kelas({
    required this.id,
    required this.namaMatkul,
    required this.dosen,
    required this.ruang,
    required this.hariIndex,
    required this.jamMulai,
    required this.jamSelesai,
    required this.warna,
  });
}