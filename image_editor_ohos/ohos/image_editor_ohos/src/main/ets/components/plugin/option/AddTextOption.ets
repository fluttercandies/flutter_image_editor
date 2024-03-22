import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';

export class AddTextOption implements Option {
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
    let settings: RenderingContextSettings = new RenderingContextSettings(true);
    let imageInfo = await pixelMap.getImageInfo();
    let offcontext: OffscreenCanvasRenderingContext2D = new OffscreenCanvasRenderingContext2D(imageInfo.size.width, imageInfo.size.height, settings);
    offcontext.setPixelMap(pixelMap);
    for (let index = 0; index < this.texts.length; index++) {
      const element = this.texts[index];
      element.handle(offcontext);
    }
    offcontext.filter;
    offcontext.transferToImageBitmap();
    return pixelMap;
    return offcontext.getPixelMap(0, 0, imageInfo.size.width, imageInfo.size.height);
  }
}

export class EditorText {
  constructor(data: Map<string, ESObject>) {
    this.text = MapUtils.get(data, 'text', '');
    this.fontName = MapUtils.get(data, 'fontName', '');
    this.x = MapUtils.get(data, 'x', 0);
    this.y = MapUtils.get(data, 'y', 0);
    this.size = MapUtils.get(data, 'size', 0);
    this.r = MapUtils.get(data, 'r', 0);
    this.g = MapUtils.get(data, 'g', 0);
    this.b = MapUtils.get(data, 'b', 0);
    this.a = MapUtils.get(data, 'a', 0);
  }

  canIgnore(): boolean {
    return this.text == '' || this.size == 0;
  }

  async handle(offContext: OffscreenCanvasRenderingContext2D) {
    if (this.canIgnore()) {
      return;
    }
    offContext.save();
    let color: string = `#${this.a.toString(16).padStart(2, '0')}${this.r.toString(16)
      .padStart(2, '0')}${this.g.toString(16).padStart(2, '0')}${this.b.toString(16).padStart(2, '0')}`;
    offContext.fillStyle = color
    offContext.fillText(this.text, this.x, this.y);
    offContext.restore();
  }

  text: string;
  fontName: string;
  x: number;
  y: number;
  size: number;
  r: number;
  g: number;
  b: number;
  a: number;
}