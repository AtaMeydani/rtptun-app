import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rtptun_app/models/vpn/vpn_model.dart';
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
  Future<void> setSelectedConfig(VPN config) async {
    await localDataSource.setSelectedConfig(config);
    notifyListeners();
  }

  @override
  VPN getConfigByIndex(int index) {
    return localDataSource.getConfigByIndex(index);
  }

  @override
  Future<VPN> createOrUpdate(VPN vpnConfig) async {
    VPN config = await localDataSource.createOrUpdate(vpnConfig);
    notifyListeners();
    return config;
  }

  @override
  Future<void> delete(VPN vpnConfig) async {
    await localDataSource.delete(vpnConfig);
    notifyListeners();
  }

  @override
  ({String title, String subtitle}) getConfigListTileInfo(int index) {
    return localDataSource.getConfigListTileInfo(index);
  }

  @override
  VPN get selectedConfig => localDataSource.selectedConfig;

  @override
  bool get isConnected => localDataSource.isConnected;

  @override
  List<VPN> get configs => localDataSource.configs;

  @override
  bool get isSelectedConfigInBox => localDataSource.isSelectedConfigInBox;
}
