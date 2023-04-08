import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/hive_data.dart';
part 'theme_config.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _key = "theme";
  final Box box;

  ThemeNotifier({required this.box});

  setTheme(AppTheme appTheme) async {
    await box.put(_key, appTheme);
    notifyListeners();
  }

  ThemeData getTheme() {
    return _AppThemeConfig.getThemeData(
      box.get(
        _key,
        defaultValue: AppTheme.light,
      ),
    );
  }
}
