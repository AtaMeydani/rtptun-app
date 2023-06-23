import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/config/config_controller.dart';

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
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Form(
          key: context.read<ConfigController>().formKey,
          child: Column(
            children: context.read<ConfigController>().fields,
          ),
        ),
      ),
    );
  }
}
