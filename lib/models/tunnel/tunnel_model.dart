import 'package:hive_flutter/adapters.dart';

import '../vpn/vpn_model.dart';
part 'tunnel_model.g.dart';

@HiveType(typeId: 1)
class Tunnel extends HiveObject {
  VPN? vpn;
}
