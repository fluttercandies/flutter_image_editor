import 'package:flutter/widgets.dart';
import 'convert_value.dart';

/// Used to describe the location information of merge for [MergeImageConfig].
class ImagePosition with JsonAble {
  /// Used to describe the location information of merge for [MergeImageConfig].
  const ImagePosition(this.offset, this.size);

  /// Use [x], [y], [width] and [height] to create instance.
  ImagePosition.params({
    required double x,
    required double y,
    required double width,
    required double height,
  })  : offset = Offset(x, y),
        size = Size(x, y);

  /// Contains offset information.
  final Offset offset;

  /// Contains size information.
  final Size size;

  @override
  Map<String, Object> toJson() {
    return <String, Object>{
      'x': offset.dx.toInt(),
      'y': offset.dy.toInt(),
      'w': size.width.toInt(),
      'h': size.height.toInt(),
    };
  }
}
