import 'package:hive_flutter/hive_flutter.dart';
part 'hive_data.g.dart';

@HiveType(typeId: 1)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
}
