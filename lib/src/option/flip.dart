part of 'edit_options.dart';

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
