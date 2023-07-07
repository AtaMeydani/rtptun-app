import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'controllers/data/repo/repository.dart';
import 'controllers/data/src/hive_source.dart';
import 'models/open_vpn/openvpn_model.dart';
import 'models/rtp/rtp_model.dart';
import 'models/tunnel/tunnel_model.dart';
import 'models/vpn/vpn_model.dart';
import 'controllers/theme/theme_controller.dart';
import 'models/theme/theme_model.dart';
import 'views/splash_screen/splash.dart';

const _vpnBoxName = 'VPNBox';
const _appThemeBoxName = 'AppThemeBox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(TunnelAdapter());
  Hive.registerAdapter(RTPAdapter());
  Hive.registerAdapter(VPNAdapter());
  Hive.registerAdapter(OpenVPNModelAdapter());
  Hive.registerAdapter(AppThemeAdapter());

  await Hive.openBox(_vpnBoxName);
  await Hive.openBox(_appThemeBoxName);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeController>(
          create: (context) => ThemeController(
            box: Hive.box(_appThemeBoxName),
          ),
        ),
        ChangeNotifierProvider<Repository>(
          create: (BuildContext context) => Repository(
            HiveDataSource(
              Hive.box(_vpnBoxName),
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
