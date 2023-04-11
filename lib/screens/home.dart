import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/data/data.dart';
import 'package:rtptun_app/data/repo/repository.dart';
import 'package:rtptun_app/screens/components/logo.dart';
import 'package:rtptun_app/theme/data/hive_data.dart';
import 'package:rtptun_app/theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeData.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  const Logo(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Consumer<ThemeNotifier>(
                      builder: (BuildContext context, themeNotifier, Widget? child) {
                        IconData iconData;
                        switch (themeNotifier.getThemeName()) {
                          case AppTheme.light:
                            iconData = Icons.wb_sunny;
                            break;
                          case AppTheme.dark:
                            iconData = Icons.nightlight_round;
                            break;
                          default:
                            iconData = Icons.question_mark;
                        }
                        return IconButton(
                          onPressed: () {
                            themeNotifier.changeTheme();
                          },
                          icon: Icon(
                            iconData,
                            color: themeData.colorScheme.onPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const _CustomListTile(
              title: 'Change Language',
              leadingIcon: Icons.translate,
            ),
            const _CustomListTile(
              title: 'Share App',
              leadingIcon: Icons.share,
            ),
            const _CustomListTile(
              title: 'About',
              leadingIcon: Icons.info,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.primary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: themeData.colorScheme.primary,
          statusBarBrightness: themeData.colorScheme.brightness,
        ),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Icon(
                    Icons.segment,
                    color: themeData.colorScheme.onPrimary,
                    size: 26,
                  ),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          const Expanded(
            child: Logo(),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: themeData.colorScheme.onPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: themeData.colorScheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _ConnectButton(size: size),
                  const SizedBox(
                    height: 12,
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: size.height * 0.14,
                    height: size.height * 0.030,
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Selector<Repository<VPNEntity>, bool>(
                      selector: (_, Repository<VPNEntity> vpn) => vpn.isConnected,
                      builder: (BuildContext context, isConnected, Widget? child) {
                        return Text(
                          isConnected ? 'Connected' : 'Not Connected',
                          style: themeData.textTheme.labelLarge!.copyWith(
                            fontSize: size.height * 0.015,
                            color: themeData.colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Selector<Repository<VPNEntity>, int>(
                    selector: (_, Repository<VPNEntity> vpn) => vpn.seconds,
                    builder: (BuildContext context, vpn, Widget? child) {
                      Duration duration = Duration(seconds: vpn);
                      final minutes = twoDigits(duration.inMinutes.remainder(60));
                      final seconds = twoDigits(duration.inSeconds.remainder(60));
                      final hours = twoDigits(duration.inHours.remainder(60));
                      return Text(
                        '$hours : $minutes : $seconds',
                        style: TextStyle(color: Colors.white, fontSize: size.height * 0.03),
                      );
                    },
                  ),
                  const _ChangeLocationButton()
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.1,
                maxChildSize: 0.5,
                builder: (_, ScrollController scrollController) => Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          size: 48,
                          color: themeData.colorScheme.primary,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _LocationInfo(size: size),
                        const SizedBox(
                          height: 15,
                        ),
                        _SpeedInfo(size: size),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(size.height),
      onTap: () {
        final Repository<VPNEntity> vpn = context.read<Repository<VPNEntity>>();
        if (vpn.isConnected) {
          vpn.disconnect();
        } else {
          vpn.connect();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: themeData.colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary.withOpacity(.5),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: size.height * 0.13,
            height: size.height * 0.13,
            decoration: BoxDecoration(
              color: themeData.colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new,
                    size: size.height * 0.035,
                    color: themeData.colorScheme.primary,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Selector<Repository<VPNEntity>, bool>(
                    selector: (_, Repository<VPNEntity> vpn) => vpn.isConnected,
                    builder: (BuildContext context, vpn, Widget? child) {
                      return Text(
                        vpn ? 'Disconnect' : 'Tap to Connect',
                        style: TextStyle(
                          fontSize: size.height * 0.013,
                          fontWeight: FontWeight.w500,
                          color: themeData.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeLocationButton extends StatelessWidget {
  const _ChangeLocationButton();

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ServerLocation()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: themeData.colorScheme.secondary,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_pin,
              color: themeData.colorScheme.onSecondary,
            ),
            Text(
              ' Change Location',
              style: themeData.textTheme.titleMedium!.copyWith(
                color: themeData.colorScheme.onSecondary,
              ),
            ),
            const Spacer(),
            Container(
              width: 25,
              decoration: BoxDecoration(
                color: themeData.colorScheme.onSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 25,
                color: themeData.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedInfo extends StatelessWidget {
  const _SpeedInfo({
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Container(
              width: size.height * 0.07,
              height: size.height * 0.07,
              decoration: BoxDecoration(
                color: themeData.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward,
                color: themeData.colorScheme.background,
                size: 30,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '15,47',
                  style: themeData.textTheme.titleMedium!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                Text(
                  ' mbps',
                  style: themeData.textTheme.titleSmall!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'DOWNLOAD',
              style: themeData.textTheme.titleSmall!.copyWith(
                color: themeData.colorScheme.onBackground.withOpacity(.3),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: size.height * 0.07,
              height: size.height * 0.07,
              decoration: BoxDecoration(
                color: themeData.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward,
                color: themeData.colorScheme.background,
                size: 30,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text(
                  '250',
                  style: themeData.textTheme.titleMedium!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                Text(
                  ' mbps',
                  style: themeData.textTheme.titleSmall!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'UPLOAD',
              style: themeData.textTheme.titleSmall!.copyWith(
                color: themeData.colorScheme.onBackground.withOpacity(.3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationInfo extends StatelessWidget {
  const _LocationInfo({
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              height: size.height * 0.07,
              width: size.height * 0.07,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/england.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'UK',
              style: themeData.textTheme.titleMedium!.copyWith(
                color: themeData.colorScheme.onBackground,
              ),
            ),
          ],
        ),
        Column(
          children: [
            Container(
              width: size.height * 0.07,
              height: size.height * 0.07,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.equalizer_rounded,
                color: themeData.colorScheme.background,
                size: 30,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10',
                  style: themeData.textTheme.titleMedium!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                Text(
                  ' ms',
                  style: themeData.textTheme.titleSmall!.copyWith(
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'PING',
              style: themeData.textTheme.titleSmall!.copyWith(
                color: themeData.colorScheme.onBackground.withOpacity(.3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  const _CustomListTile({
    required this.title,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeLanguage()));
      },
      leading: Icon(
        leadingIcon,
        size: 18,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
      ),
    );
  }
}
