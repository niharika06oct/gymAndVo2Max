// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Interval.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntervalAdapter extends TypeAdapter<Interval> {
  @override
  final int typeId = 4;

  @override
  Interval read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Interval(
      workSec: fields[0] as int,
      restSec: fields[1] as int,
      avgHrPctMax: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Interval obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.workSec)
      ..writeByte(1)
      ..write(obj.restSec)
      ..writeByte(2)
      ..write(obj.avgHrPctMax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
