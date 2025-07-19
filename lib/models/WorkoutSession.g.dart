// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkoutSession.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 2;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      start: fields[1] as DateTime,
      end: fields[2] as DateTime,
      sets: (fields[3] as List).cast<InvalidType>(),
      intervals: (fields[4] as List).cast<InvalidType>(),
      vo2Estimate: fields[5] as double?,
      perceivedEffort: fields[6] as int?,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.sets)
      ..writeByte(4)
      ..write(obj.intervals)
      ..writeByte(5)
      ..write(obj.vo2Estimate)
      ..writeByte(6)
      ..write(obj.perceivedEffort)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
