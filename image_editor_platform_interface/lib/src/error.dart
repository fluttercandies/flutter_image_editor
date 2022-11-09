/// Error for handle image.
class HandleError implements Exception {
  /// Error for handle image.
  HandleError([this.msg = '']);

  /// The message of error.
  final String msg;

  @override
  String toString() => 'handle image error: $msg';
}
