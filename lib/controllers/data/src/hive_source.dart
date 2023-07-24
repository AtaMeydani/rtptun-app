import 'package:hive_flutter/hive_flutter.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';

import '../../../models/open_vpn/openvpn_model.dart';
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
  Future<({bool success, String message})> setSelectedTunnel(Tunnel config) {
    if (isConnected) {
      return Future.value((success: false, message: 'Disconnect before changing the config'));
    } else {
      box.put(
        _selectedConfigKey,
        configs.indexed.firstWhere((element) => element.$2 == config).$1,
      );
      return Future.value((success: true, message: 'success'));
    }
  }

  @override
  Tunnel getTunnelByIndex(int index) => box.getAt(index);

  @override
  Future<Tunnel> createOrUpdate(Tunnel tunnel) async {
    if (tunnel.isInBox) {
      await tunnel.save();
    } else {
      await box.add(tunnel);
    }

    return tunnel;
  }

  @override
  Future<void> delete(Tunnel? tunnel) async {
    if (tunnel == selectedTunnel) {
      box.put(_selectedConfigKey, -1);
    }
    await tunnel?.delete();
  }

  @override
  ({String title, String subtitle}) getTunnelListTileInfo(int index) {
    final Tunnel config = getTunnelByIndex(index);

    if (config is RTP) {
      return (title: config.remark ?? '', subtitle: '${config.serverAddress} : ${config.serverPort}');
    }

    return (title: 'unknown config', subtitle: 'unknown config');
  }

  @override
  Future<({String message, bool success})> importConfig(Map<String, dynamic> configJson) async {
    Tunnel? tunnel;
    VPN? vpn;
    if (configJson.containsKey('Tunnel')) {
      Map<String, dynamic> tunnelConfig = configJson['Tunnel'];

      if (tunnelConfig.containsKey('RTP')) {
        tunnel = RTP();
        tunnel.fromJson(tunnelConfig['RTP']);
      }
    }

    if (tunnel != null && configJson.containsKey('VPN')) {
      Map<String, dynamic> vpnConfig = configJson['VPN'];

      if (vpnConfig.containsKey("OpenVPN")) {
        vpn = OpenVPNModel();
        vpn.fromJson(vpnConfig["OpenVPN"]);
      }
    }

    if (tunnel == null) {
      return (success: false, message: "There Is No Tunnel");
    } else {
      tunnel.vpn = vpn;
      await createOrUpdate(tunnel);
      return (success: true, message: "Config Successfully Added");
    }
  }

  @override
  Tunnel get selectedTunnel {
    int selectedConfigIndex = box.get(_selectedConfigKey, defaultValue: -1);
    if (selectedConfigIndex < 0 || selectedConfigIndex >= configs.length) {
      return Tunnel();
    }
    return configs[selectedConfigIndex];
  }

  @override
  bool get isConnected => box.get(_isConnectedKey, defaultValue: false);

  @override
  List<Tunnel> get configs => box.values.whereType<Tunnel>().toList();

  @override
  bool get isSelectedConfigInBox => selectedTunnel.isInBox;
}
