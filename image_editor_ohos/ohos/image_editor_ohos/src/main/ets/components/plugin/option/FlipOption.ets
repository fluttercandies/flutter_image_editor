import { Option } from './Option';
import image from '@ohos.multimedia.image';
import { MapUtils } from '../util/MapUtils';

export class FlipOption implements Option {
  static readonly key: string = 'flip';
  constructor(data: Map<string, ESObject>) {
    this.horizontal = MapUtils.get(data, 'h', false);
    this.vertical = MapUtils.get(data, 'v', false);
  }

  async handle(pixelMap: image.PixelMap): Promise<image.PixelMap> {
    await pixelMap.flip(this.horizontal, this.vertical);
    return pixelMap;
  }

  horizontal: boolean;
  vertical: boolean;

  canIgnore(): boolean {
    return!this.horizontal && !this.vertical;
  };
}