import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/consts.dart';
import 'package:rtptun_app/data/data.dart';
import 'package:rtptun_app/data/repo/repository.dart';
import 'package:rtptun_app/data/src/hive_source.dart';
import 'package:rtptun_app/screens/splash.dart';
import 'package:rtptun_app/theme/data/hive_data.dart';
import 'package:rtptun_app/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(LocationAdapter());
  Hive.registerAdapter(AppThemeAdapter());
  Hive.registerAdapter(VPNEntityAdapter());
  await Hive.openBox(vpnBoxName);
  await Hive.openBox(appThemeBoxName);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) => ThemeNotifier(
            box: Hive.box(appThemeBoxName),
          ),
        ),
        ChangeNotifierProvider<Repository<VPNEntity>>(
          create: (BuildContext context) => Repository<VPNEntity>(
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
    return Consumer<ThemeNotifier>(
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
