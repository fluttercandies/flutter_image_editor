part of 'edit_options.dart';

class ScaleOption implements Option {
  final int width;
  final int height;

  ScaleOption(this.width, this.height)
      : assert(width > 0),
        assert(height > 0);

  @override
  bool get canIgnore => false;

  @override
  String get key => 'scale';

  @override
  Map<String, Object> get transferValue => {
        'width': width,
        'height': height,
      };
}
