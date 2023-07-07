import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import 'package:rtptun_app/models/vpn/vpn_model.dart';

import '../data/repo/repository.dart';
import '../log/log_screen_controller.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/platform_invoke.dart';

const _notificationChannelId = 'my_foreground';

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

  Future<void> _initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId, // id
      'MY FOREGROUND SERVICE', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: false,
        isForegroundMode: true,

        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    /// OPTIONAL when use custom notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    Process? process;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    service.on('stopTunnel').listen((event) {
      process?.kill();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? path = preferences.getString('TunnelPath');
    List<String>? parameters = preferences.getStringList('TunnelParams');

    process = await Process.start(
      path!,
      parameters!,
      runInShell: true,
    );

    process.stdout.listen((event) {
      print(String.fromCharCodes(event));
      service.invoke(
        'tunnel_out',
        {
          "stdout": String.fromCharCodes(event),
        },
      );
    });

    process.stderr.listen((event) {
      print(String.fromCharCodes(event));
      service.invoke(
        'tunnel_error',
        {
          "stderror": String.fromCharCodes(event),
        },
      );
    });

    print(process.stdin);
    print(parameters.toString());
    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'COOL SERVICE',
            'Awesome ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _notificationChannelId,
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );

          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "Updated at ${DateTime.now()}",
          );
        }
      }

      /// you can see this log in logcat
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      // test using external plugin

      String? device;
      if (Platform.isAndroid) {
        device = 'Android';
      }

      if (Platform.isIOS) {
        device = 'IOS';
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "device": device,
        },
      );
    });
  }

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

  void stopTunnelService() {
    FlutterBackgroundService().invoke("stopTunnel");
  }

  void addLog(String log) {
    logScreenController.addLog(log);
  }

  void loadTimerState() {
    seconds = _currentTime - repository.timerState;
  }

  void _updateByteIn() async {
    Map<String, dynamic> status = (await engine.status()).toJson();
    logScreenController.updateByteIn(status.containsKey('byte_in') ? status['byte_in'] : '0');
  }

  void _updateByteOut() async {
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
    await _saveTunnelToSharedPreferences(repository.selectedTunnel);
    await _initializeService();
    startService();
    await _startVPN(repository.selectedTunnel.vpn);
    await repository.connect();
    await repository.saveTimerState(_currentTime);
    setAsBackground();
    startTimer();
  }

  Future<void> _saveTunnelToSharedPreferences(Tunnel tunnel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    switch (tunnel.runtimeType) {
      case RTP:
        RTP rtp = tunnel as RTP;

        String? nativeLibraryDir = await PlatformInvoke.getNativeLibraryDir();
        await preferences.setString('TunnelPath', '$nativeLibraryDir/librtptun.so');
        await preferences.setStringList('TunnelParams', [
          'client',
          '-i',
          rtp.localAddress!,
          '-l',
          rtp.localPort!,
          '-d',
          rtp.serverAddress!,
          '-p',
          rtp.serverPort!,
          '-k',
          rtp.secretKey!,
        ]);

        break;
      default:
    }
  }

  Future<void> _startVPN(VPN? vpn) async {
    switch (vpn.runtimeType) {
      case OpenVPNModel:
        vpn as OpenVPNModel;
        engine.connect(vpn.config!, "USA", username: vpn.username, password: vpn.password, certIsRequired: true);
        break;
      default:
    }
  }

  Future<void> _disconnect() async {
    engine.disconnect();
    stopTunnelService();
    stopService();
    await repository.disconnect();
    await repository.deleteTimerState();
    _stopTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateByteIn();
      _updateByteOut();
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
