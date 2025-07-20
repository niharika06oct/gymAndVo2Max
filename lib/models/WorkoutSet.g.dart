// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkoutSet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSetAdapter extends TypeAdapter<WorkoutSet> {
  @override
  final int typeId = 3;

  @override
  WorkoutSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSet(
      exerciseId: fields[0] as String,
      setIndex: fields[1] as int,
      loads: (fields[2] as List).cast<double>(),
      rpe: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSet obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.setIndex)
      ..writeByte(2)
      ..write(obj.loads)
      ..writeByte(3)
      ..write(obj.rpe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
