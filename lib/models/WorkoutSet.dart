import 'package:hive/hive.dart';
part 'WorkoutSet.g.dart';

@HiveType(typeId: 3)
class WorkoutSet extends HiveObject {
  @HiveField(0) final String exerciseId;   // FK into Exercise table
  @HiveField(1) final int setIndex;        // 1,2,3...
  @HiveField(2) final int reps;
  @HiveField(3) final double load;         // kg or lb, read unit from Exercise.defaultUnit
  @HiveField(4) final int rpe;             // 1‑10; optional but nice

  WorkoutSet({
    required this.exerciseId,
    required this.setIndex,
    required this.reps,
    required this.load,
    this.rpe = 0,
  });
}