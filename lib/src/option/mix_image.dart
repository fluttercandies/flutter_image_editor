part of 'edit_options.dart';

class MixImageOption implements Option {
  final ImageSource target;
  final int x;
  final int y;
  final int width;
  final int height;

  MixImageOption({
    @required this.target,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  })  : assert(target != null),
        assert(x != null),
        assert(y != null),
        assert(width != null),
        assert(height != null);

  @override
  bool get canIgnore => target == null;

  @override
  String get key => 'mix_image';

  @override
  Map<String, dynamic> get transferValue => {
        'target': target.toJson(),
        'x': x,
        'y': y,
        'w': width,
        'h': height,
      };
}
