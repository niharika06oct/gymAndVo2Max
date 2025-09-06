import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../models/vo2.dart';
import '../models/Exercise.dart';
import '../models/WorkoutSession.dart';
import '../models/WorkoutSet.dart';
import '../models/Interval.dart';
import '../models/WorkoutTemplate.dart';

// Boxes are opened in main.dart; providers simply expose them.

final vo2BoxProvider = Provider<Box<Vo2Record>>((ref) {
  return Hive.box<Vo2Record>('vo2');
});

// Reactive list of records
final vo2RecordsProvider = StreamProvider<List<Vo2Record>>((ref) {
  final box = ref.watch(vo2BoxProvider);
  // Emit current list first then updates
  return box.watch().map((_) => box.values.cast<Vo2Record>().toList())
    .startWith(box.values.cast<Vo2Record>().toList());
});

final exerciseBoxProvider = Provider<Box<Exercise>>((ref) {
  return Hive.box<Exercise>('exercises');
});

final workoutSessionBoxProvider = Provider<Box<WorkoutSession>>((ref) {
  return Hive.box<WorkoutSession>('workout_sessions');
});

final workoutSetBoxProvider = Provider<Box<WorkoutSet>>((ref) {
  return Hive.box<WorkoutSet>('workout_sets');
});

final intervalBoxProvider = Provider<Box<Interval>>((ref) {
  return Hive.box<Interval>('intervals');
});

final workoutSessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
  final box = ref.watch(workoutSessionBoxProvider);
  return box.watch().map((_) => box.values.cast<WorkoutSession>().toList())
    .startWith(box.values.cast<WorkoutSession>().toList());
});

final workoutTemplateBoxProvider = Provider<Box<WorkoutTemplate>>((ref) {
  return Hive.box<WorkoutTemplate>('workout_templates');
});

final workoutTemplatesProvider = StreamProvider<List<WorkoutTemplate>>((ref) {
  final box = ref.watch(workoutTemplateBoxProvider);
  return box.watch().map((_) => box.values.cast<WorkoutTemplate>().toList())
    .startWith(box.values.cast<WorkoutTemplate>().toList());
});
