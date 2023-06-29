import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../components/logo.dart';
import '../main_screen/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: themeData.colorScheme.primary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: themeData.colorScheme.primary,
            statusBarBrightness: themeData.colorScheme.brightness,
          ),
        ),
      ),
      backgroundColor: themeData.colorScheme.primary,
      body: Stack(children: [
        const Center(
          child: Logo(),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: LoadingAnimationWidget.fourRotatingDots(
            color: themeData.colorScheme.onPrimary,
            size: 50,
          ),
        )
      ]),
    );
  }
}
