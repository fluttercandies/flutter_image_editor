part of 'edit_options.dart';

/// Add some shape to image.
class DrawOption extends Option {
  DrawOption();

  /// The items of added shapes.
  final List<DrawPart> parts = <DrawPart>[];

  /// Add [part] to [parts].
  void addDrawPart(DrawPart part) {
    parts.add(part);
  }

  @override
  bool get canIgnore => parts.isEmpty;

  @override
  String get key => 'draw';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'parts': <Map<String, Object>>[
        for (final DrawPart e in parts)
          <String, Object>{'key': e.key, 'value': e.transferValue},
      ],
    };
  }
}

/// The part of added shape.
abstract class DrawPart implements TransferValue {
  const DrawPart();

  Map<String, Object> offsetValue(Offset o) {
    return ConvertUtils.offset(o);
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(transferValue);
  }
}

/// The paint of shape.
class DrawPaint extends DrawPart {
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

  /// The color of shape.
  final Color color;

  /// The line weight of shape.
  final double lineWeight;

  /// The painting style of shape.
  final PaintingStyle paintingStyle;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'paint';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'color': ConvertUtils.color(color),
      'lineWeight': lineWeight,
      'paintStyleFill': paintingStyle == PaintingStyle.fill,
    };
  }

  Map<String, Object> get values {
    return <String, Object>{key: transferValue};
  }
}

mixin _HavePaint on TransferValue {
  /// The paint of shape.
  abstract final DrawPaint paint;

  Map<String, Object> get values;

  @override
  Map<String, Object> get transferValue => <String, Object>{}
    ..addAll(values)
    ..addAll(paint.values);
}

/// The line of shape.
class LineDrawPart extends DrawPart with _HavePaint {
  const LineDrawPart({
    required this.start,
    required this.end,
    required this.paint,
  });

  /// The start point of line.
  final Offset start;

  /// The end point of line.
  final Offset end;

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'line';

  @override
  Map<String, Object> get values {
    return <String, Object>{
      'start': offsetValue(start),
      'end': offsetValue(end),
      'paint': paint.transferValue,
    };
  }
}

/// The rectangle of shape.
class PointDrawPart extends DrawPart with _HavePaint {
  PointDrawPart({this.paint = const DrawPaint()});

  /// The point of shape.
  final List<Offset> points = <Offset>[];

  /// Add [point] to [points].
  void addPoint(Offset point) {
    points.add(point);
  }

  void addAllPoints(List<Offset> pointList) {
    points.addAll(pointList);
  }

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'point';

  @override
  Map<String, Object> get values {
    return <String, Object>{
      'offset': points.map((e) => ConvertUtils.offset(e)).toList(),
    };
  }
}

/// Draw a rectangle.
class RectDrawPart extends DrawPart with _HavePaint {
  const RectDrawPart({
    required this.rect,
    this.paint = const DrawPaint(),
  });

  /// The rectangle of shape.
  final Rect rect;

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'rect';

  @override
  Map<String, Object> get values {
    return <String, Object>{'rect': ConvertUtils.rect(rect)};
  }
}

/// Draw a oval.
class OvalDrawPart extends DrawPart with _HavePaint {
  const OvalDrawPart({
    required this.rect,
    this.paint = const DrawPaint(),
  });

  /// The oval of shape.
  final Rect rect;

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'oval';

  @override
  Map<String, Object> get values {
    return <String, Object>{'rect': ConvertUtils.rect(rect)};
  }
}

/// Draw a path.
class PathDrawPart extends DrawPart with _HavePaint {
  PathDrawPart({
    this.autoClose = false,
    this.paint = const DrawPaint(),
  });

  /// auto close the path.
  final bool autoClose;

  /// The path of shape.
  final List<_PathPart> _parts = <_PathPart>[];

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => _parts.isEmpty;

  /// move to [point].
  void move(Offset point) {
    _parts.add(_MovePathPart(point));
  }

