import 'package:hive_flutter/adapters.dart';

import '../vpn/vpn_model.dart';
part 'tunnel_model.g.dart';

@HiveType(typeId: 1)
class Tunnel extends HiveObject {
  VPN? vpn;

  external Map<String, dynamic> toJson();
  external Map<String, dynamic> getJsonConfiguration();
  external void fromJson(Map<String, dynamic> config);
}
