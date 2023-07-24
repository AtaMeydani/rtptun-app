import 'package:hive_flutter/adapters.dart';
part 'vpn_model.g.dart';

@HiveType(typeId: 3)
class VPN extends HiveObject {
  external Map<String, dynamic> toJson();
  external void fromJson(Map<String, dynamic> config);
}
