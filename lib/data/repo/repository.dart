import 'package:flutter/material.dart';

import '../src/source.dart';

class Repository<T> with ChangeNotifier implements DataSource {
  final DataSource<T> localDataSource;

  // depedency injection
  Repository(this.localDataSource);
}
