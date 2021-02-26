part of 'edit_options.dart';

class MixImageOption implements Option {
  final ImageSource target;
  final int x;
  final int y;
  final int width;
  final int height;
  final BlendMode blendMode;

  MixImageOption({
    required this.target,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.blendMode = BlendMode.srcOver,
  }) : assert(supportBlendModes.contains(blendMode));

  @override
  bool get canIgnore => false;

  @override
  String get key => 'mix_image';

  @override
  Map<String, Object> get transferValue => {
        'target': target.toJson(),
        'x': x,
        'y': y,
        'w': width,
        'h': height,
        'mixMode': blendMode.toString().replaceAll('BlendMode.', ''),
      };
}

const supportBlendModes = [
  BlendMode.clear,
  BlendMode.src,
  BlendMode.dst,
  BlendMode.srcOver,
  BlendMode.dstOver,
  BlendMode.srcIn,
  BlendMode.dstIn,
  BlendMode.srcOut,
  BlendMode.dstOut,
  BlendMode.srcATop,
  BlendMode.dstATop,
  BlendMode.xor,
  BlendMode.darken,
  BlendMode.lighten,
  BlendMode.multiply,
  BlendMode.screen,
  BlendMode.overlay,
];
