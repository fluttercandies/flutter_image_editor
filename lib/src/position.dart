import 'package:flutter/widgets.dart';
import 'package:image_editor/src/convert_value.dart';

class ImagePosition with JsonAble {
  final Offset offset;
  final Size size;

  ImagePosition(
    this.offset,
    this.size,
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      'x': offset.dx.toInt(),
      'y': offset.dy.toInt(),
      'w': size.width.toInt(),
      'h': size.height.toInt(),
    };
  }
}
