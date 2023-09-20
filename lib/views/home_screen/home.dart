import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rtptun_app/controllers/config/config_controller.dart';
import 'package:rtptun_app/controllers/home/home_screen_controller.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';
import 'package:rtptun_app/controllers/qr_scanner/qr_scanner_screen_controller.dart';
import 'package:rtptun_app/controllers/theme/theme_controller.dart';
import 'package:rtptun_app/models/theme/theme_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import '../components/logo.dart';
import '../edit_config_screen/edit_config.dart';
import '../qr_scanner_screen/qr_view.dart';

part 'connect_button.dart';
part 'drawer_list_tile.dart';
part 'config_list_tile.dart';

enum MorePopupMenuItem {
  deleteAllConfig,
}

enum AddPopupMenuItem {
  importConfigFromQRcode,
  importConfigFromClipboard,
  typeManually,
}

const githubUrl = 'https://github.com/AtaMeydani/rtptun-app';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    HomeScreenController homeScreenController = context.read<HomeScreenController>();
    Repository repository = context.read<Repository>();
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
              onTap: null,
            ),
            _CustomDrawerListTile(
              title: 'Share App',
              leadingIcon: Icons.share,
              onTap: () => Share.share('check out my app:\n$githubUrl'),
            ),
            const _CustomDrawerListTile(
              title: 'About',
              leadingIcon: Icons.info,
              onTap: null,
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
            onSelected: (AddPopupMenuItem value) async {
              switch (value) {
                case AddPopupMenuItem.typeManually:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<ConfigController>(
                        create: (context) => ConfigController(repository: repository),
                        child: const EditConfigScreen(),
                      ),
                    ),
                  );
                  break;
                case AddPopupMenuItem.importConfigFromQRcode:
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider<QrScannerScreenController>(
                        create: (context) => QrScannerScreenController(repository: repository),
                        child: QRViewScreen(),
                      ),
                    ),
                  );
                  break;
                case AddPopupMenuItem.importConfigFromClipboard:
                  ({bool success, String message}) res = await homeScreenController.importFromClipboard();
                  if (!res.success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        showCloseIcon: true,
                        content: Text(res.message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
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
            onSelected: (MorePopupMenuItem value) async {
              switch (value) {
                case MorePopupMenuItem.deleteAllConfig:
                  await repository.deleteAllConfigs();
                  break;
              }
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
