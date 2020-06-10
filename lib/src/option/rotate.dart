part of 'edit_options.dart';

class RotateOption implements Option {
  final int degree;

  RotateOption(this.degree);

  RotateOption.radian(double radian)
      : degree = (radian / math.pi * 180).toInt();

  @override
  String get key => "rotate";

  @override
  Map<String, Object> get transferValue => {
        "degree": degree,
      };

  @override
  bool get canIgnore => degree % 360 == 0;
}
