import 'package:hive/hive.dart';

part 'quest.g.dart';

enum StatusQuest { belum, dikerjakan, selesai }

@HiveType(typeId: 4)
class Quest extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String judul;

  @HiveField(2)
  late String? deskripsi;

  @HiveField(3)
  late String matkul;

  @HiveField(4)
  late DateTime deadline;

  @HiveField(5)
  late int statusIndex;

  @HiveField(6)
  late int xpReward; // XP yang didapat kalau selesai

  @HiveField(7)
  late List<String> lampiranPaths; // path file/gambar

  StatusQuest get status => StatusQuest.values[statusIndex];
  set status(StatusQuest s) => statusIndex = s.index;

  Quest({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.matkul,
    required this.deadline,
    StatusQuest status = StatusQuest.belum,
    this.xpReward = 100,
    List<String>? lampiran,
  }) {
    statusIndex = status.index;
    lampiranPaths = lampiran ?? [];
  }

  bool get isOverdue =>
      deadline.isBefore(DateTime.now()) && status != StatusQuest.selesai;

  int get daysUntilDeadline {
    final now = DateTime.now();
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    return deadlineDate.difference(todayDate).inDays;
  }
}
