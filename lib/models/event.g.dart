// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 1;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String?,
      tanggal: fields[3] as DateTime,
      jamMulai: fields[4] as String,
      jamSelesai: fields[5] as String,
      warna: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.tanggal)
      ..writeByte(4)
      ..write(obj.jamMulai)
      ..writeByte(5)
      ..write(obj.jamSelesai)
      ..writeByte(6)
      ..write(obj.warna);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
