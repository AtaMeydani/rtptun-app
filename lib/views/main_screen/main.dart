import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/home/home_screen_controller.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';

import '../home_screen/home.dart';

part 'destination_view.dart';
part 'destinations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin<MainScreen> {
  int _currentIndex = 0;
  final List<int> _navBarHistory = [];
  List<GlobalKey>? _destinationKeys;
  List<GlobalKey<NavigatorState>>? _navigatorStateKeys;
  List<AnimationController>? _faders;
  AnimationController? _hide;

  @override
  void initState() {
    super.initState();

    _faders = _allDestinations.map<AnimationController>((_Destination destination) {
      return AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    }).toList();
    _faders?[_currentIndex].value = 1.0;
    _destinationKeys = List<GlobalKey>.generate(_allDestinations.length, (int index) => GlobalKey()).toList();
    _navigatorStateKeys =
        List<GlobalKey<NavigatorState>>.generate(_allDestinations.length, (int index) => GlobalKey<NavigatorState>())
            .toList();

    _hide = AnimationController(vsync: this, duration: kThemeAnimationDuration);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Scaffold(
          bottomNavigationBar: SizeTransition(
            sizeFactor: _hide!,
            axisAlignment: -1.0,
            child: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  _navBarHistory.remove(_currentIndex);
                  _navBarHistory.add(_currentIndex);
                  _currentIndex = index;
                });
              },
              currentIndex: _currentIndex,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.shifting,
              items: _allDestinations.map((_Destination destination) {
                return BottomNavigationBarItem(
                  icon: Icon(destination.icon),
                  backgroundColor: destination.color,
                  label: destination.title,
                );
              }).toList(),
            ),
          ),
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: _allDestinations.map((_Destination destination) {
                final Widget view = FadeTransition(
                  opacity: _faders![destination.index].drive(CurveTween(curve: Curves.fastOutSlowIn)),
                  child: KeyedSubtree(
                    key: _destinationKeys?[destination.index],
                    child: _DestinationView(
                      destination: destination.page,
                      onNavigation: () {
                        _hide?.forward();
                      },
                      navigatorStateKey: _navigatorStateKeys![destination.index],
                    ),
                  ),
                );

                if (destination.index == _currentIndex) {
                  _faders?[destination.index].forward(); // fade in
                  return view;
                } else {
                  _faders?[destination.index].reverse(); // fade out
                  if (_faders![destination.index].isAnimating) {
                    // While a view is fading out it’s wrapped with IgnorePointer, so that it doesn’t respond to user gestures.
                    return IgnorePointer(child: view);
                  }
                  return Offstage(child: view);
                }
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (AnimationController controller in _faders!) {
      controller.dispose();
    }
    _hide?.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // We use the notification’s depth to distinguish the topmost scrollable from nested ones.
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            _hide?.forward();
            break;
          case ScrollDirection.reverse:
            _hide?.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    final NavigatorState currentTabNavigatorState = _navigatorStateKeys![_currentIndex].currentState!;

    if (currentTabNavigatorState.canPop()) {
      currentTabNavigatorState.pop();
      return false;
    } else if (_navBarHistory.isNotEmpty) {
      setState(() {
        _currentIndex = _navBarHistory.last;
        _navBarHistory.removeLast();
      });
      return false;
    }
    return true;
  }
}
