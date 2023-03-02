part of 'edit_options.dart';

/// {@template image_editor.option.default_matrix}
///
/// The default color matrix.
///
/// ```
/// [1, 0, 0, 0, 0,
///  0, 1, 0, 0, 0,
///  0, 0, 1, 0, 0,
///  0, 0, 0, 1, 0]
/// ```
///
/// {@endtemplate}
const List<double> defaultColorMatrix = <double>[
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
  /// If the color matrix is null, it will use the default color matrix.
  ///
  /// default color matrix:
  /// {@macro image_editor.option.default_matrix}
  const ColorOption({
    this.matrix = defaultColorMatrix,
  }) : assert(matrix.length == 20);

  /// Migrate from [Android SDK saturation code](https://developer.android.com/reference/android/graphics/ColorMatrix.html#setSaturation(float)) .
  ///
  /// Represents the saturation of the color.
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

  /// Copy from android sdk. See [Android SDK color matrix](https://developer.android.google.cn/reference/android/graphics/ColorMatrix#setRotate(int,%20float)) .
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
        throw ArgumentError('Failed to create');
    }
    return ColorOption(matrix: mArray);
  }

  /// https://developer.android.google.cn/reference/android/graphics/ColorMatrix#setScale(float,%20float,%20float,%20float)
  factory ColorOption.scale(
    double rScale,
    double gScale,
    double bScale,
    double aScale,
  ) {
    final a = List<double>.filled(20, 0);
    a[0] = rScale;
    a[6] = gScale;
    a[12] = bScale;
    a[18] = aScale;
    return ColorOption(matrix: a);
  }

  factory ColorOption.brightness(double brightness) {
    return ColorOption.scale(brightness, brightness, brightness, 1);
  }

  /// The contrast translate follows the guide:
  /// https://docs.rainmeter.net/tips/colormatrix-guide.
  factory ColorOption.contrast(double contrast) {
    final m = List<double>.from(defaultColorMatrix);

    // final double translate = 255.0 * (1 - contrast) / 2
    final double translate = (1 - contrast) * 127.5; // faster
    m[4] = translate;
    m[9] = translate;
    m[14] = translate;
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return ColorOption(matrix: m);
  }

  /// 5x4 color matrix. This matrix is capable on both Android and iOS.
  ///
  /// ```
  /// [ a, b, c, d, e,
  ///   f, g, h, i, j,
  ///   k, l, m, n, o,
  ///   p, q, r, s, t ]
  /// ```
  ///
  /// See also:
  ///  * [Document of `ColorMatrix`](https://developer.android.com/reference/android/graphics/ColorMatrix).
  ///
  final List<double> matrix;

  /// Merge [other] into this color matrix.
  ColorOption concat(ColorOption other) {
    List<double> tmp = List.filled(20, 0);
    final a = matrix.toList();
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
  Map<String, Object> get transferValue => {'matrix': matrix};
}
