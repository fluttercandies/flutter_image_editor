part of 'edit_options.dart';

class RotateOption implements Option {
  const RotateOption(this.degree);

  RotateOption.radian(
    double radian,
  ) : degree = (radian / math.pi * 180).toInt();

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
