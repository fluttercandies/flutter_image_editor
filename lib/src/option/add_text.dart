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
  Map<String, Object> get transferValue => {
        'texts': _text.map((e) => e.toJson()).toList(),
      };
}

class EditorText {
  final String text;
  final Offset offset;
  final int fontSizePx;
  final Color textColor;

  /// android, it is must be asset name.
  final String fontName;

  EditorText({
    @required this.text,
    @required this.offset,
    this.fontSizePx = 14,
    this.textColor = Colors.black,
    this.fontName = "",
  });

  int get y {
    if (Platform.isAndroid) {
      return offset.dy.toInt() + fontSizePx;
    }
    return offset.dy.toInt();
  }

  Map<String, Object> toJson() {
    return {
      'text': text,
      'fontName': fontName,
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
