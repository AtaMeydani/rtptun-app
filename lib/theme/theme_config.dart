part of 'theme_provider.dart';

class _AppThemeConfig {
  static const ColorScheme darkColorScheme = ColorScheme(
    background: Color(0xff1a1c1e),
    brightness: Brightness.dark,
    error: Color(0xffffb4ab),
    errorContainer: Color(0xff93000a),
    inversePrimary: Color(0xff0061a4),
    inverseSurface: Color(0xffe2e2e6),
    onBackground: Color(0xffe2e2e6),
    onError: Color(0xff690005),
    onErrorContainer: Color(0xffffb4ab),
    onInverseSurface: Color(0xff2f3033),
    onPrimary: Color(0xff003258),
    onPrimaryContainer: Color(0xffd1e4ff),
    onSecondary: Color(0xff253140),
    onSecondaryContainer: Color(0xffd7e3f7),
    onSurface: Color(0xffe2e2e6),
    onSurfaceVariant: Color(0xffc3c7cf),
    onTertiary: Color(0xff3b2948),
    onTertiaryContainer: Color(0xfff2daff),
    outline: Color(0xff8d9199),
    outlineVariant: Color(0xff43474e),
    primary: Color(0xff9ecaff),
    primaryContainer: Color(0xff00497d),
    secondary: Color(0xffbbc7db),
    secondaryContainer: Color(0xff3b4858),
    shadow: Color(0xff000000),
    surface: Color(0xff1a1c1e),
    surfaceTint: Color(0xff9ecaff),
    surfaceVariant: Color(0xff43474e),
    tertiary: Color(0xffd6bee4),
    tertiaryContainer: Color(0xff523f5f),
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    background: Color(0xfffdfcff),
    brightness: Brightness.light,
    error: Color(0xffba1a1a),
    errorContainer: Color(0xffffdad6),
    inversePrimary: Color(0xff9ecaff),
    inverseSurface: Color(0xff2f3033),
    onBackground: Color(0xff1a1c1e),
    onError: Color(0xffffffff),
    onErrorContainer: Color(0xff410002),
    onInverseSurface: Color(0xfff1f0f4),
    onPrimary: Color(0xffffffff),
    onPrimaryContainer: Color(0xff001d36),
    onSecondary: Color(0xffffffff),
    onSecondaryContainer: Color(0xff101c2b),
    onSurface: Color(0xff1a1c1e),
    onSurfaceVariant: Color(0xff43474e),
    onTertiary: Color(0xffffffff),
    onTertiaryContainer: Color(0xff251431),
    outline: Color(0xff73777f),
    outlineVariant: Color(0xffc3c7cf),
    primary: Color(0xff0061a4),
    primaryContainer: Color(0xffd1e4ff),
    secondary: Color(0xff535f70),
    secondaryContainer: Color(0xffd7e3f7),
    shadow: Color(0xff000000),
    surface: Color(0xfffdfcff),
    surfaceTint: Color(0xff0061a4),
    surfaceVariant: Color(0xffdfe2eb),
    tertiary: Color(0xff6b5778),
    tertiaryContainer: Color(0xfff2daff),
  );

  static TextTheme getTextTheme(ColorScheme colorScheme) {
    return const TextTheme(
      headlineMedium: TextStyle(
        letterSpacing: 2,
        fontFamily: 'Merriweather',
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ThemeData getThemeData(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.light:
        return ThemeData.from(
          colorScheme: lightColorScheme,
          textTheme: getTextTheme(lightColorScheme),
        );
      case AppTheme.dark:
        return ThemeData.from(
          colorScheme: darkColorScheme,
          textTheme: getTextTheme(darkColorScheme),
        );
      default:
        return ThemeData.from(
          colorScheme: darkColorScheme,
          textTheme: getTextTheme(darkColorScheme),
        );
    }
  }
}
