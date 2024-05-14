import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';

export class ClipOption implements Option {
  static readonly key: string = 'clip';
  constructor(data: Map<string, ESObject>) {
    this.x = MapUtils.get(data, 'x', 0);
    this.y = MapUtils.get(data, 'y', 0);
    this.width = MapUtils.get(data, 'width', 0);
    this.height = MapUtils.get(data, 'height', 0);
  }

  /// The x coordinate of clip.
  x: number;
  /// The y coordinate of clip.
  y: number;
  /// The width of clip.
  ///
  /// The width must be greater than 0.
  width: number;
  /// The height of clip.
  ///
  /// The height must be greater than 0.
  height: number;

  canIgnore(): boolean {
    return this.width <= 0 || this.height <= 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.crop({
      size: {
        width: this.width,
        height: this.height,
      },
      x: this.x,
      y: this.y,
    });
    return pixelMap;
  }
}