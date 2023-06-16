import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rtptun_app/data/repo/repository.dart';

class HomeScreenController with ChangeNotifier {
  Timer? _timer;
  int seconds = 0;

  Future<void> toggle() async {
    if (isConnected) {
      await _disconnect();
    } else {
      await _connect();
    }
    notifyListeners();
  }

  Future<void> setSelectedItemIndex(int index) async {
    await Repository.instance.setSelectedItemIndex(index);
    notifyListeners();
  }

  Future<void> _connect() async {
    await Repository.instance.connect();
    _startTimer();
  }

  Future<void> _disconnect() async {
    await Repository.instance.disconnect();
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

  bool get isConnected => Repository.instance.isConnected;

  int get selectedItemIndex => Repository.instance.selectedItemIndex;
}
