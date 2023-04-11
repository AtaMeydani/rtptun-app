import 'package:hive_flutter/hive_flutter.dart';
import 'package:rtptun_app/data/data.dart';

import './source.dart';

class HiveDataSource implements DataSource<VPNEntity> {
  final Box box;
  HiveDataSource(this.box);

  @override
  connect() {
    return box.put('isConnected', true);
  }

  @override
  disconnect() {
    return box.put('isConnected', false);
  }
}
