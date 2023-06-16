import 'package:flutter/material.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';

enum Protocol {
  rtp,
}

class ConfigController with ChangeNotifier {
  // Protocol protocol;
  RTP rtp = RTP(remark: 'remark', address: 'address', port: 6969);

  void saveChanges() {}
}
