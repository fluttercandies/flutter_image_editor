part of 'edit_options.dart';

/// Rotate image.
class RotateOption implements Option {
  /// Rotate image.
  ///
  /// Normally, it is between 0 and 360 degrees, clockwise.
  const RotateOption(this.degree);

  /// This method is the construction method of radian.
  RotateOption.radian(
    double radian,
  ) : degree = (radian / math.pi * 180).toInt();

  /// The degree of rotate.
  final int degree;

  @override
  String get key => 'rotate';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{'degree': degree};
  }

  @override
  bool get canIgnore => degree % 360 == 0;
}
