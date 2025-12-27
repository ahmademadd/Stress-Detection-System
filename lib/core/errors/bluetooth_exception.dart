class BluetoothException implements Exception {
  final String message;
  BluetoothException(this.message);

  @override
  String toString() => message;
}
