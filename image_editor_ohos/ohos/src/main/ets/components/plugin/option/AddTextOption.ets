import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';
import { common2D, drawing } from '@kit.ArkGraphics2D';

export class AddTextOption implements Option {
  static readonly key: string = 'add_text';

  constructor(data: Map<string, ESObject>) {
    let list: Array<Map<string, ESObject>> = MapUtils.get(data, 'texts', []);
    this.texts = [];
    for (let index = 0; index < list.length; index++) {
      const element: Map<string, ESObject> = list[index];
      this.texts.push(new EditorText(element));
    }
  }

  texts: Array<EditorText>;

  canIgnore(): boolean {
    return this.texts.length == 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    try {
      let canvas = new drawing.Canvas(pixelMap);
      for (let index = 0; index < this.texts.length; index++) {
        const element = this.texts[index];
        element.handle(canvas);
      }
    }
    catch (e) {
      console.log(e);
    }
    return pixelMap;
  }
}

export class EditorText {
  constructor(data: Map<string, ESObject>) {
    this.text = MapUtils.get(data, 'text', '');
    this.fontName = MapUtils.get(data, 'fontName', '');
    this.x = MapUtils.get(data, 'x', 0);
    this.y = MapUtils.get(data, 'y', 0);
    this.size = MapUtils.get(data, 'size', 0);
    this.color = MapUtils.getColor(data);
  }

  canIgnore(): boolean {
    return this.text == '' || this.size == 0;
  }

  async handle(canvas: drawing.Canvas) {
    if (this.canIgnore()) {
      return;
    }

    const brush = new drawing.Brush();
    brush.setColor(this.color);
    const font = new drawing.Font();
    font.setSize(this.size);
    // TODO, 没有 api 设置自定义
    let typeface = new drawing.Typeface();
    // let familyName = typeface.getFamilyName();
    font.setTypeface(typeface);
    const textBlob = drawing.TextBlob.makeFromString(this.text, font, drawing.TextEncoding.TEXT_ENCODING_UTF8);
    let bounds = textBlob.bounds();
    canvas.attachBrush(brush);
    canvas.drawTextBlob(textBlob, this.x - bounds.left, this.y - bounds.top);
    canvas.detachBrush();
  }

  text: string;
  fontName: string;
  x: number;
  y: number;
  size: number;
  color: common2D.Color;
}