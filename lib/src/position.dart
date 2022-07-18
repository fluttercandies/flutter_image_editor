import 'package:flutter/widgets.dart';
import 'package:image_editor/src/convert_value.dart';

class ImagePosition with JsonAble {
  const ImagePosition(this.offset, this.size);

  final Offset offset;
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
