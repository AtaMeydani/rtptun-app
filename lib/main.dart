import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';
import 'package:rtptun_app/controllers/data/src/hive_source.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';

import 'controllers/theme/theme_controller.dart';
import 'models/theme/theme_model.dart';
import 'views/splash_screen/splash.dart';

const vpnBoxName = 'VPNBox';
const appThemeBoxName = 'AppThemeBox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(RTPAdapter());
  Hive.registerAdapter(AppThemeAdapter());

  await Hive.openBox(vpnBoxName);
  await Hive.openBox(appThemeBoxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (context) => ThemeController(
            box: Hive.box(appThemeBoxName),
          ),
        ),
        ChangeNotifierProvider<Repository>(
          create: (BuildContext context) => Repository(
            HiveDataSource(
              Hive.box(vpnBoxName),
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (BuildContext context, themeManager, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          theme: themeManager.getTheme(),
        );
      },
    );
  }
}
