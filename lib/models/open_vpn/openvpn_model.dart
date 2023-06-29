import 'package:hive_flutter/adapters.dart';

import '../vpn/vpn_model.dart';
part 'openvpn_model.g.dart';

@HiveType(typeId: 4)
class OpenVPN extends HiveObject implements VPN {
  @HiveField(0)
  String? config;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? password;

  OpenVPN({
    this.config,
    this.username,
    this.password,
  });
}
