import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { FormatOption } from './option/FormatOption';
import { Option } from './option/Option';
import { FlipOption } from './option/FlipOption';
import image from '@ohos.multimedia.image';
import { ClipOption } from './option/ClipOption';
import { RotateOption } from './option/RotateOption';
import { ScaleOption } from './option/ScaleOption';
import fs from '@ohos.file.fs';
import font from '@ohos.font'
import drawing from "@ohos.graphics.drawing"
import { AddTextOption } from './option/AddTextOption';
import { MixImageOption } from './option/MixImageOption';
import { DrawOption } from './option/DrawOption';
import { ImageMergeOption } from './option/ImageMergeOption';
import { ImageUtils } from './util/ImageUtils';
import { ColorOption } from './option/ColorOption';

/** ImageEditorOhosPlugin **/
export default class ImageEditorOhosPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context: Context | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "ImageEditorOhosPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "com.fluttercandies/image_editor");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    switch (call.method) {
      case 'memoryToMemory':
        await this.tryAgain(call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let list: Uint8Array = args.get('image');
          let buf: ArrayBuffer = list.buffer as ArrayBuffer;
          const imageSource: image.ImageSource = image.createImageSource(buf);
          return await this.handleImage(args, imageSource);
        });
        break;
      case 'memoryToFile':
        await this.tryAgain(call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let targetPath: string = args.get('target');
          let list: Uint8Array = args.get('image');
          let buf: ArrayBuffer = list.buffer as ArrayBuffer;
          const imageSource: image.ImageSource = image.createImageSource(buf);
          let uint8Array = await this.handleImage(args, imageSource);
          let file = await fs.open(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          await fs.write(file.fd, uint8Array.buffer);
          await fs.close(file.fd);
          return targetPath;
        });
        break;
      case 'fileToMemory':
        await this.tryAgain(call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let filePath: string = args.get('src');
          const imageSource: image.ImageSource = image.createImageSource(filePath);
          return await this.handleImage(args, imageSource);
        });
        break;
      case 'fileToFile':
        await this.tryAgain(call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let filePath: string = args.get('src');
          let targetPath: string = args.get('target');
          const imageSource: image.ImageSource = image.createImageSource(filePath);
          let uint8Array = await this.handleImage(args, imageSource);
          let file = await fs.open(targetPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          await fs.write(file.fd, uint8Array.buffer);
          await fs.close(file.fd);
          return targetPath;
        });
        break;
      case 'getCachePath':
        result.success(this.context?.cacheDir);
        break;
      case 'registerFont':
      // TODO
        let args: Map<string, ESObject> = call.args;
        let fontPath: string = args.get('path');
        let familyName: string = new Date().getTime().toString();
        font.registerFont({
          familyName: familyName,
          familySrc: 'file:/' + fontPath,
        });
      // let xx = font.getFontByName('abc');
        result.success(familyName);
        break;
      case 'mergeToMemory':
        await this.tryAgain(call, result, async () => {
          let uint8Array = await this.mergeImage(call);
          return uint8Array;
        });
        break;
      case 'mergeToFile':
        await this.tryAgain(call, result, async () => {
          let uint8Array = await this.mergeImage(call);
          let args: Map<string, ESObject> = call.args;
          let option: Map<string, ESObject> = args.get('option');
          let fmt: FormatOption = new FormatOption(option.get('fmt'));
          let extName: string = 'jpg';
          if (fmt.format == 0) {
            extName = 'png';
          }
          const currentTimeStamp: number = new Date().getTime();
          let path = this.context?.getApplicationContext().cacheDir + '/' + currentTimeStamp.toString() + '.' + extName;
          let file = await fs.open(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
          await fs.write(file.fd, uint8Array.buffer);
          await fs.close(file.fd);
          return path;
        });
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  async tryAgain(call: MethodCall, result: MethodResult, doWork: () => Promise<ESObject>, numberOfRetries: number = 1,): Promise<void> {
    if (numberOfRetries < 0) {
      return;
    }
    try {
      result.success(await doWork());
    }
    catch (e) {
      console.error(`${call.method} failed, code is ${e.code}, message is ${e.message}`);
      if (numberOfRetries - 1 > 0) {
        this.tryAgain(call, result, doWork, numberOfRetries - 1);
      }
      else {
        result.error(`${e.code}`, call.method, `${e.message}`);
      }
    }
  }

  async handleImage(args: Map<string, ESObject>, imageSource: image.ImageSource): Promise<Uint8Array> {
    try {
      const fmt = new FormatOption(args.get('fmt'));
      const pixelMap = await this.handleImageOptions(args, imageSource);
      try {
        return await this.packImage(pixelMap, fmt);
      } finally {
        await ImageUtils.releaseResource('PixelMap', () => pixelMap.release());
      }
    } finally {
      await ImageUtils.releaseResource('ImageSource', () => imageSource.release());
    }
  }

  private async packImage(pixelMap: PixelMap, fmt: FormatOption): Promise<Uint8Array> {
    const packOptions: image.PackingOption = {
      format: fmt.format === 0 ? 'image/png' : 'image/jpeg',
      quality: fmt.quality,
    };
    const imagePacker = image.createImagePacker();
    try {
      return new Uint8Array(await imagePacker.packing(pixelMap, packOptions));
    } finally {
      await ImageUtils.releaseResource('ImagePacker', () => imagePacker.release());
    }
  }

  async handleImageOptions(args: Map<string, ESObject>, imageSource: image.ImageSource): Promise<PixelMap> {

    let optionsList: Array<Map<string, ESObject>> = args.get('options');
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };

    let pixelMap: PixelMap = await imageSource.createPixelMap(decodingOptions);
    let ownershipTransferred = false;
    try {
      let exifRotate: number = 0;
      try {
        let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
        exifRotate = ImageUtils.parseExifRotate(imageProperty);
        await pixelMap.rotate(exifRotate % 360);
      }
      catch (e) {
      }

      for (let index = 0; index < optionsList.length; index++) {
        const data: Map<string, ESObject> = optionsList[index];
        let value: Map<string, ESObject> = data.get('value');
        let option: Option | null = null;
        switch (data.get('type')) {
          case ClipOption.key:
            option = new ClipOption(value);
            break;
          case FlipOption.key:
            option = new FlipOption(value);
            break;
          case RotateOption.key:
            option = new RotateOption(value);
            break;
          case ScaleOption.key:
            option = new ScaleOption(value);
            break;
          case AddTextOption.key:
            option = new AddTextOption(value);
            break;
          case MixImageOption.key:
            option = new MixImageOption(value);
            break;
          case DrawOption.key:
            option = new DrawOption(value);
            break;
          case ColorOption.key:
            option = new ColorOption(value);
            break;
          default:
            break;
        }
        if (option != null && !option.canIgnore()) {
          const previous = pixelMap;
          pixelMap = await option.handle(previous);
          if (pixelMap !== previous) {
            await ImageUtils.releaseResource('PixelMap', () => previous.release());
          }
        }
      }
      ownershipTransferred = true;
      return pixelMap;
    } finally {
      if (!ownershipTransferred) {
        await ImageUtils.releaseResource('PixelMap', () => pixelMap.release());
      }
    }
  }


  async mergeImage(call: MethodCall): Promise<Uint8Array> {
    let args: Map<string, ESObject> = call.args;
    let option: Map<string, ESObject> = args.get('option');
    let fmt: FormatOption = new FormatOption(option.get('fmt'));
    let width: number = option.get('w');
    let height: number = option.get('h');
    const context = new OffscreenCanvasRenderingContext2D(width, height, {
      antialias: true,
    });

    let images: Array<Map<string, ESObject>> = option.get('images');
    // 'src': image.toJson(), => 'memory'
    // 'position': position.toJson(),

    for (let index = 0; index < images.length; index++) {
      const element: Map<string, ESObject> = images[index];
      let imageMergeOption: ImageMergeOption = new ImageMergeOption(element);
      await imageMergeOption.handle(context);
    }

    const pixelMap = context.getPixelMap(0, 0, width, height);
    try {
      const scale = px2vp(1);
      await pixelMap.scale(scale, scale);
      return await this.packImage(pixelMap, fmt);
    } finally {
      await ImageUtils.releaseResource('PixelMap', () => pixelMap.release());
    }
  }
}
