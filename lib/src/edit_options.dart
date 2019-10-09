import 'package:flutter/widgets.dart';
import 'dart:math' show pi;

abstract class Option {
  String get key;

  Map<String, dynamic> get transferValue;
}

class ImageEditOption {
  ImageEditOption();

  List<Option> options = [];

  void reset() {
    options.clear();
  }

  void addOption(Option option) {
    options.add(option);
  }

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> result = [];
    for (final option in options) {
      result.add({
        "type": option.key,
        "value": option.transferValue,
      });
    }
    return result;
  }
}

class FlipOption implements Option {
  final bool horizontal;
  final bool vertical;

  FlipOption({
    this.horizontal = true,
    this.vertical = false,
  });

  @override
  String get key => "flip";

  @override
  Map<String, dynamic> get transferValue => {
        'h': horizontal,
        'v': vertical,
      };
}

class ClipOption implements Option {
  final num x;
  final num y;
  final num width;
  final num height;

  ClipOption({
    this.x = 0,
    this.y = 0,
    @required this.width,
    @required this.height,
  })  : assert(width > 0 && height > 0),
        assert(x >= 0, y >= 0);

  factory ClipOption.fromRect(Rect rect) {
    return ClipOption(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: start.dx,
      y: start.dy,
      width: end.dx - start.dx,
      height: end.dy - start.dy,
    );
  }

  @override
  String get key => "clip";

  @override
  Map<String, dynamic> get transferValue => {
        "x": x,
        "y": y,
        "width": width,
        "height": height,
      };
}

class RotateOption implements Option {
  final int angle;

  RotateOption(this.angle);

  RotateOption.radian(double radian) : angle = (radian / pi * 180).toInt();

  @override
  String get key => "rotate";

  @override
  Map<String, dynamic> get transferValue => {
        "angle": angle,
      };
}

class ZoomOption implements Option {
  final double width;
  final double height;
  final bool keepRatio;

  ZoomOption({
    this.width,
    this.height,
    this.keepRatio = true,
  });

  @override
  String get key => "zoom";

  @override
  Map<String, dynamic> get transferValue => {
        "width": width,
        "height": height,
        "keepRatio": keepRatio,
      };
}
