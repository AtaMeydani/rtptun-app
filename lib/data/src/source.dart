abstract class DataSource<T> {
  Future<void> connect();
  Future<void> disconnect();
}
