import 'package:hive/hive.dart';
import 'Exercise.dart';
part 'WorkoutTemplate.g.dart';

@HiveType(typeId: 5)
class WorkoutTemplate extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String description;
  @HiveField(3) final List<TemplateExercise> exercises;
  @HiveField(4) final String category; // 'Strength', 'HIIT', 'Cardio', 'Core'
  @HiveField(5) final int estimatedDuration; // in minutes
  @HiveField(6) final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  @HiveField(7) final String? baseTemplateId; // ID of the original template (null for original templates)
  @HiveField(8) final bool isCustom; // true if this is a custom version

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.category,
    required this.estimatedDuration,
    required this.difficulty,
    String? baseTemplateId,
    this.isCustom = false,
  }) : baseTemplateId = baseTemplateId;
}

@HiveType(typeId: 6)
class TemplateExercise extends HiveObject {
  @HiveField(0) final String exerciseId;
  @HiveField(1) final int sets;
  @HiveField(2) final int reps;
  @HiveField(3) final double? weight; // null for bodyweight exercises
  @HiveField(4) final int? restSeconds; // rest between sets
  @HiveField(5) final String? notes;

  TemplateExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weight,
    this.restSeconds,
    this.notes,
  });
}
