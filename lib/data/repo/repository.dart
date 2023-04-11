import 'dart:async';
import 'package:flutter/material.dart';
import '../src/source.dart';

class Repository<T> with ChangeNotifier implements DataSource {
  bool isConnected = false;
  Timer? _timer;
  int seconds = 0;

  final DataSource<T> localDataSource;

  // depedency injection
  Repository(this.localDataSource);

  @override
  connect() async {
    isConnected = true;
    await localDataSource.connect();
    notifyListeners();
    _startTimer();
  }

  @override
  disconnect() async {
    isConnected = false;
    await localDataSource.disconnect();
    _stopTimer();
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;
      notifyListeners();
    });
  }

  _stopTimer() {
    _timer?.cancel();
    seconds = 0;
    notifyListeners();
  }
}
