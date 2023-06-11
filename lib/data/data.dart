import 'package:hive_flutter/adapters.dart';
part 'data.g.dart';

@HiveType(typeId: 1)
class VPNEntity extends HiveObject {
  @HiveField(0)
  String remark;

  @HiveField(1)
  String address;

  @HiveField(2)
  int port;

  @HiveField(3)
  Protocol protocol;

  VPNEntity({required this.remark, required this.address, required this.port, required this.protocol});
}

@HiveType(typeId: 2)
enum Protocol {
  @HiveField(0)
  rtp,
}

@HiveType(typeId: 3)
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
