part of 'edit_options.dart';

class ClipOption implements Option {
  ClipOption({
    this.x = 0,
    this.y = 0,
    required this.width,
    required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  factory ClipOption.fromRect(Rect rect) {
    return ClipOption(
      x: rect.left.round(),
      y: rect.top.round(),
      width: rect.width.round(),
      height: rect.height.round(),
    );
  }

  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: start.dx.round(),
      y: start.dy.round(),
      width: (end.dx - start.dx).round(),
      height: (end.dy - start.dy).round(),
    );
  }

  final num x;
  final num y;
  final num width;
  final num height;

  @override
  String get key => 'clip';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'x': x.round(),
      'y': y.round(),
      'width': width.round(),
      'height': height.round(),
    };
  }

  @override
  bool get canIgnore => width <= 0 || height <= 0;
}
