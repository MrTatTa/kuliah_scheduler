// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KelasAdapter extends TypeAdapter<Kelas> {
  @override
  final int typeId = 0;

  @override
  Kelas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Kelas(
      id: fields[0] as String,
      namaMatkul: fields[1] as String,
      dosen: fields[2] as String,
      ruang: fields[3] as String,
      hariIndex: fields[4] as int,
      jamMulai: fields[5] as String,
      jamSelesai: fields[6] as String,
      warna: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Kelas obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaMatkul)
      ..writeByte(2)
      ..write(obj.dosen)
      ..writeByte(3)
      ..write(obj.ruang)
      ..writeByte(4)
      ..write(obj.hariIndex)
      ..writeByte(5)
      ..write(obj.jamMulai)
      ..writeByte(6)
      ..write(obj.jamSelesai)
      ..writeByte(7)
      ..write(obj.warna);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KelasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
