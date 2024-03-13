import image from '@ohos.multimedia.image';
import { Option } from './Option';

export class ClipOption implements Option {
  constructor(data: Map<string, ESObject>) {
    this.x = data.has('x') ? data.get('x') : 0;
    this.y = data.has('y') ? data.get('y') : 0;
    this.width = data.has('width') ? data.get('width') : 0;
    this.height = data.has('height') ? data.get('height') : 0;
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

  async handle(pixelMap: image.PixelMap): Promise<void> {
    await pixelMap.crop({
      size: {
        width: this.width,
        height: this.height,
      },
      x: this.x,
      y: this.y,
    });
  }
}