import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';

export class ScaleOption implements Option {
  static readonly key: string = 'scale';

  constructor(data: Map<string, ESObject>) {
    this.keepWidthFirst = MapUtils.get(data, 'keepWidthFirst', true);
    this.keepRatio = MapUtils.get(data, 'keepRatio', false);
    this.width = MapUtils.get(data, 'width', 0);
    this.height = MapUtils.get(data, 'height', 0);
  }

  // constructor(width: number, height: number, keepRatio: boolean, keepWidthFirst: boolean) {
  //   this.keepWidthFirst =keepWidthFirst;
  //   this.keepRatio = keepRatio;
  //   this.width = width;
  //   this.height = height;
  // }

  /// The width of scale.
  width: number;
  /// The height of scale.
  height: number;
  /// {@macro image_editor.option.scale}
  keepRatio: boolean;
  /// {@macro image_editor.option.scale}
  keepWidthFirst: boolean;

  canIgnore(): boolean {
    return false;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    let w = this.width
    let h = this.height
    let imageInfo = await pixelMap.getImageInfo();
    if (this.keepRatio) {
      let srcRatio = imageInfo.size.width / imageInfo.size.height;
      if (this.keepWidthFirst) {
        h = w / srcRatio
      } else {
        w = srcRatio * h
      }
    }

    let width: number = imageInfo.size.width;
    let height: number = imageInfo.size.height;
    if (width != w || height != h) {
      let sx: number = w / width
      let sy: number = h / height
      await pixelMap.scale(sx, sy);
    }

    return pixelMap;
  }
}