import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import 'package:rtptun_app/models/vpn/vpn_model.dart';

import '../data/repo/repository.dart';
import '../log/log_screen_controller.dart';

import 'package:flutter_background_service/flutter_background_service.dart';

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

  void startService() {
    FlutterBackgroundService().startService();
  }

  void stopService() {
    FlutterBackgroundService().invoke("stopService");
  }

  void setAsBackground() {
    FlutterBackgroundService().invoke("setAsBackground");
  }

  void setAsForeground() {
    FlutterBackgroundService().invoke("setAsForeground");
  }

  void addLog(String log) {
    logScreenController.addLog(log);
  }

  void loadTimerState() {
    seconds = _currentTime - repository.timerState;
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
    Tunnel tunnel = repository.selectedTunnel;
    VPN? vpn = tunnel.vpn;
    if (vpn != null) {
      if (vpn is OpenVPNModel && vpn.config != null) {
        engine.connect(vpn.config!, "USA", username: vpn.username, password: vpn.password, certIsRequired: true);
      }
    }
    await repository.connect();
    await repository.saveTimerState(_currentTime);
    startService();
    setAsBackground();
    startTimer();
  }

  Future<void> _disconnect() async {
    engine.disconnect();

    await repository.disconnect();
    await repository.deleteTimerState();
    stopService();
    _stopTimer();
  }

  void startTimer() {
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

  int get _currentTime => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  bool get isConnected => repository.isConnected;

  AnimationController get animationController => _animationController;

  @override
  void dispose() {
    if (isConnected) {
      setAsForeground();
    } else {
      _timer?.cancel();
      repository.deleteTimerState();
    }

    super.dispose();
  }
}
