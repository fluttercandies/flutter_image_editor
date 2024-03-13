import image from '@ohos.multimedia.image';
import { Option } from './Option';

export class ScaleOption implements Option {
  constructor(data: Map<string, ESObject>) {
    this.keepWidthFirst = data.has('keepWidthFirst') ? data.get('keepWidthFirst') : true;
    this.keepRatio = data.has('keepRatio') ? data.get('keepRatio') : false;
    this.width = data.has('width') ? data.get('width') : 0;
    this.height = data.has('height') ? data.get('height') : 0;
  }

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

  async handle(pixelMap: image.PixelMap): Promise<void> {
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
  }
}