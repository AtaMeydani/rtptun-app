part of 'home.dart';

class _CustomFloatingActionButton extends StatelessWidget {
  const _CustomFloatingActionButton();

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    HomeScreenController homeScreenController = context.read<HomeScreenController>();

    return Selector<HomeScreenController, bool>(
        selector: (_, HomeScreenController vpn) => vpn.isConnected,
        builder: (BuildContext context, isConnected, Widget? child) {
          return FloatingActionButton.extended(
            backgroundColor: isConnected ? themeData.colorScheme.primary : themeData.colorScheme.secondary,
            extendedPadding: const EdgeInsets.all(20),
            extendedIconLabelSpacing: 10,
            icon: RotationTransition(
              turns: homeScreenController.connectButtonAnimation,
              child: Icon(
                isConnected ? Icons.power_settings_new : Icons.power_off,
              ),
            ),
            onPressed: () {
              homeScreenController.toggle().then((({bool success, String message}) value) {
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
              StreamBuilder(
                stream: FlutterBackgroundService().on('timer'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  homeScreenController.updateBytesInOut();
                  print('object');
                  String time = Duration(seconds: snapshot.data!['time']).toString().split('.')[0];
                  return Text(time);
                },
              ),
            ]),
          );
        });
  }
}
