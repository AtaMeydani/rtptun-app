import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:rtptun_app/models/open_vpn/openvpn_model.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import 'package:rtptun_app/models/vpn/vpn_model.dart';

import '../data/repo/repository.dart';
import '../log/log_screen_controller.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/platform_invoke.dart';

const _notificationChannelId = 'my_foreground';

class _MyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class HomeScreenController with ChangeNotifier {
  Repository repository;

  final AnimationController _connectButtonAnimationController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: _MyTickerProvider(),
  );

  late final OpenVPN engine;
  bool granted = false;

  LogScreenController logScreenController;

  VPNStage? lastStage;
  late Animation<double> connectButtonAnimation =
      Tween<double>(begin: 0, end: 1).animate(_connectButtonAnimationController);

  HomeScreenController({
    required this.repository,
    required this.logScreenController,
  }) {
    engine = OpenVPN(
      onVpnStageChanged: (stage, raw) {
        if (lastStage != stage) {
          _addLog(stage.toString());
          lastStage = stage;
        }
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.laskarmedia.vpn",
      providerBundleIdentifier: "id.laskarmedia.openvpnFlutterExample.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        if (lastStage != stage) {
          _addLog(stage.toString());
          lastStage = stage;
        }
      },
    );

    _initializeService();
    _setAsBackground();
  }

  void updateBytesInOut() async {
    if (engine.initialized && await engine.isConnected()) {
      Map<String, dynamic> vpnStatus = (await engine.status()).toJson();
      logScreenController.updateByteIn(vpnStatus.containsKey('byte_in') ? vpnStatus['byte_in'] : '0');
      logScreenController.updateByteOut(vpnStatus.containsKey('byte_out') ? vpnStatus['byte_out'] : '0');
    }
  }

  Future<({bool success, String message})> toggle() async {
    if (repository.isSelectedConfigInBox) {
      if (Platform.isAndroid) {
        granted = await engine.requestPermissionAndroid();
      }

      if (granted) {
        if (isConnected) {
          _addLog('disconnecting...');
          _connectButtonAnimationController.reverse();

          await _disconnect();
          logScreenController.reset();
        } else {
          _addLog('connecting...');
          _connectButtonAnimationController.forward();
          await _connect();
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

  Future<({bool success, String message})> importFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      Map<String, dynamic> configJson;
      try {
        configJson = json.decode(data.text ?? '{}');
      } on FormatException {
        return (success: false, message: "Invalid Format");
      }

      return await repository.importConfig(configJson);
    }
    return (success: false, message: "No Data");
  }

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
        onStart: _onStart,

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
        onForeground: _onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: _onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
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

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? path = preferences.getString('TunnelPath');
    List<String>? parameters = preferences.getStringList('TunnelParams');

    process = await Process.start(
      path!,
      parameters!,
    );

    process.stdout.listen((event) {
      service.invoke(
        'tunnel_out',
        {
          "stdout": String.fromCharCodes(event),
        },
      );
    });

    process.stderr.listen((event) {
      service.invoke(
        'tunnel_error',
        {
          "stderr": String.fromCharCodes(event),
        },
      );
    });

    int seconds = 0;

    // bring to foreground
    Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
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

      service.invoke(
        'timer',
        {
          "time": seconds,
        },
      );

      seconds++;
    });

    service.on('stopService').listen((event) async {
      while (true) {
        bool? killed = process?.kill(ProcessSignal.sigkill);
        if (killed != null && killed) {
          break;
        }

        service.invoke(
          'tunnel_out',
          {
            "stdout": "Waiting for service to terminate...",
          },
        );

        await Future.delayed(const Duration(seconds: 1));
      }

      timer.cancel();
      service.invoke(
        'timer',
        {
          "time": 0,
        },
      );
      await service.stopSelf();
    });
  }

  Future<bool> _startService() async {
    return await FlutterBackgroundService().startService();
  }

  void _stopService() {
    FlutterBackgroundService().invoke("stopService");
  }

  void _setAsBackground() {
    FlutterBackgroundService().invoke("setAsBackground");
  }

  void _setAsForeground() {
    FlutterBackgroundService().invoke("setAsForeground");
  }

  void _addLog(String log) {
    logScreenController.addLog(log);
  }

  Future<void> _connect() async {
    Tunnel selectedTunnel = repository.selectedTunnel;
    String tunnelName = await _saveTunnelToSharedPreferences(selectedTunnel);
    await _initializeService();
    await _startService();
    _setAsBackground();
    await _startVPN(repository.selectedTunnel.vpn, tunnelName);
    await repository.connect();
  }

  Future<String> _saveTunnelToSharedPreferences(Tunnel tunnel) async {
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

        return Future.value(rtp.remark);
      default:
        return Future.value('Unknown Tunnel');
    }
  }

  Future<void> _startVPN(VPN? vpn, String tunnelName) async {
    switch (vpn.runtimeType) {
      case OpenVPNModel:
        vpn as OpenVPNModel;
        engine.connect(
          vpn.config!,
          tunnelName,
          username: vpn.username,
          password: vpn.password,
          certIsRequired: true,
        );
        break;
      default:
    }
  }

  Future<void> _disconnect() async {
    engine.disconnect();
    _stopService();
    await repository.disconnect();
  }

  bool get isConnected => repository.isConnected;

  AnimationController get animationController => _connectButtonAnimationController;

  @override
  void dispose() {
    _connectButtonAnimationController.dispose();
    if (isConnected) {
      _setAsForeground();
    }

    super.dispose();
  }
}
