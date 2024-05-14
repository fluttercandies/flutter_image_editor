import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';

export class RotateOption implements Option {
  static readonly key: string = 'rotate';
  constructor(data: Map<string, ESObject>) {
    this.degree = MapUtils.get(data, 'degree', 0) % 360;
  }

  /// The degree of rotate.
  degree: number;

  canIgnore(): boolean {
    return this.degree == 0;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.rotate(this.degree);
    return pixelMap;
  }
}