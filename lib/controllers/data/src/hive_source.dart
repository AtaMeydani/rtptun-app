import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/rtp/rtp_model.dart';
import '../../../models/vpn/vpn_model.dart';
import './source.dart';

const _isConnectedKey = 'isConnected';
const _selectedConfigKey = 'selectedConfig';

class HiveDataSource implements DataSource {
  final Box box;
  HiveDataSource(this.box);

  @override
  connect() {
    return box.put(_isConnectedKey, true);
  }

  @override
  disconnect() {
    return box.put(_isConnectedKey, false);
  }

  @override
  Future<void> setSelectedConfig(VPN config) {
    return box.put(
      _selectedConfigKey,
      configs.indexed.firstWhere((element) => element.$2 == config).$1,
    );
  }

  @override
  VPN getConfigByIndex(int index) => box.getAt(index);

  @override
  Future<VPN> createOrUpdate(VPN vpnConfig) async {
    if (vpnConfig.isInBox) {
      await vpnConfig.save();
    } else {
      await box.add(vpnConfig);
    }

    return vpnConfig;
  }

  @override
  Future<void> delete(VPN vpnConfig) async {
    if (vpnConfig == selectedConfig) {
      box.put(_selectedConfigKey, -1);
    }
    await vpnConfig.delete();
  }

  @override
  ({String title, String subtitle}) getConfigListTileInfo(int index) {
    final VPN config = getConfigByIndex(index);

    if (config is RTP) {
      return (title: config.remark ?? '', subtitle: '${config.serverAddress} : ${config.serverPort}');
    }

    return (title: 'unknown config', subtitle: 'unknown config');
  }

  @override
  VPN get selectedConfig {
    int selectedConfigIndex = box.get(_selectedConfigKey, defaultValue: -1);
    if (selectedConfigIndex < 0 || selectedConfigIndex >= configs.length) {
      return VPN();
    }
    return configs[selectedConfigIndex];
  }

  @override
  bool get isConnected => box.get('isConnected', defaultValue: false);

  @override
  List<VPN> get configs => box.values.whereType<VPN>().toList();

  @override
  bool get isSelectedConfigInBox => selectedConfig.isInBox;
}
