import '../models/Exercise.dart';

/// Central exercise catalog so multiple screens can reference the same list.
final List<Exercise> kExerciseCatalog = [
  Exercise(
    id: 'bench_press',
    name: 'Bench Press',
    primaryMuscles: ['Chest', 'Triceps'],
    secondaryMuscles: ['Shoulders'],
    category: 'Strength',
    defaultUnit: 'kg',
  ),
  Exercise(
    id: 'squat',
    name: 'Squat',
    primaryMuscles: ['Quadriceps', 'Glutes'],
    secondaryMuscles: ['Core', 'Hamstrings'],
    category: 'Strength',
    defaultUnit: 'kg',
  ),
  Exercise(
    id: 'deadlift',
    name: 'Deadlift',
    primaryMuscles: ['Back', 'Hamstrings'],
    secondaryMuscles: ['Glutes', 'Core'],
    category: 'Strength',
    defaultUnit: 'kg',
  ),
  Exercise(
    id: 'pull_up',
    name: 'Pull Up',
    primaryMuscles: ['Back', 'Biceps'],
    secondaryMuscles: ['Shoulders'],
    category: 'Strength',
    defaultUnit: 'reps',
  ),
  Exercise(
    id: 'shoulder_press',
    name: 'Shoulder Press',
    primaryMuscles: ['Shoulders'],
    secondaryMuscles: ['Triceps'],
    category: 'Strength',
    defaultUnit: 'kg',
  ),
  Exercise(
    id: 'plank',
    name: 'Plank',
    primaryMuscles: ['Core'],
    secondaryMuscles: ['Shoulders'],
    category: 'Core',
    defaultUnit: 'sec',
  ),
]; 