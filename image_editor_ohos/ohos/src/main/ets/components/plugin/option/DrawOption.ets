import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';
import { common2D, drawing } from '@kit.ArkGraphics2D';
import { Offset } from '../mode/Offset';

export class DrawOption implements Option {
  static readonly key: string = 'draw';

  constructor(data: Map<string, ESObject>) {
    let list: Array<Map<string, ESObject>> = MapUtils.get(data, 'parts', []);
    this.draws = [];
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      let key: string = element.get('key');
      let value: Map<string, ESObject> = MapUtils.getMap(element, 'value');
      let drawPart: _DrawPart | null = null;
      switch (key) {
        case LineDrawPart.key:
          drawPart = new LineDrawPart(value);
          break;
        case PointDrawPart.key:
          drawPart = new PointDrawPart(value);
          break;
        case RectDrawPart.key:
          drawPart = new RectDrawPart(value);
          break;
        case OvalDrawPart.key:
          drawPart = new OvalDrawPart(value);
          break;
        case PathDrawPart.key:
          drawPart = new PathDrawPart(value);
        default:
          break;
      }
      if (drawPart != null && !drawPart.canIgnore()) {
        this.draws.push(drawPart);
      }
    }
  }

  draws: Array<_DrawPart>;

  canIgnore(): boolean {
    return this.draws.length == 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let canvas = new drawing.Canvas(pixelMap);
    for (let index = 0; index < this.draws.length; index++) {
      const element = this.draws[index];
      element.handle(canvas);
    }
    return pixelMap;
  }
}

interface _DrawPart {
  handle(canvas: drawing.Canvas): void;

  canIgnore(): boolean;
}


export class DrawPaint {
  static readonly key: string = 'paint';

  constructor(data: Map<string, ESObject>) {
    this.color = MapUtils.getColor(MapUtils.getMap(data, 'color'));
    this.lineWeight = MapUtils.get(data, 'lineWeight', 2);
    this.paintStyleFill = MapUtils.get(data, 'paintStyleFill', true);
  }

  color: common2D.Color;
  lineWeight: number;
  paintStyleFill: boolean;

  static get(map: Map<string, ESObject>): DrawPaint {
    return new DrawPaint(MapUtils.get(map, DrawPaint.key, new  Map<string, ESObject>()));
  }
}

export class LineDrawPart implements _DrawPart {
  static readonly key: string = 'line';

  constructor(data: Map<string, ESObject>) {
    this.paint = DrawPaint.get(data);
    this.start = MapUtils.getOffset(MapUtils.getMap(data, 'start'));
    this.end = MapUtils.getOffset(MapUtils.getMap(data, 'end'));
  }

  canIgnore(): boolean {
    return false;
  }

  handle(canvas: drawing.Canvas): void {
    let pen: drawing.Pen = new drawing.Pen();
    pen.setColor(this.paint.color);
    pen.setStrokeWidth(this.paint.lineWeight);
    canvas.attachPen(pen);
    canvas.drawLine(this.start.x, this.start.y, this.end.x, this.end.y);
    canvas.detachPen();
  }

  start: Offset;
  end: Offset;
  paint: DrawPaint;
}


export class PointDrawPart implements _DrawPart {
  static readonly key: string = 'point';

  constructor(data: Map<string, ESObject>) {
    this.paint = DrawPaint.get(data);
    this.offsets = [];
    let list: Array<ESObject> = MapUtils.get<Array<ESObject>>(data, 'offset', []);
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      this.offsets.push(MapUtils.getOffset(element));
    }
  }

  canIgnore(): boolean {
    return this.offsets.length == 0;
  }

  handle(canvas: drawing.Canvas): void {
    let pen: drawing.Pen = new drawing.Pen();
    pen.setColor(this.paint.color);
    pen.setStrokeWidth(this.paint.lineWeight);
    canvas.attachPen(pen);
    let path: drawing.Path = new drawing.Path();
    for (let index = 0; index < this.offsets.length; index++) {
      const element = this.offsets[index];
      if (index == 0) {
        path.moveTo(element.x, element.y);
      }
      else {
        path.lineTo(element.x, element.y);
      }
    }
    canvas.drawPath(path);
    canvas.detachPen();
  }

  offsets: Array<Offset>;
  paint: DrawPaint;
}

export class RectDrawPart implements _DrawPart {
  static readonly key: string = 'rect';

  constructor(data: Map<string, ESObject>) {
    this.paint = DrawPaint.get(data);
    this.rect = MapUtils.getRect(MapUtils.getMap(data, 'rect'));
  }

  canIgnore(): boolean {
    return false;
  }

  handle(canvas: drawing.Canvas): void {
    if (this.paint.paintStyleFill) {
      let brush = new drawing.Brush();
      brush.setColor(this.paint.color);
      canvas.attachBrush(brush);
      this.drawRect(canvas);
      canvas.detachBrush();
    }
    else {
      let pen: drawing.Pen = new drawing.Pen();
      pen.setColor(this.paint.color);
      pen.setStrokeWidth(this.paint.lineWeight);
      canvas.attachPen(pen);
      this.drawRect(canvas);
      canvas.detachPen();
    }
  }

  drawRect(canvas: drawing.Canvas): void {
    canvas.drawRect(this.rect);
  }

  rect: common2D.Rect;
  paint: DrawPaint;
}

export class OvalDrawPart extends RectDrawPart {
  static readonly key: string = 'oval';

