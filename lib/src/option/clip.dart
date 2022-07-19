part of 'edit_options.dart';

///
/// {@template image_editor.option.clip}
///
/// The clip option is used to clip image.
///
/// {@endtemplate}
class ClipOption implements Option {
  /// {@macro image_editor.option.clip}
  const ClipOption({
    this.x = 0,
    this.y = 0,
    required this.width,
    required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  /// {@macro image_editor.option.clip}
  factory ClipOption.fromRect(Rect rect) {
    return ClipOption(
      x: rect.left.round(),
      y: rect.top.round(),
      width: rect.width.round(),
      height: rect.height.round(),
    );
  }

  /// {@macro image_editor.option.clip}
  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: start.dx.round(),
      y: start.dy.round(),
      width: (end.dx - start.dx).round(),
      height: (end.dy - start.dy).round(),
    );
  }

  /// The x coordinate of clip.
  final num x;

  /// The y coordinate of clip.
  final num y;

  /// The width of clip.
  ///
  /// The width must be greater than 0.
  final num width;

  /// The height of clip.
  ///
  /// The height must be greater than 0.
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
