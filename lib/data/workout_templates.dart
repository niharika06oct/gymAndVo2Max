import '../models/WorkoutTemplate.dart';

/// Predefined workout templates for common fitness routines
final List<WorkoutTemplate> kWorkoutTemplates = [
  // STRENGTH TEMPLATES
  WorkoutTemplate(
    id: 'push_day',
    name: 'Push Day',
    description: 'Upper body pushing movements focusing on chest, shoulders, and triceps',
    category: 'Strength',
    difficulty: 'Intermediate',
    estimatedDuration: 60,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'bench_press', sets: 4, reps: 8, weight: 80, restSeconds: 180),
      TemplateExercise(exerciseId: 'incline_bench_press', sets: 3, reps: 10, weight: 60, restSeconds: 120),
      TemplateExercise(exerciseId: 'shoulder_press', sets: 3, reps: 10, weight: 25, restSeconds: 120),
      TemplateExercise(exerciseId: 'lateral_raises', sets: 3, reps: 15, weight: 10, restSeconds: 90),
      TemplateExercise(exerciseId: 'tricep_pushdown', sets: 3, reps: 12, weight: 20, restSeconds: 90),
      TemplateExercise(exerciseId: 'close_grip_bench_press', sets: 3, reps: 10, weight: 50, restSeconds: 90),
    ],
  ),
  
  WorkoutTemplate(
    id: 'pull_day',
    name: 'Pull Day',
    description: 'Upper body pulling movements focusing on back and biceps',
    category: 'Strength',
    difficulty: 'Intermediate',
    estimatedDuration: 60,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'deadlift', sets: 4, reps: 5, weight: 100, restSeconds: 240),
      TemplateExercise(exerciseId: 'pull_up', sets: 3, reps: 8, restSeconds: 120),
      TemplateExercise(exerciseId: 'bent_over_row', sets: 3, reps: 10, weight: 60, restSeconds: 120),
      TemplateExercise(exerciseId: 'lat_pulldown', sets: 3, reps: 12, weight: 50, restSeconds: 90),
      TemplateExercise(exerciseId: 'bicep_curls', sets: 3, reps: 12, weight: 15, restSeconds: 90),
      TemplateExercise(exerciseId: 'hammer_curls', sets: 3, reps: 12, weight: 15, restSeconds: 90),
    ],
  ),
  
  WorkoutTemplate(
    id: 'leg_day',
    name: 'Leg Day',
    description: 'Lower body strength training focusing on quads, glutes, and hamstrings',
    category: 'Strength',
    difficulty: 'Intermediate',
    estimatedDuration: 75,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'squat', sets: 4, reps: 8, weight: 80, restSeconds: 180),
      TemplateExercise(exerciseId: 'romanian_deadlift', sets: 3, reps: 10, weight: 70, restSeconds: 120),
      TemplateExercise(exerciseId: 'lunges', sets: 3, reps: 12, weight: 20, restSeconds: 90),
      TemplateExercise(exerciseId: 'leg_press', sets: 3, reps: 15, weight: 100, restSeconds: 90),
      TemplateExercise(exerciseId: 'leg_extension', sets: 3, reps: 15, weight: 30, restSeconds: 60),
      TemplateExercise(exerciseId: 'leg_curl', sets: 3, reps: 15, weight: 25, restSeconds: 60),
      TemplateExercise(exerciseId: 'calf_raises', sets: 4, reps: 20, weight: 40, restSeconds: 60),
    ],
  ),
  
  WorkoutTemplate(
    id: 'full_body_basic',
    name: 'Full Body Basic',
    description: 'Complete full body workout for beginners',
    category: 'Strength',
    difficulty: 'Beginner',
    estimatedDuration: 45,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'squat', sets: 3, reps: 12, weight: 40, restSeconds: 90),
      TemplateExercise(exerciseId: 'push_ups', sets: 3, reps: 10, restSeconds: 90),
      TemplateExercise(exerciseId: 'bent_over_row', sets: 3, reps: 10, weight: 30, restSeconds: 90),
      TemplateExercise(exerciseId: 'shoulder_press', sets: 3, reps: 10, weight: 15, restSeconds: 60),
      TemplateExercise(exerciseId: 'plank', sets: 3, reps: 30, restSeconds: 60),
      TemplateExercise(exerciseId: 'bicep_curls', sets: 3, reps: 12, weight: 10, restSeconds: 60),
    ],
  ),
  
  // HIIT TEMPLATES
  WorkoutTemplate(
    id: 'hiit_basic',
    name: 'Basic HIIT',
    description: 'High intensity interval training for fat burning',
    category: 'HIIT',
    difficulty: 'Beginner',
    estimatedDuration: 20,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'burpees', sets: 4, reps: 10, restSeconds: 30),
      TemplateExercise(exerciseId: 'mountain_climbers', sets: 4, reps: 20, restSeconds: 30),
      TemplateExercise(exerciseId: 'jumping_jacks', sets: 4, reps: 30, restSeconds: 30),
      TemplateExercise(exerciseId: 'high_knees', sets: 4, reps: 20, restSeconds: 30),
      TemplateExercise(exerciseId: 'jump_squats', sets: 4, reps: 15, restSeconds: 30),
    ],
  ),
  
  WorkoutTemplate(
    id: 'hiit_advanced',
    name: 'Advanced HIIT',
    description: 'High intensity interval training for experienced athletes',
    category: 'HIIT',
    difficulty: 'Advanced',
    estimatedDuration: 30,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'burpees', sets: 5, reps: 15, restSeconds: 20),
      TemplateExercise(exerciseId: 'mountain_climbers', sets: 5, reps: 30, restSeconds: 20),
      TemplateExercise(exerciseId: 'jump_squats', sets: 5, reps: 20, restSeconds: 20),
      TemplateExercise(exerciseId: 'pike_push_ups', sets: 5, reps: 10, restSeconds: 20),
      TemplateExercise(exerciseId: 'high_knees', sets: 5, reps: 30, restSeconds: 20),
      TemplateExercise(exerciseId: 'jumping_jacks', sets: 5, reps: 40, restSeconds: 20),
    ],
  ),
  
  // CORE TEMPLATES
  WorkoutTemplate(
    id: 'core_basic',
    name: 'Core Basics',
    description: 'Fundamental core strengthening exercises',
    category: 'Core',
    difficulty: 'Beginner',
    estimatedDuration: 15,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'plank', sets: 3, reps: 30, restSeconds: 60),
      TemplateExercise(exerciseId: 'crunches', sets: 3, reps: 20, restSeconds: 45),
      TemplateExercise(exerciseId: 'russian_twists', sets: 3, reps: 20, restSeconds: 45),
      TemplateExercise(exerciseId: 'dead_bug', sets: 3, reps: 10, restSeconds: 45),
      TemplateExercise(exerciseId: 'bird_dog', sets: 3, reps: 10, restSeconds: 45),
    ],
  ),
  
  WorkoutTemplate(
    id: 'core_advanced',
    name: 'Advanced Core',
    description: 'Challenging core exercises for strength and stability',
    category: 'Core',
    difficulty: 'Advanced',
    estimatedDuration: 25,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'plank', sets: 3, reps: 60, restSeconds: 90),
      TemplateExercise(exerciseId: 'side_plank', sets: 3, reps: 30, restSeconds: 60),
      TemplateExercise(exerciseId: 'hollow_body_hold', sets: 3, reps: 30, restSeconds: 60),
      TemplateExercise(exerciseId: 'leg_raises', sets: 3, reps: 15, restSeconds: 60),
      TemplateExercise(exerciseId: 'russian_twists', sets: 3, reps: 30, restSeconds: 45),
      TemplateExercise(exerciseId: 'mountain_climbers', sets: 3, reps: 20, restSeconds: 45),
    ],
  ),
  
  // CARDIO TEMPLATES
  WorkoutTemplate(
    id: 'cardio_basic',
    name: 'Basic Cardio',
    description: 'Low to moderate intensity cardio workout',
    category: 'Cardio',
    difficulty: 'Beginner',
    estimatedDuration: 30,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'running', sets: 1, reps: 20, restSeconds: 0),
      TemplateExercise(exerciseId: 'cycling', sets: 1, reps: 10, restSeconds: 0),
    ],
  ),
  
  WorkoutTemplate(
    id: 'bodyweight_circuit',
    name: 'Bodyweight Circuit',
    description: 'Complete bodyweight workout requiring no equipment',
    category: 'Strength',
    difficulty: 'Intermediate',
    estimatedDuration: 40,
    isCustom: false,
    exercises: [
      TemplateExercise(exerciseId: 'push_ups', sets: 3, reps: 15, restSeconds: 60),
      TemplateExercise(exerciseId: 'squat', sets: 3, reps: 20, restSeconds: 60),
      TemplateExercise(exerciseId: 'lunges', sets: 3, reps: 15, restSeconds: 60),
      TemplateExercise(exerciseId: 'plank', sets: 3, reps: 45, restSeconds: 60),
      TemplateExercise(exerciseId: 'burpees', sets: 3, reps: 10, restSeconds: 60),
      TemplateExercise(exerciseId: 'mountain_climbers', sets: 3, reps: 20, restSeconds: 60),
    ],
  ),
];
