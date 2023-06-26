import 'package:flutter/material.dart';

class LogScreenController with ChangeNotifier {
  final List<String> logs = [];
  String byteIn = '0';
  String byteOut = '0';

  void addLog(String log) {
    logs.add(log);
    notifyListeners();
  }

  void clear() {
    logs.clear();
    notifyListeners();
  }

  void updateByteIn(String bytes) {
    byteIn = bytes;
    notifyListeners();
  }

  void updateByteOut(String bytes) {
    byteOut = bytes;
    notifyListeners();
  }

  void reset() {
    updateByteIn('0');
    updateByteOut('0');
    clear();
  }

  get len => logs.length;
}
