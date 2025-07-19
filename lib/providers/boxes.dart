import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vo2.dart';
import '../models/Exercise.dart';
import '../models/WorkoutSession.dart';
import '../models/WorkoutSet.dart';
import '../models/Interval.dart';

final vo2BoxProvider = FutureProvider<Box<Vo2Record>>((ref) async {
  await Hive.initFlutter();               // runs once
  Hive.registerAdapter(Vo2RecordAdapter());// generated adapter
  return await Hive.openBox<Vo2Record>('vo2');
});

final exerciseBoxProvider = FutureProvider<Box<Exercise>>((ref) async {
  Hive.registerAdapter(ExerciseAdapter());
  return await Hive.openBox<Exercise>('exercises');
});

final workoutSessionBoxProvider = FutureProvider<Box<WorkoutSession>>((ref) async {
  Hive.registerAdapter(WorkoutSessionAdapter());
  return await Hive.openBox<WorkoutSession>('workout_sessions');
});

final workoutSetBoxProvider = FutureProvider<Box<WorkoutSet>>((ref) async {
  Hive.registerAdapter(WorkoutSetAdapter());
  return await Hive.openBox<WorkoutSet>('workout_sets');
});

final intervalBoxProvider = FutureProvider<Box<Interval>>((ref) async {
  Hive.registerAdapter(IntervalAdapter());
  return await Hive.openBox<Interval>('intervals');
});
