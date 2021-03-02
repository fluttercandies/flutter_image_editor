class HandleError implements Exception {
  String msg;

  HandleError([this.msg = '']);

  @override
  String toString() {
    return "handle image error: $msg";
  }
}