  /// draw line to [point].
  ///
  /// The [paint] is not used, it will be ignored and it will be delete.
  void lineTo(Offset point, [DrawPaint? paint]) {
    _parts.add(_LineToPathPart(point));
  }

  /// The parameters of iOS and Android/flutter are inconsistent and need to be converted.
  /// For the time being, consistency cannot be guaranteed, delete it first.
  ///
  /// Consider adding back in future versions (may not)
  // void arcTo(Rect rect, double startAngle, double sweepAngle, bool useCenter,
  //     DrawPaint paint) {
  //   parts.add(
  //     _ArcToPathPart(
  //       rect: rect,
  //       startAngle: startAngle,
  //       sweepAngle: sweepAngle,
  //       useCenter: useCenter,
  //     ),
  //   );
  // }

  /// Add bezier curve.
  ///
  /// The [target] is the end point of the curve, and the [control]
  void bezier2To(Offset target, Offset control) {
    _parts.add(
      _BezierPathPart(
        target: target,
        control1: control,
        control2: null,
        kind: 2,
      ),
    );
  }

  /// Add bezier curve.
  ///
  /// The method have 2 control points.
  ///
  /// The [target] is the end point of the curve, and the [control1] and [control2] are the control points.
  void bezier3To(Offset target, Offset control1, Offset control2) {
    _parts.add(
      _BezierPathPart(
        target: target,
        control1: control1,
        control2: control2,
        kind: 3,
      ),
    );
  }

  /// Add bezier curve.
  ///
  /// If the [control1] and [control2] are null, the mothod will use [lineTo].
  ///
  /// If [control2] is null, will use [bezier2To].
  ///
  /// If [control1] and [control2] are not null, will use [bezier3To].
  void bezierTo({
    required Offset target,
    Offset? control1,
    Offset? control2,
    DrawPaint paint = const DrawPaint(),
  }) {
    if (control1 == null) {
      lineTo(target);
      return;
    }
    if (control2 == null) {
      bezier2To(target, control1);
      return;
    }
    bezier3To(target, control1, control2);
  }

  @override
  String get key => 'path';

  @override
  Map<String, Object> get values {
    return <String, Object>{
      'autoClose': autoClose,
      'parts': <Map<String, Object>>[
        for (final _PathPart e in _parts)
          <String, Object>{'key': e.key, 'value': e.transferValue},
      ],
    };
  }
}

abstract class _PathPart extends TransferValue {
  const _PathPart();

  @override
  bool get canIgnore => false;
}

class _MovePathPart extends _PathPart {
  const _MovePathPart(this.offset);

  final Offset offset;

  @override
  String get key => 'move';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{'offset': ConvertUtils.offset(offset)};
  }
}

class _LineToPathPart extends _PathPart {
  const _LineToPathPart(this.offset);

  final Offset offset;

  @override
  String get key => 'lineTo';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{'offset': ConvertUtils.offset(offset)};
  }
}

class _BezierPathPart extends _PathPart {
  const _BezierPathPart({
    required this.target,
    required this.kind,
    required this.control1,
    this.control2,
  }) : assert(kind == 2 || kind == 3);

  final Offset target;
  final int kind;
  final Offset control1;
  final Offset? control2;

  @override
  String get key => 'bezier';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'target': ConvertUtils.offset(target),
      'c1': ConvertUtils.offset(control1),
      'kind': kind,
      if (control2 != null) 'c2': ConvertUtils.offset(control2!),
    };
  }
}

/// ignore: unused_element
class _ArcToPathPart extends _PathPart {
  const _ArcToPathPart({
    required this.rect,
    required this.startAngle,
    required this.sweepAngle,
    required this.useCenter,
  });

  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final bool useCenter;

  @override
  String get key => 'arcTo';

  @override
  Map<String, Object> get transferValue {
    return <String, Object>{
      'rect': ConvertUtils.rect(rect),
      'start': startAngle,
      'sweep': sweepAngle,
      'useCenter': useCenter,
    };
  }
}
