import 'package:hive_flutter/adapters.dart';

import '../vpn/vpn_model.dart';
part 'openvpn_model.g.dart';

@HiveType(typeId: 4)
class OpenVPNModel extends HiveObject implements VPN {
  @HiveField(0)
  String? config;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? password;

  OpenVPNModel({
    this.config,
    this.username,
    this.password,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "OpenVPN": {
        'config': config,
        'username': username,
        'password': password,
      }
    };
  }

  @override
  void fromJson(Map<String, dynamic> vpnConfig) {
    config = vpnConfig["config"];
    username = vpnConfig["username"];
    password = vpnConfig["password"];
  }
}
