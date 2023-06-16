import 'package:hive_flutter/adapters.dart';
part 'rtp_model.g.dart';

@HiveType(typeId: 1)
class RTP extends HiveObject {
  @HiveField(0)
  String remark;

  @HiveField(1)
  String address;

  @HiveField(2)
  int port;

  RTP({
    required this.remark,
    required this.address,
    required this.port,
  });
}
