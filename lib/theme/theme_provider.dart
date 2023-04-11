import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/hive_data.dart';
part 'theme_config.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _key = "theme";
  final Box box;

  ThemeNotifier({required this.box});

  ThemeData getTheme() {
    return _AppThemeConfig.getThemeData(
      getThemeName(),
    );
  }

  changeTheme() {
    AppTheme currentAppTheme = getThemeName();
    switch (currentAppTheme) {
      case AppTheme.light:
        _setTheme(AppTheme.dark);
        break;
      case AppTheme.dark:
        _setTheme(AppTheme.light);
        break;
      default:
    }
  }

  AppTheme getThemeName() {
    return box.get(
      _key,
      defaultValue: AppTheme.light,
    );
  }

  _setTheme(AppTheme appTheme) async {
    await box.put(_key, appTheme);
    notifyListeners();
  }
}
