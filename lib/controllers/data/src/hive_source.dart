import 'package:hive_flutter/hive_flutter.dart';
import 'package:rtptun_app/models/rtp/rtp_model.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';

import './source.dart';

const _isConnectedKey = 'isConnected';
const _selectedConfigKey = 'selectedConfig';
const _timerStateKey = 'timerState';

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
  Future<void> setSelectedTunnel(Tunnel config) {
    return box.put(
      _selectedConfigKey,
      configs.indexed.firstWhere((element) => element.$2 == config).$1,
    );
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
  Future<void> saveTimerState(int seconds) {
    return box.put(_timerStateKey, seconds);
  }

  @override
  Future<void> deleteTimerState() {
    return box.delete(_timerStateKey);
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

  @override
  int get timerState => box.get(_timerStateKey, defaultValue: DateTime.now().millisecondsSinceEpoch ~/ 1000);
}
