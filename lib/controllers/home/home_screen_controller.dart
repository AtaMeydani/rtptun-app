import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:rtptun_app/controllers/data/repo/repository.dart';

class MyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class HomeScreenController with ChangeNotifier {
  Timer? _timer;
  int seconds = 0;
  Repository repository;

  HomeScreenController({required this.repository});

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: MyTickerProvider(),
  );

  AnimationController get animationController => _animationController;

  Future<({bool success, String message})> toggle() async {
    if (repository.isSelectedConfigInBox) {
      if (isConnected) {
        _animationController.reverse();
        await _disconnect();
      } else {
        _animationController.forward();
        await _connect();
      }
      notifyListeners();

      return (success: true, message: 'success');
    } else {
      return (success: false, message: 'Please Select A Config Before Connect');
    }
  }

  Future<void> _connect() async {
    await repository.connect();
    _startTimer();
  }

  Future<void> _disconnect() async {
    await repository.disconnect();
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    seconds = 0;
  }

  bool get isConnected => repository.isConnected;
}
