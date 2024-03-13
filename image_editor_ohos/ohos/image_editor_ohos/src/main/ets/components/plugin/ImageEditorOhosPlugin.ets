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
import colorSpaceManager from '@ohos.graphics.colorSpaceManager';
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
        await this.tryAgain(1, call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let list: Uint8Array = args.get('image');
          let buf: ArrayBuffer = list.buffer as ArrayBuffer;
          const imageSource: image.ImageSource = image.createImageSource(buf);
          return await this.handleImage(args, imageSource);
        });
        break;
      case 'memoryToFile':
        await this.tryAgain(1, call, result, async () => {
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
        await this.tryAgain(1, call, result, async () => {
          let args: Map<string, ESObject> = call.args;
          let filePath: string = args.get('src');
          const imageSource: image.ImageSource = image.createImageSource(filePath);
          return await this.handleImage(args, imageSource);
        });
        break;
      case 'fileToFile':
        await this.tryAgain(1, call, result, async () => {
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
      default:
        result.notImplemented();
        break;
    }
  }

  async tryAgain(numberOfRetries: number, call: MethodCall, result: MethodResult, doWork: () => Promise<ESObject>): Promise<void> {
    if (numberOfRetries < 0) {
      return;
    }
    try {
      result.success(await doWork());
    }
    catch (e) {
      console.error(`${call.method} failed, code is ${e.code}, message is ${e.message}`);
      if (numberOfRetries - 1 > 0) {
        this.tryAgain(numberOfRetries - 1, call, result, doWork);
      }
      else {
        result.error(`${e.code}`, call.method, `${e.message}`);
      }
    }
  }

  async handleImage(args: Map<string, ESObject>, imageSource: image.ImageSource): Promise<Uint8Array> {
    let fmt: FormatOption = new FormatOption(args.get('fmt'));
    let optionsList: Array<Map<string, ESObject>> = args.get('options');
    let decodingOptions: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
    };

    let pixelMap: PixelMap = await imageSource.createPixelMap(decodingOptions);

    for (let index = 0; index < optionsList.length; index++) {
      const data: Map<string, ESObject> = optionsList[index];
      let value: Map<string, ESObject> = data.get('value');
      let option: Option | null = null;
      switch (data.get('type')) {
        case 'clip':
          option = new ClipOption(value);
          break;
        case 'flip':
          option = new FlipOption(value);
          break;
        case 'rotate':
          option = new RotateOption(value);
          break;
        case 'scale':
          option = new ScaleOption(value);
          break;
        default:
          break;
      }
      if (option != null && !option.canIgnore()) {
        await option.handle(pixelMap);
      }
    }


    let exifRotate = 0;
    // let minWidth: number = args.get('minWidth');
    // let minHeight: number = args.get('minHeight');
    // if (args.get('autoCorrectionAngle')) {
    //   try {
    //     let imageProperty = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION);
    //     /// exifRotate = this.parseExifRotate(imageProperty);
    //   }
    //   catch (e) {
    //     if (this.showLog)
    //       console.error(`getImageProperty failed, code is ${e.code}, message is ${e.message}`);
    //   }
    // }
    // if (exifRotate == 270 || exifRotate == 90) {
    //   let tmp: number = minWidth;
    //   minWidth = minHeight;
    //   minHeight = tmp;
    // }
    try {
      let imageInfo = await pixelMap.getImageInfo();
      // let scale = 1 / this.calcScale(
      //   minWidth,
      //   minHeight,
      //   imageInfo.size.width,
      //   imageInfo.size.height,
      // );
      // await pixelMap.scale(scale, scale);
      // let rotate: number = args.get('rotate');
      // let targetRotate = (rotate + exifRotate) % 360;
      // if (targetRotate != 0) {
      //   await pixelMap.rotate(targetRotate);
      // }
    }
    catch (e) {
      //if (this.showLog)
      console.error(`getImageInfo failed, code is ${e.code}, message is ${e.message}`);
    }


    const imagePackerApi = image.createImagePacker();

    // PixelMap编码成不同格式的存档图片
    let format: string = 'image/jpeg';
    switch (fmt.format) {
      case 0:
        format = 'image/png'
        break;
      default:
        break;
    }

    const packOptions: image.PackingOption = {
      format: format,
      quality: fmt.quality,
    }

    let uint8Array: Uint8Array = new Uint8Array(await imagePackerApi.packing(pixelMap, packOptions));
    pixelMap.release();
    imageSource.release();
    return uint8Array;
  }

  calcScale(minWidth: number, minHeight: number, width: number, height: number,): number {
    let scaleW = width / minWidth
    let scaleH = height / minHeight
    //if (this.showLog) {
    console.log(`width scale = ${scaleW}`)
    console.log(`height scale = ${scaleH}`)
    //}
    return Math.max(1, Math.min(scaleW, scaleH))
  }

  // 1	上	左	0°
  // 2	上	右	水平翻转
  // 3	下	右	180°
  // 4	下	左	垂直翻转
  // 5	左	上	顺时针90°+水平翻转
  // 6	右	上	顺时针90°
  // 7	右	下	顺时针90°+垂直翻转
  // 8	左	下	逆时针90°
  parseExifRotate(orientation: string): number {
    orientation = orientation.toLowerCase();
    switch (orientation) {
    // 1	上	左	0°
      case 'top-left':
        return 0;
    // 2	上	右	水平翻转
      case 'top-right':
        return 0;
    // 3	下	右	180°
      case 'bottom-right':
        return 180;
    // 4	下	左	垂直翻转
      case 'bottom-left':
        return 0;
      case 'left-top':
      // 5	左	上	顺时针90°+水平翻转
        return 90;
    // 6	右	上	顺时针90°
      case 'right-top':
        return 90;
    // 7	右	下	顺时针90°+垂直翻转
      case 'right-bottom':
        return 90;
    // 8	左	下	逆时针90°
      case 'left-bottom':
        return 270;
      default:
        break;
    }
    return 0;
  }
}