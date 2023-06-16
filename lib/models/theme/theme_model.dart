import 'package:hive_flutter/hive_flutter.dart';
part 'theme_model.g.dart';

@HiveType(typeId: 0)
enum AppTheme {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
}
