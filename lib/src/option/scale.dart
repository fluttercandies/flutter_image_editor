part of 'edit_options.dart';

class ScaleOption implements Option {
  const ScaleOption(
    this.width,
    this.height, {
    this.keepRatio = false,
    this.keepWidthFirst = true,
  }) : assert(width > 0 && height > 0);

  final int width;
  final int height;
  final bool keepRatio;
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
