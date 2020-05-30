part of 'edit_options.dart';

/// Not yet implemented, just reserved api
class DrawOption extends Option {
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

abstract class DrawPart implements TransferValue {
  const DrawPart();

  Map<String, Object> offsetValue(Offset o) {
    return ConvertUtils.offset(o);
  }
}

class DrawPaint extends DrawPart {
  final Color color;
  final double lineWeight;
  final PaintingStyle paintingStyle;

  const DrawPaint({
    this.color = Colors.black,
    this.lineWeight = 2,
    this.paintingStyle = PaintingStyle.fill,
  });

  factory DrawPaint.paint(Paint paint) {
    return DrawPaint(
      color: paint.color,
      lineWeight: paint.strokeWidth,
      paintingStyle: paint.style,
    );
  }

  @override
  bool get canIgnore => false;

  // ignore: unused_element
  void _p() {
    var paint = Paint(); // ignore: unused_local_variable
    var canvas = Canvas(PictureRecorder()); // ignore: unused_local_variable

    PointMode pointMode;
    List<Offset> points;
    canvas.drawPoints(pointMode, points, paint);
    Path path = Path();
//    path.conicTo(x1, y1, x2, y2, w);
//    path.cubicTo(x1, y1, x2, y2, x3, y3);
//    path.quadraticBezierTo(x1, y1, x2, y2);
    canvas.drawPath(path, paint);
  }

  @override
  String get key => 'paint';

  @override
  Map<String, Object> get transferValue => {
        'color': ConvertUtils.color(color),
        'lineWeight': lineWeight,
        'paintStyleFill': paintingStyle == paintingStyle,
      };

  Map<String, Object> get values => {
        key: transferValue,
      };
}

mixin _HavePaint on TransferValue {
  DrawPaint get paint;

  Map<String, Object> get values;

  @override
  Map<String, Object> get transferValue =>
      <String, Object>{}..addAll(values)..addAll(paint.values);
}

class LineDrawPart extends DrawPart with _HavePaint {
  final Offset start;
  final Offset end;
  final DrawPaint paint;

  LineDrawPart({
    @required this.start,
    @required this.end,
    this.paint,
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'line';

  @override
  Map<String, Object> get values => {
        'start': offsetValue(start),
        'end': offsetValue(end),
        paint.key: paint.transferValue,
      };
}

class PointDrawPart extends DrawPart with _HavePaint {
  final List<Offset> points = [];
  final DrawPaint paint;
  final PointMode pointMode;

  PointDrawPart({
    this.paint = const DrawPaint(),
    this.pointMode = PointMode.points,
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'point';

  @override
  Map<String, Object> get values => {
        'offset': points.map((e) => ConvertUtils.offset(e)).toList(),
      };
}

class RectDrawPart extends DrawPart with _HavePaint {
  final Rect rect;
  final DrawPaint paint;

  RectDrawPart({
    @required this.rect,
    this.paint = const DrawPaint(),
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'rect';

  @override
  Map<String, Object> get values => {
        'rect': ConvertUtils.rect(rect),
      };
}

class OvalDrawPart extends DrawPart with _HavePaint {
  final DrawPaint paint;
  final Rect rect;

  OvalDrawPart({
    @required this.rect,
    this.paint = const DrawPaint(),
  });

  @override
  bool get canIgnore => false;

  @override
  String get key => 'circle';

  @override
  Map<String, Object> get values => {
        'rect': ConvertUtils.rect(rect),
      };
}

class PathDrawPart extends DrawPart {
  final List<_PathPart> parts = [];

  @override
  bool get canIgnore => parts.isEmpty;

  void move(Offset point) {
    parts.add(
      _MovePathPart(const DrawPaint(), point),
    );
  }

  void lineTo(Offset point, DrawPaint paint) {
    parts.add(
      _LineToPathPart(const DrawPaint(), point),
    );
  }

  void arcTo(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      DrawPaint paint) {
    parts.add(
      _ArcToPathPart(
        paint: paint,
        rect: rect,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        useCenter: useCenter,
      ),
    );
  }

  void bezier2To(Offset target, Offset control, DrawPaint paint) {
    parts.add(
      _BezierPathPart(
        paint: paint,
        target: target,
        control1: control,
        control2: null,
        kind: 2,
      ),
    );
  }

  void bezier3To(
      Offset target, Offset control1, Offset control2, DrawPaint paint) {
    parts.add(
      _BezierPathPart(
        paint: paint,
        target: target,
        control1: control1,
        control2: control2,
        kind: 3,
      ),
    );
  }

  void bezierTo({
    @required Offset target,
    Offset control1,
    Offset control2,
    DrawPaint paint = const DrawPaint(),
  }) {
    assert(target != null);
    if (target == null) {
      return;
    }
    if (control1 == null) {
      lineTo(target, paint);
      return;
    }
    if (control2 == null) {
      bezier2To(target, control1, paint);
      return;
    }
    bezier3To(target, control1, control2, paint);
  }

  @override
  String get key => 'path';

  @override
  Map<String, Object> get transferValue => {
        'parts': parts.map((e) => e.transferValue).toList(),
      };
}

abstract class _PathPart extends TransferValue with _HavePaint {
  @override
  bool get canIgnore => false;
}

class _MovePathPart extends _PathPart {
  final DrawPaint paint;
  final Offset offset;

  _MovePathPart(this.paint, this.offset);

  @override
  String get key => 'move';

  @override
  Map<String, Object> get values => {
        'offset': ConvertUtils.offset(offset),
      };
}

class _LineToPathPart extends _PathPart {
  final DrawPaint paint;
  final Offset offset;

  _LineToPathPart(this.paint, this.offset);

  @override
  String get key => 'lineTo';

  @override
  Map<String, Object> get values => {
        'offset': ConvertUtils.offset(offset),
      };
}

class _BezierPathPart extends _PathPart {
  final DrawPaint paint;
  final Offset target;
  final Offset control1;
  final Offset control2;
  final int kind;

  _BezierPathPart({
    @required this.paint,
    @required this.target,
    @required this.control1,
    @required this.control2,
    @required this.kind,
  }) : assert(kind == 2 || kind == 3);

  @override
  String get key => 'bezier';

  @override
  Map<String, Object> get values {
    final value = <String, Object>{
      'target': ConvertUtils.offset(target),
      'c1': ConvertUtils.offset(control1),
      'kind': kind,
    };

    if (control2 != null) {
      value['c2'] = ConvertUtils.offset(control2);
    }

    return value;
  }
}

class _ArcToPathPart extends _PathPart {
  final DrawPaint paint;
  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final bool useCenter;

  _ArcToPathPart({
    @required this.paint,
    @required this.rect,
    @required this.startAngle,
    @required this.sweepAngle,
    @required this.useCenter,
  });

  @override
  String get key => 'arcTo';

  @override
  Map<String, Object> get values => {
        'rect': ConvertUtils.rect(rect),
        'start': startAngle,
        'sweep': sweepAngle,
        'useCenter': useCenter,
      };
}
