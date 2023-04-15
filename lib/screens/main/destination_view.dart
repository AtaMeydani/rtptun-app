part of 'main.dart';

class _DestinationView extends StatefulWidget {
  final Widget destination;
  final VoidCallback onNavigation;
  final GlobalKey<NavigatorState> navigatorStateKey;
  const _DestinationView({
    Key? key,
    required this.destination,
    required this.onNavigation,
    required this.navigatorStateKey,
  }) : super(key: key);

  @override
  State<_DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<_DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [
        _ViewNavigatorObserver(widget.onNavigation),
      ],
      key: widget.navigatorStateKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return widget.destination;
        },
      ),
    );
  }
}

class _ViewNavigatorObserver extends NavigatorObserver {
  _ViewNavigatorObserver(this.onNavigation);

  final VoidCallback onNavigation;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigation();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onNavigation();
  }
}
