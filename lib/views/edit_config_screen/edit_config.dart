import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/config/config_controller.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';

class EditConfigScreen extends StatefulWidget {
  const EditConfigScreen({super.key});

  @override
  State<EditConfigScreen> createState() => _EditConfigScreenState();
}

class _EditConfigScreenState extends State<EditConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration file'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              context.read<ConfigController>().delete();
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: context.watch<ConfigController>().saving
                ? LoadingAnimationWidget.horizontalRotatingDots(
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  )
                : const Icon(Icons.check),
            onPressed: () async {
              if (await context.read<ConfigController>().saveChanges()) {
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: context.read<ConfigController>().formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          ListTile(
            title: const Text('Select Tunnel'),
            subtitle: Text(context.watch<ConfigController>().tunnel?.runtimeType.toString() ?? 'not selected'),
            onTap: () {
              _showDialog(context: context, items: {
                'RTP': () {
                  return context.read<ConfigController>().changeSelectedTunnel(RTP());
                },
                // 'No Tunnel': () {
                //   return context.read<ConfigController>().changeSelectedTunnel(null);
                // }
              });
            },
          ),
          ...context.watch<ConfigController>().tunnelFields,
          ListTile(
            title: const Text('Select VPN'),
            subtitle: Text(context.watch<ConfigController>().vpn?.runtimeType.toString() ?? 'not selected'),
            onTap: () {
              _showDialog(context: context, items: {
                'OpenVPN': () {
                  return context.read<ConfigController>().changeSelectedVPN(OpenVPNModel());
                },
                'No VPN': () {
                  return context.read<ConfigController>().changeSelectedVPN(null);
                }
              });
            },
          ),
          ...context.watch<ConfigController>().vpnFields,
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
