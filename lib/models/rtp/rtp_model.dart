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
  String? listenAddress;

  @HiveField(4)
  String? listenPort;

  @HiveField(5)
  String? secretKey;

  @override
  @HiveField(6)
  VPN? vpn;

  RTP({
    this.remark,
    this.serverAddress,
    this.serverPort,
    this.listenAddress,
    this.listenPort,
    this.secretKey,
    this.vpn,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RTP &&
          runtimeType == other.runtimeType &&
          serverAddress == other.serverAddress &&
          serverPort == other.serverPort &&
          listenAddress == other.listenAddress &&
          listenPort == other.listenPort &&
          secretKey == other.secretKey;

  @override
  int get hashCode => Object.hashAll([
        serverAddress,
        serverPort,
        listenAddress,
        listenPort,
        secretKey,
      ]);
}
