import 'package:hive_flutter/adapters.dart';
part 'data.g.dart';

@HiveType(typeId: 0)
class VPNEntity extends HiveObject {
  @HiveField(0)
  Location vpnLocation = Location.unknown;
}

@HiveType(typeId: 2)
enum Location {
  @HiveField(0)
  unknown,
  @HiveField(1)
  france,
  @HiveField(2)
  germany,
  @HiveField(3)
  us,
  @HiveField(4)
  uk,
}
