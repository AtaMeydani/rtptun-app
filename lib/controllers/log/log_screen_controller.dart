import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_ip_address/get_ip_address.dart';

class LogScreenController with ChangeNotifier {
  final List<String> logs = [];
  final scrollController = ScrollController();
  String byteIn = '0';
  String byteOut = '0';

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
    jump();
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

  void jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
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

  get len => logs.length;
}
