// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jurnal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JurnalAdapter extends TypeAdapter<Jurnal> {
  @override
  final int typeId = 3;

  @override
  Jurnal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Jurnal(
      id: fields[0] as String,
      kelasId: fields[1] as String,
      tanggal: fields[2] as DateTime,
      pertemuanKe: fields[3] as int,
      materi: fields[4] as String,
      catatan: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Jurnal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kelasId)
      ..writeByte(2)
      ..write(obj.tanggal)
      ..writeByte(3)
      ..write(obj.pertemuanKe)
      ..writeByte(4)
      ..write(obj.materi)
      ..writeByte(5)
      ..write(obj.catatan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JurnalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
