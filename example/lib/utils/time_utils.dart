class TimeUtils {
  DateTime _start;

  void start() {
    _start = DateTime.now();
  }

  Duration current() {
    return DateTime.now().difference(_start);
  }

  String currentMs() {
    return '${current().inMilliseconds}ms';
  }
}
