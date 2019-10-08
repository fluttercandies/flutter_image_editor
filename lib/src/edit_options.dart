import 'package:flutter/widgets.dart';

abstract class Option {
  String get key;

  Map<String, dynamic> get transferValue;
}

class ImageEditOption {
  ImageEditOption();

  List<Option> options = [];

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
  final FlipType type;

  FlipOption([
    this.type = FlipType.horizontal,
  ]);

  @override
  String get key => "flip";

  @override
  Map<String, dynamic> get transferValue => {
        "type": type.index,
      };
}

enum FlipType {
  horizontal,
  vertical,
}

class ClipOption implements Option {
  final double x;
  final double y;
  final double width;
  final double height;

  ClipOption({this.x, this.y, this.width, this.height});

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
  final double angle;

  RotateOption(this.angle);

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
