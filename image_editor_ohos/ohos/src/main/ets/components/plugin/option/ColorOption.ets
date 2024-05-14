import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';

export class ColorOption implements Option {
  static readonly key: string = 'color';

  constructor(data: Map<string, ESObject>) {
    this.matrix = new ColorFilter(MapUtils.get(data, 'matrix', []));
  }

  matrix: ColorFilter;

  canIgnore(): boolean {
    return false;
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    return pixelMap;
  }
}