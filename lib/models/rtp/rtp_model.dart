import 'package:hive_flutter/adapters.dart';

import '../tunnel/tunnel_model.dart';
import '../vpn/vpn_model.dart';

part 'rtp_model.g.dart';

@HiveType(typeId: 2)
class RTP extends HiveObject implements Tunnel {
  @HiveField(0)
  String? remark;

  @HiveField(1)
  String? serverAddress;

  @HiveField(2)
  String? serverPort;

  @HiveField(3)
  String? localAddress;

  @HiveField(4)
  String? localPort;

  @HiveField(5)
  String? secretKey;

  @override
  @HiveField(6)
  VPN? vpn;

  RTP({
    this.remark,
    this.serverAddress,
    this.serverPort,
    this.localAddress,
    this.localPort,
    this.secretKey,
    this.vpn,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "Tunnel": {
        "RTP": {
          "remark": remark,
          "serverAddress": serverAddress,
          "serverPort": serverPort,
          "localAddress": localAddress,
          "localPort": localPort,
          "secretKey": secretKey,
        },
      }
    };
  }

  @override
  void fromJson(Map<String, dynamic> config) {
    remark = config["remark"];
    serverAddress = config["serverAddress"];
    serverPort = config["serverPort"];
    localAddress = config["localAddress"];
    localPort = config["localPort"];
    secretKey = config["secretKey"];
  }

  @override
  Map<String, dynamic> getJsonConfiguration() {
    return {
      ...toJson(),
      "VPN": {
        ...vpn?.toJson() ?? {},
      },
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RTP &&
          runtimeType == other.runtimeType &&
          serverAddress == other.serverAddress &&
          serverPort == other.serverPort &&
          localAddress == other.localAddress &&
          localPort == other.localPort &&
          secretKey == other.secretKey;

  @override
  int get hashCode => Object.hashAll([
        serverAddress,
        serverPort,
        localAddress,
        localPort,
        secretKey,
      ]);
}
