import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

import '../data/repo/repository.dart';
import '../log/log_screen_controller.dart';

class MyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class HomeScreenController with ChangeNotifier {
  Timer? _timer;
  int seconds = 0;
  Repository repository;

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: MyTickerProvider(),
  );

  VpnStatus? status;
  VPNStage? stage;
  late final OpenVPN engine;
  bool granted = false;

  LogScreenController logScreenController;

  HomeScreenController({
    required this.repository,
    required this.logScreenController,
  });

  void addLog(String log) {
    logScreenController.addLog(log);
  }

  void updateByteIn() async {
    Map<String, dynamic> status = (await engine.status()).toJson();
    logScreenController.updateByteIn(status.containsKey('byte_in') ? status['byte_in'] : '0');
  }

  void updateByteOut() async {
    Map<String, dynamic> status = (await engine.status()).toJson();
    logScreenController.updateByteOut(status.containsKey('byte_out') ? status['byte_out'] : '0');
  }

  Future<({bool success, String message})> toggle() async {
    if (repository.isSelectedConfigInBox) {
      if (Platform.isAndroid) {
        granted = await engine.requestPermissionAndroid();
      }

      if (granted) {
        if (isConnected) {
          addLog('disconnecting...');
          _animationController.reverse();

          await _disconnect();
          addLog('disconnected');
          logScreenController.reset();
        } else {
          addLog('connecting...');
          _animationController.forward();
          await _connect();
          addLog('connected');
        }
        notifyListeners();
        return (success: true, message: 'success');
      } else {
        return (success: false, message: 'Request Permission');
      }
    } else {
      return (success: false, message: 'Please Select A Config Before Connect');
    }
  }

  Future<void> _connect() async {
    engine.connect(config, "USA", username: defaultVpnUsername, password: defaultVpnPassword, certIsRequired: true);
    await repository.connect();
    _startTimer();
  }

  Future<void> _disconnect() async {
    engine.disconnect();

    await repository.disconnect();
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateByteIn();
      updateByteOut();
      seconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    seconds = 0;
  }

  bool get isConnected => repository.isConnected;

  AnimationController get animationController => _animationController;
}

const String defaultVpnUsername = "";
const String defaultVpnPassword = "";
String config = '''''';
