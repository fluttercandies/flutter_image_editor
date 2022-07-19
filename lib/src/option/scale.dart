part of 'edit_options.dart';

/// {@template image_editor.option.scale}
///
/// The scale option is used to scale image.
///
/// The [width] and [height] must be greater than 0.
///
/// By default, the aspect ratio is not guaranteed.
/// If you need to maintain the aspect ratio, you can set [aspectRatio] to true.
///
/// [About `keepRatio` and `keepWidthFirst` document][doc-keepRatio]
///
/// When the keepRatio is false, the [keepWidthFirst] will be ignored.
///
/// [doc-keepRatio]: https://github.com/fluttercandies/flutter_image_editor#scale
///
/// {@endtemplate}
class ScaleOption implements Option {
  /// {@macro image_editor.option.scale}
  const ScaleOption(
    this.width,
    this.height, {
    this.keepRatio = false,
    this.keepWidthFirst = true,
  }) : assert(width > 0 && height > 0);

  /// The width of scale.
  final int width;

  /// The height of scale.
  final int height;

  /// {@macro image_editor.option.scale}
  final bool keepRatio;

  /// {@macro image_editor.option.scale}
  final bool keepWidthFirst;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'scale';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'width': width,
      'height': height,
      'keepRatio': keepRatio,
      'keepWidthFirst': keepWidthFirst,
    };
  }
}
