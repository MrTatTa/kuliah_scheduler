// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 4;

  @override
  Quest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quest(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String?,
      matkul: fields[3] as String,
      deadline: fields[4] as DateTime,
      xpReward: fields[6] as int,
    )..statusIndex = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, Quest obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.matkul)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.statusIndex)
      ..writeByte(6)
      ..write(obj.xpReward);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
