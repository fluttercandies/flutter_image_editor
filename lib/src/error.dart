class HandleError implements Exception {
  HandleError([this.msg = '']);

  final String msg;

  @override
  String toString() => 'handle image error: $msg';
}
