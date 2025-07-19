import 'package:hive/hive.dart';
part 'Exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final List<String> primaryMuscles;
  @HiveField(3) final List<String>? secondaryMuscles;
  @HiveField(4) final String? category;
  @HiveField(5) final String? defaultUnit;   // 'kg', 'lb', etc.

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    this.secondaryMuscles,
    this.category,
    this.defaultUnit,
  });
}
