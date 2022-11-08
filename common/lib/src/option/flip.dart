part of 'edit_options.dart';

/// Flip image, support flip horizontal and vertical.
class FlipOption implements Option {
  const FlipOption({
    this.horizontal = true,
    this.vertical = false,
  });

  /// Flip horizontal.
  final bool horizontal;

  /// Flip vertical.
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
