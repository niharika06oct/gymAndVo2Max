import 'package:hive/hive.dart';
part 'vo2.g.dart';

@HiveType(typeId: 0)
class Vo2Record extends HiveObject {
  @HiveField(0) DateTime date;
  @HiveField(1) double vo2;          // ml·kg⁻¹·min⁻¹
  @HiveField(2) String method;       // 'Cooper', 'Watch', etc.

  Vo2Record({required this.date, required this.vo2, required this.method});
}
