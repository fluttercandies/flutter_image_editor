import image from '@ohos.multimedia.image';
import { Offset } from '../mode/Offset';
import { MapUtils } from '../util/MapUtils';
import { Option } from './Option';
import { drawing } from '@kit.ArkGraphics2D';
import { ImageUtils } from '../util/ImageUtils';
import { ScaleOption } from './ScaleOption';

export class ImageMergeOption {
  constructor(data: Map<string, ESObject>) {
    this.image = MapUtils.get(MapUtils.getMap(data, 'src'), 'memory', new Uint8Array());
    let position: Map<string, ESObject> = MapUtils.getMap(data, 'position');
    this.offset = MapUtils.getOffset(position);
    this.width = MapUtils.get(position, 'w', 0);
    this.height = MapUtils.get(position, 'h', 0);
  }


  /// The degree of rotate.
  image: Uint8Array;
  offset: Offset;
  width: number;
  height: number;

  async handle(context: OffscreenCanvasRenderingContext2D): Promise<void> {
    const imageSource: image.ImageSource = image.createImageSource(this.image.buffer);
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      // editable: true,
    };
    let pixelMap: PixelMap = await imageSource.createPixelMap(decodingOptions);
    // let pixelMap: PixelMap = await image.createPixelMap(this.image.buffer, {
    //   size: {
    //     width: this.width, height: this.height,
    //
    //   },
    //   // editable: true,
    // },);
    context.drawImage(pixelMap, this.offset.x, this.offset.y, this.width, this.height);
  }
}