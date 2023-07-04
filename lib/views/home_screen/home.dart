import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/config/config_controller.dart';
import 'package:rtptun_app/controllers/home/home_screen_controller.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';
import 'package:rtptun_app/controllers/theme/theme_controller.dart';
import 'package:rtptun_app/models/theme/theme_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';

import 'dart:math' as math;

import '../components/logo.dart';
import '../edit_config_screen/edit_config.dart';

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
  VpnStatus? status;
  VPNStage? stage;
  bool granted = false;

  @override
  void initState() {
    context.read<HomeScreenController>().engine = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          status = data;
        });
      },
      onVpnStageChanged: (data, raw) {
        setState(() {
          stage = data;
        });
      },
    );

    context.read<HomeScreenController>().engine.initialize(
          groupIdentifier: "group.com.laskarmedia.vpn",
          providerBundleIdentifier: "id.laskarmedia.openvpnFlutterExample.VPNExtension",
          localizedDescription: "VPN by Nizwar",
          lastStage: (stage) {
            context.read<HomeScreenController>().addLog(stage.toString());
          },
          lastStatus: (status) {
            context.read<HomeScreenController>().addLog(status.toJson().toString());
          },
        );
    super.initState();
  }

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
                    child: Consumer<ThemeController>(
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
              switch (value) {
                case AddPopupMenuItem.typeManually:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<ConfigController>(
                        create: (context) => ConfigController(repository: context.read<Repository>()),
                        child: const EditConfigScreen(),
                      ),
                    ),
                  );
                  break;
                case AddPopupMenuItem.importConfigFromQRcode:
                  // TODO: Handle this case.
                  break;
                case AddPopupMenuItem.importConfigFromClipboard:
                  // TODO: Handle this case.
                  break;
              }
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
            },
          ),
        ],
      ),
      backgroundColor: themeData.colorScheme.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const _CustomFloatingActionButton(),
      body: SafeArea(
        child: Selector<Repository, List<Tunnel>>(
          selector: (_, Repository repository) => repository.configs,
          builder: (BuildContext context, List<Tunnel> configs, Widget? child) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: configs.length,
              itemBuilder: (context, index) {
                return Selector<Repository, ({bool isSelected, ({String title, String subtitle}) info})>(
                    selector: (_, Repository repository) => (
                          isSelected: repository.selectedTunnel == configs[index],
                          info: repository.getTunnelListTileInfo(index)
                        ),
                    builder: (BuildContext context, ({bool isSelected, ({String title, String subtitle}) info}) record,
                        Widget? child) {
                      return _CustomConfigListTile(
                        isSelected: record.isSelected,
                        info: record.info,
                        config: configs[index],
                      );
                    });
              },
            );
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
  final bool isSelected;
  final ({String title, String subtitle}) info;
  final Tunnel config;
  static const radius = 20.0;

  const _CustomConfigListTile({
    required this.isSelected,
    required this.info,
    required this.config,
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
          context.read<Repository>().setSelectedTunnel(config);
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
        title: Text(info.title),
        subtitle: Text(
          info.subtitle,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider<ConfigController>(
                      create: (context) => ConfigController(
                        repository: context.read<Repository>(),
                        tunnel: config,
                      ),
                      child: const EditConfigScreen(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                if (isSelected && context.read<HomeScreenController>().isConnected) return;
                context.read<Repository>().delete(config);
              },
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

class _CustomFloatingActionButtonState extends State<_CustomFloatingActionButton> {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  late final AnimationController _animationController = context.read<HomeScreenController>().animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    context.read<HomeScreenController>().loadTimerState();
    if (context.read<HomeScreenController>().isConnected) {
      context.read<HomeScreenController>().startTimer();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Selector<HomeScreenController, bool>(
        selector: (_, HomeScreenController vpn) => vpn.isConnected,
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
              context.read<HomeScreenController>().toggle().then((({bool success, String message}) value) {
                if (!value.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      // margin: EdgeInsets.only(bottom: 80),
                      showCloseIcon: true,
                      content: Text(value.message),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            label: Column(children: [
              Text(isConnected ? 'Disconnect' : 'Tap to Connect'),
              Selector<HomeScreenController, int>(
                selector: (_, HomeScreenController vpn) => vpn.seconds,
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
