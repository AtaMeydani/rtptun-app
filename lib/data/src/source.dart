abstract class DataSource {
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
  int get selectedItemIndex;
  Future<void> setSelectedItemIndex(int index);
}
