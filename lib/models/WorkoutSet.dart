import 'package:hive/hive.dart';
part 'WorkoutSet.g.dart';

@HiveType(typeId: 3)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  final String exerciseId;
  @HiveField(1)
  final int setIndex;
  @HiveField(2)
  final List<double> loads;
  @HiveField(3)
  final int rpe;

  int get reps => loads.length;
  double get totalVolume => loads.fold(0.0, (a, b) => a + b);
  double get averageLoad => reps > 0 ? totalVolume / reps : 0.0;

  WorkoutSet({
    required this.exerciseId,
    required this.setIndex,
    required this.loads,
    this.rpe = 0,
  });
}