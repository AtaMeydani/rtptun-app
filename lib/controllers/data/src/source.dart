import '../../../models/vpn/vpn_model.dart';

abstract class DataSource {
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
  VPN get selectedConfig;
  Future<void> setSelectedConfig(VPN config);
  List<VPN> get configs;
  VPN getConfigByIndex(int index);
  Future<VPN> createOrUpdate(VPN vpnConfig);
  Future<void> delete(VPN vpnConfig);
  ({String title, String subtitle}) getConfigListTileInfo(int index);
  bool get isSelectedConfigInBox;
}
