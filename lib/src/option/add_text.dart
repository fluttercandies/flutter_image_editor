part of 'edit_options.dart';

class AddTextOption implements Option {
  AddTextOption();

  final List<EditorText> texts = <EditorText>[];

  void addText(EditorText text) {
    texts.add(text);
  }

  @override
  bool get canIgnore => texts.isEmpty;

  @override
  String get key => 'add_text';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'texts': texts.map((e) => e.toJson()).toList(),
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
