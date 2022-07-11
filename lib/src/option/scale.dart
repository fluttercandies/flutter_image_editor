part of 'edit_options.dart';

class ScaleOption implements Option {
  final int width;
  final int height;
  final bool keepRatio;

  ScaleOption(
    this.width,
    this.height, {
    this.keepRatio: false,
  }) : assert(width > 0 && height > 0);

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
    };
  }
}
