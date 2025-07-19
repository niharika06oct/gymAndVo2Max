import 'package:hive/hive.dart';
part 'Interval.g.dart';

@HiveType(typeId: 4)
class Interval extends HiveObject {
  @HiveField(0) final int workSec;
  @HiveField(1) final int restSec;
  @HiveField(2) final double avgHrPctMax;  // 0.0–1.0 of HRmax

  Interval({
    required this.workSec,
    required this.restSec,
    required this.avgHrPctMax,
  });
}