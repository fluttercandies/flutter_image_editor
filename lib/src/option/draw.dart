part of 'edit_options.dart';

/// Not yet implemented, just reserved api
class DrawOption extends Option {
  const DrawOption() : parts = const <DrawPart>[];

  final List<DrawPart> parts;

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

  void addDrawPart(DrawPart part) {
    parts.add(part);
  }
}

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

  final Color color;
  final double lineWeight;
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
  abstract final DrawPaint paint;

  Map<String, Object> get values;

  @override
  Map<String, Object> get transferValue => <String, Object>{}
    ..addAll(values)
    ..addAll(paint.values);
}

class LineDrawPart extends DrawPart with _HavePaint {
  const LineDrawPart({
    required this.start,
    required this.end,
    required this.paint,
  });

  final Offset start;
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

class PointDrawPart extends DrawPart with _HavePaint {
  const PointDrawPart({
    this.paint = const DrawPaint(),
  }) : points = const <Offset>[];

  final List<Offset> points;

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

class RectDrawPart extends DrawPart with _HavePaint {
  const RectDrawPart({
    required this.rect,
    this.paint = const DrawPaint(),
  });

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

class OvalDrawPart extends DrawPart with _HavePaint {
  const OvalDrawPart({
    required this.rect,
    this.paint = const DrawPaint(),
  });

  final Rect rect;

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => false;

  @override
  String get key => 'oval';

  @override
  Map<String, Object> get values => {
        'rect': ConvertUtils.rect(rect),
      };
}

class PathDrawPart extends DrawPart with _HavePaint {
  const PathDrawPart({
    this.autoClose = false,
    this.paint = const DrawPaint(),
  }) : parts = const <_PathPart>[];

  final bool autoClose;

  // ignore: library_private_types_in_public_api
  final List<_PathPart> parts;

  @override
  final DrawPaint paint;

  @override
  bool get canIgnore => parts.isEmpty;

  void move(Offset point) {
    parts.add(_MovePathPart(point));
  }

  void lineTo(Offset point, DrawPaint paint) {
    parts.add(_LineToPathPart(point));
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

  void bezier2To(Offset target, Offset control) {
    parts.add(
      _BezierPathPart(
        target: target,
        control1: control,
        control2: null,
        kind: 2,
      ),
    );
  }

  void bezier3To(Offset target, Offset control1, Offset control2) {
    parts.add(
      _BezierPathPart(
        target: target,
        control1: control1,
        control2: control2,
        kind: 3,
      ),
    );
  }

  void bezierTo({
    required Offset target,
    Offset? control1,
    Offset? control2,
    DrawPaint paint = const DrawPaint(),
  }) {
    if (control1 == null) {
      lineTo(target, paint);
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
        for (final _PathPart e in parts)
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
