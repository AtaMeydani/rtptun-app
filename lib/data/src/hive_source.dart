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

  @override
  int get selectedItemIndex => box.get('selectedItemIndex', defaultValue: -1);

  @override
  Future<void> setSelectedItemIndex(int index) {
    return box.put('selectedItemIndex', index);
  }

  @override
  bool get isConnected => box.get('isConnected', defaultValue: false);
}
