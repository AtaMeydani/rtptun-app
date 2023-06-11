import 'dart:async';
import 'package:flutter/material.dart';
import '../src/source.dart';

class Repository<T> with ChangeNotifier implements DataSource {
  Timer? _timer;
  int seconds = 0;

  final DataSource<T> localDataSource;

  // depedency injection
  Repository(this.localDataSource);

  @override
  connect() async {
    await localDataSource.connect();
    _startTimer();
  }

  @override
  disconnect() async {
    await localDataSource.disconnect();
    _stopTimer();
  }

  @override
  int get selectedItemIndex => localDataSource.selectedItemIndex;

  @override
  Future<void> setSelectedItemIndex(int index) async {
    await localDataSource.setSelectedItemIndex(index);
    notifyListeners();
  }

  Future<void> toggle() async {
    if (isConnected) {
      await disconnect();
    } else {
      await connect();
    }
    notifyListeners();
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

  @override
  bool get isConnected => localDataSource.isConnected;
}
