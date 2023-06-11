import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/data/data.dart';
import 'package:rtptun_app/data/repo/repository.dart';
import 'dart:math' as math;

import '../theme/data/hive_data.dart';
import '../theme/theme_provider.dart';
import 'components/logo.dart';

enum MorePopupMenuItem {
  serviceRestart,
  deleteAllConfig,
}

enum AddPopupMenuItem {
  importConfigFromQRcode,
  importConfigFromClipboard,
  typeManually,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<VPNEntity> items = [
    VPNEntity(remark: 'UK', address: 'uk.mrgray.xyz', port: 6969, protocol: Protocol.rtp),
    VPNEntity(remark: 'UK', address: 'uk.mrgray.xyz', port: 6969, protocol: Protocol.rtp),
    VPNEntity(remark: 'UK', address: 'uk.mrgray.xyz', port: 6969, protocol: Protocol.rtp),
    VPNEntity(remark: 'UK', address: 'uk.mrgray.xyz', port: 6969, protocol: Protocol.rtp),
  ];

  String dropdownValue = 'One';

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
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
            const _CustomDrawerListTile(
              title: 'Change Language',
              leadingIcon: Icons.translate,
            ),
            const _CustomDrawerListTile(
              title: 'Share App',
              leadingIcon: Icons.share,
            ),
            const _CustomDrawerListTile(
              title: 'About',
              leadingIcon: Icons.info,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 5,
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
          PopupMenuButton<AddPopupMenuItem>(
            icon: const Icon(Icons.add),
            // offset: Offset(0, 50),
            itemBuilder: (BuildContext context) =>
                AddPopupMenuItem.values.map<PopupMenuItem<AddPopupMenuItem>>((AddPopupMenuItem value) {
              return PopupMenuItem<AddPopupMenuItem>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onSelected: (AddPopupMenuItem value) {
              // Do something when a menu item is selected.
              print('Selected: $value');
            },
          ),
          PopupMenuButton<MorePopupMenuItem>(
            // offset: Offset(0, 50),
            itemBuilder: (BuildContext context) =>
                MorePopupMenuItem.values.map<PopupMenuItem<MorePopupMenuItem>>((MorePopupMenuItem value) {
              return PopupMenuItem<MorePopupMenuItem>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onSelected: (MorePopupMenuItem value) {
              // Do something when a menu item is selected.
              print('Selected: $value');
            },
          ),
        ],
      ),
      backgroundColor: themeData.colorScheme.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const _CustomFloatingActionButton(),
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Selector<Repository<VPNEntity>, bool>(
                selector: (_, Repository<VPNEntity> vpn) => vpn.selectedItemIndex == index,
                builder: (BuildContext context, isSelected, Widget? child) {
                  return _CustomConfigListTile(
                    vpnEntity: items[index],
                    isSelected: isSelected,
                    index: index,
                  );
                });
          },
        ),
      ),
    );
  }
}

class _CustomDrawerListTile extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  const _CustomDrawerListTile({
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

class _CustomConfigListTile extends StatelessWidget {
  final VPNEntity vpnEntity;
  final bool isSelected;
  final int index;
  static const radius = 20.0;

  const _CustomConfigListTile({
    required this.vpnEntity,
    required this.isSelected,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        visualDensity: VisualDensity.standard,
        selectedTileColor: themeData.colorScheme.secondaryContainer,
        selected: isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        minLeadingWidth: 10,
        titleTextStyle: themeData.textTheme.titleSmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        onTap: () {
          final Repository<VPNEntity> vpn = context.read<Repository<VPNEntity>>();
          vpn.setSelectedItemIndex(index);
        },
        leading: Container(
          width: 10,
          decoration: BoxDecoration(
            color: isSelected ? themeData.colorScheme.primary : themeData.colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
            ),
          ),
        ),
        title: Text(
          vpnEntity.remark,
        ),
        subtitle: Text(
          '${vpnEntity.address} : ${vpnEntity.port}',
          style: themeData.textTheme.titleSmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const Edit()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomFloatingActionButton extends StatefulWidget {
  const _CustomFloatingActionButton();

  @override
  // ignore: library_private_types_in_public_api
  _CustomFloatingActionButtonState createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<_CustomFloatingActionButton> with SingleTickerProviderStateMixin {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Selector<Repository<VPNEntity>, bool>(
        selector: (_, Repository<VPNEntity> vpn) => vpn.isConnected,
        builder: (BuildContext context, isConnected, Widget? child) {
          return FloatingActionButton.extended(
            backgroundColor: isConnected ? themeData.colorScheme.primary : themeData.colorScheme.secondary,
            extendedPadding: const EdgeInsets.all(20),
            extendedIconLabelSpacing: 10,
            icon: RotationTransition(
              turns: _animation,
              child: Icon(
                isConnected ? Icons.power_settings_new : Icons.power_off,
              ),
            ),
            onPressed: () {
              final Repository<VPNEntity> vpn = context.read<Repository<VPNEntity>>();
              vpn.toggle();
              if (_animationController.status == AnimationStatus.completed) {
                _animationController.reverse();
              } else {
                _animationController.forward();
              }
            },
            label: Column(children: [
              Text(isConnected ? 'Disconnect' : 'Tap to Connect'),
              Selector<Repository<VPNEntity>, int>(
                selector: (_, Repository<VPNEntity> vpn) => vpn.seconds,
                builder: (BuildContext context, vpn, Widget? child) {
                  Duration duration = Duration(seconds: vpn);
                  final minutes = twoDigits(duration.inMinutes.remainder(60));
                  final seconds = twoDigits(duration.inSeconds.remainder(60));
                  final hours = twoDigits(duration.inHours.remainder(60));
                  return Text(
                    '$hours : $minutes : $seconds',
                  );
                },
              ),
            ]),
          );
        });
  }
}
