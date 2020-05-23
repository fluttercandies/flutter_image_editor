import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:image_editor/image_editor.dart';

abstract class IgnoreAble {
  bool get canIgnore;
}

abstract class Option implements IgnoreAble {
  String get key;

  Map<String, dynamic> get transferValue;
}

class ImageEditorOption implements IgnoreAble {
  ImageEditorOption();

  OutputFormat outputFormat = OutputFormat.jpeg(95);

  List<Option> get options {
    List<Option> result = [];
    for (final group in groupList) {
      for (final opt in group) {
        result.add(opt);
      }
    }
    return result;
  }

  List<OptionGroup> groupList = [];

  void reset() {
    groupList.clear();
  }

  void addOption(Option option, {bool newGroup = false}) {
    OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }

    group.addOption(option);
  }

  void addOptions(List<Option> options, {bool newGroup = true}) {
    OptionGroup group;
    if (groupList.isEmpty || newGroup) {
      group = OptionGroup();
      groupList.add(group);
    } else {
      group = groupList.last;
    }

    group.addOptions(options);
  }

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> result = [];
    for (final option in options) {
      if (option.canIgnore) {
        continue;
      }
      result.add({
        "type": option.key,
        "value": option.transferValue,
      });
    }
    return result;
  }

  @override
  bool get canIgnore {
    for (final opt in options) {
      if (!opt.canIgnore) {
        return false;
      }
    }
    return true;
  }
}

class OptionGroup extends ListBase<Option> implements IgnoreAble {
  @override
  bool get canIgnore {
    for (final option in options) {
      if (!option.canIgnore) {
        return false;
      }
    }
    return true;
  }

  final List<Option> options = [];

  void addOptions(List<Option> optionList) {
    this.options.addAll(optionList);
  }

  void addOption(Option option) {
    this.options.add(option);
  }

  @override
  int get length => options.length;

  @override
  operator [](int index) {
    return options[index];
  }

  @override
  void operator []=(int index, value) {
    options[index] = value;
  }

  @override
  set length(int newLength) {
    options.length = newLength;
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

  @override
  bool get canIgnore => horizontal == null || vertical == null;
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
      x: fixNumber(rect.left),
      y: fixNumber(rect.top),
      width: fixNumber(rect.width),
      height: fixNumber(rect.height),
    );
  }

  factory ClipOption.fromOffset(Offset start, Offset end) {
    return ClipOption(
      x: fixNumber(start.dx),
      y: fixNumber(start.dy),
      width: fixNumber(end.dx - start.dx),
      height: fixNumber(end.dy - start.dy),
    );
  }

  static int fixNumber(num number) {
    return number.round();
  }

  @override
  String get key => "clip";

  @override
  Map<String, dynamic> get transferValue => {
        "x": x.round(),
        "y": y.round(),
        "width": width.round(),
        "height": height.round(),
      };

  @override
  bool get canIgnore => width <= 0 || height <= 0;
}

class RotateOption implements Option {
  final int degree;

  RotateOption(this.degree);

  RotateOption.radian(double radian)
      : degree = (radian / math.pi * 180).toInt();

  @override
  String get key => "rotate";

  @override
  Map<String, dynamic> get transferValue => {
        "degree": degree,
      };

  @override
  bool get canIgnore => degree % 360 == 0;
}

/// ```
/// 1,0,0,0,0,
/// 0,1,0,0,0,
/// 0,0,1,0,0,
/// 0,0,0,1,0
/// ```
///
const defaultColorMatrix = const <double>[
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  0,
  1,
  0
];

class ColorOption implements Option {
  /// 5x4 matrix. See [Document of android](https://developer.android.google.cn/reference/android/graphics/ColorMatrix.html)
  ///
  /// In android:
  /// ```
  /// [ a, b, c, d, e,
  ///   f, g, h, i, j,
  ///   k, l, m, n, o,
  ///   p, q, r, s, t ]
  /// ```
  ///
  /// Since iOS uses the GPUImage library to handle matrix color changes
  ///
  /// GPUImage only supports 4x4 matrix, so in iOS, the same matrix is as follows:
  /// ```
  /// [ a, b, c, d,
  ///   f, g, h, i,
  ///   k, l, m, n,
  ///   p, q, r, s ]
  /// ```
  ///
  final List<double> matrix;

  /// see [matrix]
  const ColorOption({this.matrix = defaultColorMatrix})
      : assert(matrix != null && matrix.length == 20);

  /// migrate from [android sdk saturation code](https://developer.android.google.cn/reference/android/graphics/ColorMatrix.html#setSaturation(float)) .
  factory ColorOption.saturation(double saturation) {
    final m = List<double>.from(defaultColorMatrix);

    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return ColorOption(matrix: m);
  }

  /// Copy from android sdk.
  factory ColorOption.rotate(int axis, double degrees) {
    final mArray = List<double>.from(defaultColorMatrix);
    double radians = degrees * math.pi / 180;
    final cosine = math.cos(radians);
    final sine = math.sin(radians);
    switch (axis) {
      // Rotation around the red color
      case 0:
        mArray[6] = mArray[12] = cosine;
        mArray[7] = sine;
        mArray[11] = -sine;
        break;
      // Rotation around the green color
      case 1:
        mArray[0] = mArray[12] = cosine;
        mArray[2] = -sine;
        mArray[10] = sine;
        break;
      // Rotation around the blue color
      case 2:
        mArray[0] = mArray[6] = cosine;
        mArray[1] = sine;
        mArray[5] = -sine;
        break;
      default:
        throw ArgumentError("cannot create");
    }

    return ColorOption(matrix: mArray);
  }

  factory ColorOption.scale(
      double rScale, double gScale, double bScale, double aScale) {
    final a = List<double>.filled(20, 0);
    a[0] = rScale;
    a[6] = gScale;
    a[12] = bScale;
    a[18] = aScale;
    return ColorOption(matrix: a);
  }

  ColorOption concat(ColorOption other) {
    List<double> tmp = List.filled(20, 0);

    final a = this.matrix.toList();
    final b = other.matrix.toList();
    int index = 0;
    for (int j = 0; j < 20; j += 5) {
      for (int i = 0; i < 4; i++) {
        tmp[index++] = a[j + 0] * b[i + 0] +
            a[j + 1] * b[i + 5] +
            a[j + 2] * b[i + 10] +
            a[j + 3] * b[i + 15];
      }
      tmp[index++] = a[j + 0] * b[4] +
          a[j + 1] * b[9] +
          a[j + 2] * b[14] +
          a[j + 3] * b[19] +
          a[j + 4];
    }

    return ColorOption(matrix: tmp);
  }

  

  @override
  bool get canIgnore => listEquals(matrix, defaultColorMatrix);

  @override
  String get key => 'color';

  @override
  Map<String, dynamic> get transferValue => {'matrix': matrix};
}
