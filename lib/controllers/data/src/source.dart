import 'package:rtptun_app/models/tunnel/tunnel_model.dart';

abstract class DataSource {
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
  Tunnel get selectedTunnel;
  Future<void> setSelectedTunnel(Tunnel tunnel);
  List<Tunnel> get configs;
  Tunnel getTunnelByIndex(int index);
  Future<Tunnel> createOrUpdate(Tunnel tunnel);
  Future<void> delete(Tunnel? tunnel);
  ({String title, String subtitle}) getTunnelListTileInfo(int index);
  Future<void> saveTimerState(int seconds);
  Future<void> deleteTimerState();
  int get timerState;
  bool get isSelectedConfigInBox;
}
