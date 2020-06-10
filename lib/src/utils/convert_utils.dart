import 'package:flutter/material.dart';

class ConvertUtils {
  ConvertUtils._();

  static Map<String, Object> offset(Offset offset) {
    return {
      'x': offset.dx.toInt(),
      'y': offset.dy.toInt(),
    };
  }

  static Map<String, Object> color(Color c) {
    return {
      'r': c.red,
      'g': c.green,
      'b': c.blue,
      'a': c.alpha,
    };
  }

  static Map<String, Object> rect(Rect rect) {
    return {
      'left': rect.left.toInt(),
      'top': rect.top.toInt(),
      'width': rect.width.toInt(),
      'height': rect.height.toInt(),
    };
  }
}
