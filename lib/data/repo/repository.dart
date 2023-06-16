import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../consts.dart';
import '../src/hive_source.dart';
import '../src/source.dart';

class Repository implements DataSource {
  final DataSource localDataSource;

  static final Repository instance = Repository._privateConstructor(
    HiveDataSource(
      Hive.box(vpnBoxName),
    ),
  );

  Repository._privateConstructor(this.localDataSource);

  @override
  Future<void> connect() async {
    await localDataSource.connect();
  }

  @override
  Future<void> disconnect() async {
    await localDataSource.disconnect();
  }

  @override
  int get selectedItemIndex => localDataSource.selectedItemIndex;

  @override
  Future<void> setSelectedItemIndex(int index) async {
    await localDataSource.setSelectedItemIndex(index);
  }

  @override
  bool get isConnected => localDataSource.isConnected;
}
