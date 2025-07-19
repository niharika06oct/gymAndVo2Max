// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vo2.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class Vo2RecordAdapter extends TypeAdapter<Vo2Record> {
  @override
  final int typeId = 0;

  @override
  Vo2Record read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vo2Record(
      date: fields[0] as DateTime,
      vo2: fields[1] as double,
      method: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Vo2Record obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.vo2)
      ..writeByte(2)
      ..write(obj.method);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vo2RecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
