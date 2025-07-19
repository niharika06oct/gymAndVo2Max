import 'package:hive/hive.dart';
part 'WorkoutSession.g.dart';

@HiveType(typeId: 2)
class WorkoutSession extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final DateTime start;
  @HiveField(2) final DateTime end;
  @HiveField(3) final List<WorkoutSet> sets;
  @HiveField(4) final List<Interval> intervals;
  @HiveField(5) final double? vo2Estimate;
  @HiveField(6) final int? perceivedEffort;
  @HiveField(7) final String? notes;

  WorkoutSession({
    required this.id,
    required this.start,
    required this.end,
    this.sets = const [],
    this.intervals = const [],
    this.vo2Estimate,
    this.perceivedEffort,
    this.notes,
  });
}