  drawRect(canvas: drawing.Canvas): void {
    let path: drawing.Path = new drawing.Path();
    let kappa = .5522848;
    let x = this.rect.left;
    let y = this.rect.top;
    let width = this.rect.right - this.rect.left;
    let height = this.rect.bottom - this.rect.top;
    let ox = (width / 2) * kappa;
    let oy = (height / 2) * kappa;
    let xe = x + width;
    let ye = y + height;
    let xm = x + width / 2;
    let ym = y + height / 2;
    path.moveTo(x, ym);
    path.cubicTo(x, ym - oy, xm - ox, y, xm, y);
    path.cubicTo(xm + ox, y, xe, ym - oy, xe, ym);
    path.cubicTo(xe, ym + oy, xm + ox, ye, xm, ye);
    path.cubicTo(xm - ox, ye, x, ym + oy, x, ym);
    path.close();
    canvas.drawPath(path);
  }
}

export class PathDrawPart implements _DrawPart {
  static readonly key: string = 'path';

  constructor(data: Map<string, ESObject>) {
    this.paint = DrawPaint.get(data);
    this.parts = [];
    let list: Array<ESObject> = MapUtils.get<Array<ESObject>>(data, 'parts', []);
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      let key: string = element.get('key');
      let value: Map<string, ESObject> = MapUtils.getMap(element, 'value');
      let pathPart: _PathPart | null = null;
      switch (key) {
        case _MovePathPart.key:
          pathPart = new _MovePathPart(value);
          break;
        case _LineToPathPart.key:
          pathPart = new _LineToPathPart(value);
          break;
        case _BezierPathPart.key:
          pathPart = new _BezierPathPart(value);
          break;
        case _ArcToPathPart.key:
          pathPart = new _ArcToPathPart(value);
          break;
        default:
          break;
      }
      if (pathPart != null && !pathPart.canIgnore()) {
        this.parts.push(pathPart);
      }
    }
    this.autoClose = MapUtils.get(data, 'autoClose', false);
  }

  canIgnore(): boolean {
    return this.parts.length == 0;
  }

  handle(canvas: drawing.Canvas): void {
    if (this.paint.paintStyleFill) {
      let brush = new drawing.Brush();
      brush.setColor(this.paint.color);
      canvas.attachBrush(brush);
      this.drawPath(canvas);
      canvas.detachBrush();
    }
    else {
      let pen: drawing.Pen = new drawing.Pen();
      pen.setColor(this.paint.color);
      pen.setStrokeWidth(this.paint.lineWeight);
      canvas.attachPen(pen);
      this.drawPath(canvas);
      canvas.detachPen();
    }

  }

  drawPath(canvas: drawing.Canvas): void {
    let path: drawing.Path = new drawing.Path();
    for (let index = 0; index < this.parts.length; index++) {
      const element = this.parts[index];
      element.handle(path);
    }
    if (this.autoClose) {
      path.close();
    }
    canvas.drawPath(path);
  }

  parts: Array<_PathPart>;
  paint: DrawPaint;
  autoClose: boolean;
}

abstract class _PathPart {
  handle(path: drawing.Path): void {
    throw new Error('Method not implemented.');
  }

  canIgnore(): boolean {
    return false;
  }
}

class _MovePathPart extends _PathPart {
  static readonly key: string = 'move';

  constructor(data: Map<string, ESObject>) {
    super();
    this.offset = MapUtils.getOffset(MapUtils.getMap(data, 'offset'));
  }

  handle(path: drawing.Path): void {
    path.moveTo(this.offset.x, this.offset.y);
  }

  offset: Offset;
}

class _LineToPathPart extends _MovePathPart {
  static readonly key: string = 'lineTo';

  handle(path: drawing.Path): void {
    path.lineTo(this.offset.x, this.offset.y);
  }
}

class _BezierPathPart extends _PathPart {
  static readonly key: string = 'bezier';

  constructor(data: Map<string, ESObject>) {
    super();
    this.control1 = MapUtils.getOffset(MapUtils.getMap(data, 'c1'));
    this.control2 = data.get('c2') ? MapUtils.getOffset(MapUtils.getMap(data, 'c2')) : null;
    this.target = MapUtils.getOffset(MapUtils.getMap(data, 'target'));
    // 2 bezier2To control2 = null
    // 3 bezier3To control2 != null
    this.kind = MapUtils.get(data, 'kind', 2);
  }

  handle(path: drawing.Path): void {
    if (this.control2 != null) {
      path.cubicTo(this.control1.x, this.control1.y, this.control2.x, this.control2.y, this.target.x, this.target.y);
    }
    else {
      path.quadTo(this.control1.x, this.control1.y, this.target.x, this.target.y);
    }
  }

  control1: Offset;
  control2: Offset | null;
  target: Offset;
  kind: number;
}

class _ArcToPathPart extends _PathPart {
  static readonly key: string = 'arcTo';

  constructor(data: Map<string, ESObject>) {
    super();
    this.rect = MapUtils.getRect(MapUtils.getMap(data, 'rect'));
    this.startAngle = MapUtils.get(data, 'start', 0);
    this.sweepAngle = MapUtils.get(data, 'sweep', 0);
    this.useCenter = MapUtils.get(data, 'useCenter', false);
  }

  handle(path: drawing.Path): void {
    path.arcTo(this.rect.left, this.rect.top, this.rect.right, this.rect.bottom, this.startAngle, this.sweepAngle);
  }

  rect: common2D.Rect;
  startAngle: number;
  sweepAngle: number;
  useCenter: boolean
}