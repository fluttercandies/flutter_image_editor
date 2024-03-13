import { Option } from './Option';
import image from '@ohos.multimedia.image';

export class FlipOption implements Option {
  constructor(data: Map<string, ESObject>) {
    this.horizontal = data.has('h') ? data.get('h') : false;
    this.vertical = data.has('v') ? data.get('v') : false;
  }

  async handle(pixelMap: image.PixelMap): Promise<void> {
    await pixelMap.flip(this.horizontal, this.vertical);
  }

  horizontal: boolean;
  vertical: boolean;

  canIgnore(): boolean {
    return !this.horizontal && !this.vertical;
  };
}