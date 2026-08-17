// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresensiAdapter extends TypeAdapter<Presensi> {
  @override
  final int typeId = 2;

  @override
  Presensi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Presensi(
      id: fields[0] as String,
      kelasId: fields[1] as String,
      tanggal: fields[2] as DateTime,
      pertemuanKe: fields[4] as int,
    )..statusIndex = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, Presensi obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kelasId)
      ..writeByte(2)
      ..write(obj.tanggal)
      ..writeByte(3)
      ..write(obj.statusIndex)
      ..writeByte(4)
      ..write(obj.pertemuanKe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresensiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
