import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rtptun_app/models/tunnel/tunnel_model.dart';
import '../src/source.dart';

class Repository with ChangeNotifier implements DataSource {
  final DataSource localDataSource;

  Repository(this.localDataSource);

  @override
  Future<void> connect() async {
    await localDataSource.connect();
  }

  @override
  Future<void> disconnect() async {
    await localDataSource.disconnect();
  }

  @override
  Future<void> setSelectedTunnel(Tunnel config) async {
    await localDataSource.setSelectedTunnel(config);
    notifyListeners();
  }

  @override
  Tunnel getTunnelByIndex(int index) {
    return localDataSource.getTunnelByIndex(index);
  }

  @override
  Future<Tunnel> createOrUpdate(Tunnel tunnel) async {
    Tunnel config = await localDataSource.createOrUpdate(tunnel);
    notifyListeners();
    return config;
  }

  @override
  Future<void> delete(Tunnel? tunnel) async {
    await localDataSource.delete(tunnel);
    notifyListeners();
  }

  @override
  ({String title, String subtitle}) getTunnelListTileInfo(int index) {
    return localDataSource.getTunnelListTileInfo(index);
  }

  @override
  Tunnel get selectedTunnel => localDataSource.selectedTunnel;

  @override
  bool get isConnected => localDataSource.isConnected;

  @override
  List<Tunnel> get configs => localDataSource.configs;

  @override
  bool get isSelectedConfigInBox => localDataSource.isSelectedConfigInBox;
}
