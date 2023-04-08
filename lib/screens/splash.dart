import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'components/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: themeData.colorScheme.background,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: themeData.colorScheme.background,
            statusBarBrightness: themeData.colorScheme.brightness,
          ),
        ),
      ),
      backgroundColor: themeData.colorScheme.background,
      body: Stack(children: [
        const Center(
          child: Logo(),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: LoadingAnimationWidget.fourRotatingDots(
            color: themeData.colorScheme.primary,
            size: 50,
          ),
        )
      ]),
    );
  }
}
