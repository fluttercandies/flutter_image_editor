import image from '@ohos.multimedia.image';

export interface Option {
  canIgnore(): boolean;

  handle(pixelMap: image.PixelMap): Promise<image.PixelMap>
}