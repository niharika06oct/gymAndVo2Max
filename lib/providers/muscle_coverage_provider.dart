import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../models/WorkoutSession.dart';
import '../models/Exercise.dart';
import 'boxes.dart';
import '../data/exercises.dart';

/// Maps specific muscles to radar categories so the chart stays consistent.
const Map<String, String> _muscleToCategory = {
  // Chest
  'Chest': 'Chest',

  // Back
  'Back': 'Back',
  'Lats': 'Back',

  // Legs
  'Quadriceps': 'Legs',
  'Glutes': 'Legs',
  'Hamstrings': 'Legs',
  'Calves': 'Legs',

  // Shoulders
  'Shoulders': 'Shoulders',
  'Delts': 'Shoulders',

  // Arms
  'Biceps': 'Arms',
  'Triceps': 'Arms',

  // Core
  'Core': 'Core',
  'Abs': 'Core',
};

/// Returns a map of category -> accumulated volume (reps * load) across ALL sessions.
final muscleCoverageProvider = StreamProvider<Map<String, double>>((ref) {
  final box = ref.watch(workoutSessionBoxProvider);

  Map<String, double> _aggregate() {
    final map = <String, double>{
      'Chest': 0,
      'Back': 0,
      'Legs': 0,
      'Shoulders': 0,
      'Arms': 0,
      'Core': 0,
    };

    for (final session in box.values.cast<WorkoutSession>()) {
      for (final set in session.sets) {
        Exercise? exercise;
        try {
          exercise = kExerciseCatalog.firstWhere((e) => e.id == set.exerciseId);
        } catch (_) {
          exercise = null;
        }
        if (exercise == null) continue;
        for (final muscle in exercise.primaryMuscles) {
          final category = _muscleToCategory[muscle] ?? muscle;
          map[category] = (map[category] ?? 0) + (set.reps * set.load);
        }
      }
    }
    return map;
  }

  return box.watch().map((_) => _aggregate()).startWith(_aggregate());
}); 