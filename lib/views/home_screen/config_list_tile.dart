part of 'home.dart';

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
    HomeScreenController homeScreenController = context.read<HomeScreenController>();
    Repository repository = context.read<Repository>();

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
        onTap: () async {
          ({String message, bool success}) res = await repository.setSelectedTunnel(config);
          if (!res.success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true,
                content: Text(res.message),
                duration: const Duration(seconds: 2),
              ),
            );
          }
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
              onPressed: () {
                _shareDialog(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider<ConfigController>(
                      create: (context) => ConfigController(
                        repository: repository,
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
                if (isSelected && homeScreenController.isConnected) return;
                repository.delete(config);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Share Config')),
          content: const Text('Select a method to share:'),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _grcodeDialog(context);
              },
              child: const Text('QRcode'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Clipboard.setData(ClipboardData(text: json.encode(config.getJsonConfiguration())));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Copied to clipboard'),
                ));
              },
              child: const Text('Export to clipboard'),
            ),
          ],
        );
      },
    );
  }

  void _grcodeDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('QR Code')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: const EdgeInsets.all(10),
          actionsPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(20),
          content: SizedBox(
            height: size.width,
            width: size.width,
            child: QrImageView(
              // ignore: deprecated_member_use
              foregroundColor: Theme.of(context).colorScheme.primary,
              data: json.encode(config.toJson()),

              version: QrVersions.auto,
              size: 320,
              constrainErrorBounds: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
              ),
              errorStateBuilder: (cxt, err) {
                return const Center(
                  child: Text(
                    'Uh oh! Something went wrong...',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          scrollable: true,
        );
      },
    );
  }
}
