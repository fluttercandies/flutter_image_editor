import image from '@ohos.multimedia.image';
import { Option } from './Option';

export class RotateOption implements Option {
  constructor(data: Map<string, ESObject>) {
    this.degree = data.has('degree') ? data.get('degree') : 0;
  }
  /// The degree of rotate.
  degree: number;

  canIgnore(): boolean {
    return this.degree % 360 == 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<void> {
    await pixelMap.rotate(this.degree);
  }
}