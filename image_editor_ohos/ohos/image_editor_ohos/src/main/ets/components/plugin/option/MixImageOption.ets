import { drawing } from '@kit.ArkGraphics2D';
import { Option } from './Option';
import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { ScaleOption } from './ScaleOption';
import { ImageUtils } from '../util/ImageUtils';

export class MixImageOption implements Option {
  static readonly key: string = 'mix_image';

  constructor(data: Map<string, ESObject>) {
    if (!data.has('target') || !data.has('x') || !data.has('y') || !data.has('w') || !data.has('h')) {
      throw new Error('Invalid data for MixImageOption');
    }

    const blendModeStr: string = MapUtils.get(data, 'mixMode', '');

    // if (MixImageOption.blendModeMap.size == 0) {
    //   let list = Object.keys(drawing.BlendMode);
    //   for (let index = 0; index < list.length; index++) {
    //     const key = list[index];
    //     MixImageOption.blendModeMap.set(key.replace('_', '').toLowerCase(), drawing.BlendMode[key]);
    //   }
    //
    // }
    //
    this.blendMode = MixImageOption.blendModeMap.get(blendModeStr);
    this.target = MapUtils.getMap(data, 'target').get('memory');
    this.x = MapUtils.get(data, 'x', 0);
    this.y = MapUtils.get(data, 'y', 0);
    this.width = MapUtils.get(data, 'w', 0);
    this.height = MapUtils.get(data, 'h', 0);


    // if (!supportBlendModes.includes(this.blendMode)) {
    //   throw new Error('Invalid blend mode');
    // }
  }

  target: Uint8Array;
  x: number;
  y: number;
  width: number;
  height: number;
  blendMode: drawing.BlendMode | undefined;
  // BlendMode.clear,
  // BlendMode.src,
  // BlendMode.dst,
  // BlendMode.srcOver,
  // BlendMode.dstOver,
  // BlendMode.srcIn,
  // BlendMode.dstIn,
  // BlendMode.srcOut,
  // BlendMode.dstOut,
  // BlendMode.srcATop,
  // BlendMode.dstATop,
  // BlendMode.xor,
  // BlendMode.darken,
  // BlendMode.lighten,
  // BlendMode.multiply,
  // BlendMode.screen,
  // BlendMode.overlay,
  private static blendModeMap: Map<string, drawing.BlendMode> = new Map([
    ['clear', drawing.BlendMode.CLEAR],
    ['src', drawing.BlendMode.SRC],
    ['dst', drawing.BlendMode.DST],
    ['srcOver', drawing.BlendMode.SRC_OVER],
    ['dstOver', drawing.BlendMode.DST_OVER],
    ['srcIn', drawing.BlendMode.SRC_IN],
    ['dstIn', drawing.BlendMode.DST_IN],
    ['srcOut', drawing.BlendMode.SRC_OUT],
    ['dstOut', drawing.BlendMode.DST_OUT],
    ['srcATop', drawing.BlendMode.SRC_ATOP],
    ['dstATop', drawing.BlendMode.DST_ATOP],
    ['xor', drawing.BlendMode.XOR],
    ['darken', drawing.BlendMode.DARKEN],
    ['lighten', drawing.BlendMode.LIGHTEN],
    ['multiply', drawing.BlendMode.MULTIPLY],
    ['screen', drawing.BlendMode.SCREEN],
    ['overlay', drawing.BlendMode.OVERLAY],
  ]);

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let canvas = new drawing.Canvas(pixelMap);
    let brush = new drawing.Brush();

    if (this.blendMode != undefined) {
      brush.setBlendMode(this.blendMode);
    }
    canvas.attachBrush(brush);

    const imageSource: image.ImageSource = image.createImageSource(this.target.buffer);
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };
    let targetPixelMap: PixelMap = await imageSource.createPixelMap(decodingOptions);
    let exifRotate: number = 0;
    try {
      let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
      exifRotate = ImageUtils.parseExifRotate(imageProperty);
      await pixelMap.rotate(exifRotate % 360);
    }
    catch (e) {
    }


    let scaleOption: ScaleOption = new ScaleOption(new Map<string, ESObject>([
      ['width', this.width],
      ['height', this.height],
      ['keepWidthFirst', true],
      ['keepRatio', false],
    ]));
    await scaleOption.handle(targetPixelMap);
    canvas.drawImage(targetPixelMap, this.x, this.y);
    canvas.detachBrush();

    return pixelMap;

  }

  canIgnore(): boolean {
    return false;
  }
}
