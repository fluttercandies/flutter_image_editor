import 'package:flutter/material.dart';

/// Convert option to json for transfer.
class ConvertUtils {
  const ConvertUtils._();

  /// Convert [Offset] to map
  static Map<String, Object> offset(Offset offset) {
    return {
      'x': offset.dx.toInt(),
      'y': offset.dy.toInt(),
    };
  }

  /// Convert [Color] to map
  static Map<String, Object> color(Color c) {
    return {
      'r': c.red,
      'g': c.green,
      'b': c.blue,
      'a': c.alpha,
    };
  }

  /// Convert [Rect] to map
  static Map<String, Object> rect(Rect rect) {
    return {
      'left': rect.left.toInt(),
      'top': rect.top.toInt(),
      'width': rect.width.toInt(),
      'height': rect.height.toInt(),
    };
  }
}
