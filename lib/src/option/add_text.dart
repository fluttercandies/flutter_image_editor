part of 'edit_options.dart';

class AddTextOption implements Option {
  final _text = <EditorText>[];

  void addText(EditorText text) {
    _text.add(text);
  }

  @override
  bool get canIgnore => _text.isEmpty;

  @override
  String get key => 'add_text';

  @override
  Map<String, dynamic> get transferValue => {
        'texts': _text.map((e) => e.toJson()).toList(),
      };
}

class EditorText {
  final String text;
  final Offset offset;
  final int fontSizePx;
  final Color textColor;

  EditorText({
    @required this.text,
    @required this.offset,
    this.fontSizePx = 14,
    this.textColor = Colors.black,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'x': offset.dx.toInt(),
      'y': offset.dy.toInt(),
      'size': fontSizePx,
      'r': textColor.red,
      'g': textColor.green,
      'b': textColor.blue,
      'a': textColor.alpha,
    };
  }
}
