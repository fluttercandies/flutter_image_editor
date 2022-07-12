part of 'edit_options.dart';

class FlipOption implements Option {
  const FlipOption({
    this.horizontal = true,
    this.vertical = false,
  });

  final bool horizontal;
  final bool vertical;

  @override
  String get key => 'flip';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{'h': horizontal, 'v': vertical};
  }

  @override
  bool get canIgnore => !horizontal && !vertical;
}
