part of 'edit_options.dart';

/// Mix image
class MixImageOption implements Option {
  /// Mix image
  MixImageOption({
    required this.target,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.blendMode = BlendMode.srcOver,
  }) : assert(supportBlendModes.contains(blendMode));

  /// The target image to mix.
  final ImageSource target;

  /// The x coordinate of mix image.
  final int x;

  /// The y coordinate of mix image.
  final int y;

  /// The width of mix image.
  final int width;

  /// The height of mix image.
  final int height;

  /// The blend mode of mix image, default is [BlendMode.srcOver].
  final BlendMode blendMode;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'mix_image';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'target': target.toJson(),
      'x': x,
      'y': y,
      'w': width,
      'h': height,
      'mixMode': blendMode.toString().replaceAll('BlendMode.', ''),
    };
  }
}

/// Because native support is required,
/// only the modes supported by `iOS/macOS` and `Android` are included here.
const supportBlendModes = <BlendMode>[
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
