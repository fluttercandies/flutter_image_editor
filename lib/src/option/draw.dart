part of 'edit_options.dart';

class DrawOption with Option {
  final List<DrawPart> parts = [];

  DrawOption();

  @override
  bool get canIgnore => parts.isEmpty;

  @override
  String get key => 'draw';

  @override
  Map<String, Object> get transferValue => {
        "parts": parts.map((e) => e.transferValue).toList(),
      };

  void addDrawPart(DrawPart part) {
    parts.add(part);
  }
}

abstract class DrawPart with Option {
  Map<String, Object> offsetValue(Offset o) {
    return ConvertUtils.offset(o);
  }
}

class LineDrawPart extends DrawPart {
  final Offset start;
  final Offset end;
  final Color color;
  final int weight;

  LineDrawPart({
    @required this.start,
    @required this.end,
    this.color = Colors.black,
    this.weight = 1,
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'line';

  @override
  Map<String, Object> get transferValue => {
        'start': offsetValue(start),
        'end': offsetValue(end),
        'color': ConvertUtils.color(color),
        'weight': weight,
      };
}

class PointDrawPart extends DrawPart {
  final Offset offset;
  final Color color;

  PointDrawPart({
    @required this.offset,
    this.color = Colors.black,
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'point';

  @override
  Map<String, Object> get transferValue => {
        'offset': offsetValue(offset),
        'color': ConvertUtils.color(color),
      };
}
