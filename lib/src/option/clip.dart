part of 'edit_options.dart';

class ClipOption implements Option {
  final num x;
  final num y;
  final num width;
  final num height;

  ClipOption({
    this.x = 0,
    this.y = 0,
    @required this.width,
    @required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  factory ClipOption.fromRect(Rect rect) {
    return ClipOption(
      x: fixNumber(rect.left),
      y: fixNumber(rect.top),
      width: fixNumber(rect.width),
      height: fixNumber(rect.height),
    );
  }

  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: fixNumber(start.dx),
      y: fixNumber(start.dy),
      width: fixNumber(end.dx - start.dx),
      height: fixNumber(end.dy - start.dy),
    );
  }

  static int fixNumber(num number) {
    return number.round();
  }

  @override
  String get key => "clip";

  @override
  Map<String, dynamic> get transferValue => {
        "x": x.round(),
        "y": y.round(),
        "width": width.round(),
        "height": height.round(),
      };

  @override
  bool get canIgnore => width <= 0 || height <= 0;
}
