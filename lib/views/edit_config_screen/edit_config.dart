import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/config/config_controller.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';

class EditConfigScreen extends StatelessWidget {
  const EditConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigController configController = context.read<ConfigController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration file'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              configController.delete();
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: Selector<ConfigController, bool>(
              builder: (context, saving, child) {
                return saving
                    ? LoadingAnimationWidget.horizontalRotatingDots(
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      )
                    : const Icon(Icons.check);
              },
              selector: (_, ConfigController configController) => configController.saving,
            ),
            onPressed: () async {
              if (await configController.saveChanges()) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: configController.formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          ListTile(
            title: const Text('Select Tunnel'),
            subtitle: Selector<ConfigController, String>(
              builder: (context, value, child) {
                return Text(value);
              },
              selector: (_, ConfigController controller) => controller.tunnel?.runtimeType.toString() ?? 'not selected',
            ),
            onTap: () {
              _showDialog(context: context, items: {
                'RTP': () {
                  return configController.changeSelectedTunnel(RTP());
                },
              });
            },
          ),
          Selector<ConfigController, List<Widget>>(
            builder: (context, value, child) {
              return Column(
                children: value,
              );
            },
            selector: (_, ConfigController controller) => controller.tunnelFields,
          ),
          Selector<ConfigController, bool>(
            selector: (_, ConfigController configController) => configController.tunnel != null,
            builder: (context, tunnelIsSelected, child) {
              return Stack(
                children: [
                  ListTile(
                    title: const Text('Select VPN'),
                    subtitle: Selector<ConfigController, String>(
                      builder: (context, value, child) {
                        return Text(value);
                      },
                      selector: (_, ConfigController controller) =>
                          controller.vpn?.runtimeType.toString() ?? 'not selected',
                    ),
                    onTap: () {
                      _showDialog(context: context, items: {
                        'OpenVPN': () {
                          return configController.changeSelectedVPN(OpenVPNModel());
                        },
                        'No VPN': () {
                          return configController.changeSelectedVPN(null);
                        }
                      });
                    },
                  ),
                  tunnelIsSelected
                      ? const SizedBox.shrink()
                      : const Positioned.fill(
                          child: AbsorbPointer(),
                        ),
                ],
              );
            },
          ),
          Selector<ConfigController, List<Widget>>(
            builder: (context, value, child) {
              return Column(
                children: value,
              );
            },
            selector: (_, ConfigController controller) => controller.vpnFields,
          ),
        ]),
      ),
    );
  }
}

void _showDialog({required BuildContext context, required Map<String, void Function()> items}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select an item'),
        content: SingleChildScrollView(
            child: ListBody(
          children: items.entries.map((item) {
            return InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.key),
              ),
              onTap: () {
                item.value();
                Navigator.pop(context);
              },
            );
          }).toList(),
        )),
      );
    },
  );
}
