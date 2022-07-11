part of 'edit_options.dart';

class AddTextOption implements Option {
  const AddTextOption() : _texts = const <EditorText>[];

  final List<EditorText> _texts;

  void addText(EditorText text) {
    _texts.add(text);
  }

  @override
  bool get canIgnore => _texts.isEmpty;

  @override
  String get key => 'add_text';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'texts': _texts.map((e) => e.toJson()).toList(),
    };
  }
}

class EditorText {
  const EditorText({
    required this.text,
    required this.offset,
    this.fontSizePx = 14,
    this.textColor = Colors.black,
    this.fontName = '',
  });

  final String text;
  final Offset offset;
  final int fontSizePx;
  final Color textColor;
  final String fontName;

  int get y {
    if (Platform.isAndroid) {
      return offset.dy.toInt() + fontSizePx;
    }
    return offset.dy.toInt();
  }

  Map<String, Object> toJson() {
    return <String, Object>{
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
