import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_ip_address/get_ip_address.dart';

class LogScreenController with ChangeNotifier {
  final List<String> logs = [];
  final scrollController = ScrollController();
  static const int _kilobyte = 1024;
  static const int _megabyte = _kilobyte * 1024;
  String byteIn = '0 B';
  String byteOut = '0 B';

  LogScreenController() {
    FlutterBackgroundService().on('tunnel_out').listen((event) {
      addLog(event?['stdout'] ?? 'Service Tunnel STDOUT Error');
    });

    FlutterBackgroundService().on('tunnel_error').listen((event) {
      addLog(event?['stderr'] ?? 'Service Tunnel STDERR Error');
    });
  }

  void addLog(String log) async {
    logs.add(log);
    notifyListeners();
    _jump();
  }

  void updateByteIn(String bytes) {
    byteIn = _formatBytes(int.parse(bytes));
    notifyListeners();
  }

  void updateByteOut(String bytes) {
    byteOut = _formatBytes(int.parse(bytes));
    notifyListeners();
  }

  void reset() {
    updateByteIn('0');
    updateByteOut('0');
    _clear();
  }

  void checkIP() async {
    try {
      /// Initialize Ip Address
      var ipAddress = IpAddress(type: RequestType.json);

      /// Get the IpAddress based on requestType.
      dynamic data = await ipAddress.getIpAddress();
      addLog(data.toString());
    } on IpAddressException catch (exception) {
      /// Handle the exception.
      addLog(exception.message);
    }
  }

  void _clear() {
    logs.clear();
    notifyListeners();
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";

    if (bytes < _kilobyte) {
      return "$bytes B";
    } else if (bytes < _megabyte) {
      double kb = bytes / _kilobyte;
      return "${kb.toStringAsFixed(2)} KB";
    } else {
      double mb = bytes / _megabyte;
      return "${mb.toStringAsFixed(2)} MB";
    }
  }

  get len => logs.length;
}
