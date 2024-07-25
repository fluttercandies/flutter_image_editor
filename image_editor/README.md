# image_editor

![BUILD](https://github.com/fluttercandies/flutter_image_editor/actions/workflows/runnable.yml/badge.svg?event=push)

The version of readme pub and github may be inconsistent, please refer to [github](https://github.com/fluttercandies/flutter_image_editor).

Use native(objc,kotlin,arkts) code to handle image data, it is easy to process pictures, and can be used for saving/uploading/preview images.

- [image\_editor](#image_editor)
  - [Screenshot](#screenshot)
  - [Platform of support](#platform-of-support)
  - [Change Log](#change-log)
  - [Support](#support)
  - [ImageEditor Usage](#imageeditor-usage)
    - [ImageEditor method params](#imageeditor-method-params)
    - [ImageEditorOption](#imageeditoroption)
    - [Option](#option)
      - [Flip](#flip)
      - [Clip](#clip)
      - [Rotate](#rotate)
      - [Color Martix](#color-martix)
      - [Scale](#scale)
      - [AddText](#addtext)
        - [FontManager](#fontmanager)
      - [MixImage](#miximage)
        - [BlendMode](#blendmode)
    - [DrawOption](#drawoption)
    - [OutputFormat](#outputformat)
  - [ImageMerge](#imagemerge)
  - [LICENSE](#license)
    - [Third party](#third-party)

## Screenshot

![img](https://github.com/kikt-blog/image/raw/master/github/flutter_image_editor_ss.gif)

## Platform of support

Android, iOS, OpenHarmony

`OpenHarmony` 平台的例子，请运行 `image_editor_ohos/example`

## Change Log

This version is a null-safety version.

Please read document for null-safety information in [dart][dart-safe] or [flutter][flutter-safe].

[flutter-safe]: https://flutter.dev/docs/null-safety
[dart-safe]: https://dart.dev/null-safety

## Support

| Feature           | Android |  iOS  | OpenHarmony |
| :---------------- | :-----: | :---: | :---------: |
| flip              |    ✅    |   ✅   |      ✅      |
| crop              |    ✅    |   ✅   |      ✅      |
| rotate            |    ✅    |   ✅   |      ✅      |
| scale             |    ✅    |   ✅   |      ✅      |
| matrix            |    ✅    |   ✅   |      ❌      |
| mix image         |    ✅    |   ✅   |      ✅      |
| merge multi image |    ✅    |   ✅   |      ✅      |
| draw point        |    ✅    |   ✅   |      ✅      |
| draw line         |    ✅    |   ✅   |      ✅      |
| draw rect         |    ✅    |   ✅   |      ✅      |
| draw circle       |    ✅    |   ✅   |      ✅      |
| draw path         |    ✅    |   ✅   |      ✅      |
| draw Bezier       |    ✅    |   ✅   |      ✅      |
| Gaussian blur     |    ❌    |   ❌   |      ❌      |


## ImageEditor Usage

[![pub package](https://img.shields.io/pub/v/image_editor.svg)](https://pub.dev/packages/image_editor) [![GitHub](https://img.shields.io/github/license/fluttercandies/flutter_image_editor.svg)](https://github.com/fluttercandies/flutter_image_editor) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_image_editor.svg?style=social&label=Stars)](https://github.com/fluttercandies/flutter_image_editor)

```yaml
dependencies:
  image_editor: $latest
```

About version, please find it from [pub](https://pub.dev/packages/image_editor).

Import

```dart
import 'package:image_editor/image_editor.dart';
```

Method list:

```dart
ImageEditor.editImage();
ImageEditor.editFileImage();
ImageEditor.editFileImageAndGetFile();
ImageEditor.editImageAndGetFile();
```

[Example used alone](https://github.com/CaiJingLong/flutter_image_editor/blob/main/image_editor/example/lib/advanced_page.dart)

[Example](https://github.com/CaiJingLong/flutter_image_editor/blob/main/image_editor/example/lib/advanced_page.dart) of [extended_image](https://github.com/fluttercandies/extended_image)

### ImageEditor method params

| Name              | Description                            |
| ----------------- | -------------------------------------- |
| image             | dart.typed_data.Uint8List              |
| file              | dart.io.File                           |
| imageEditorOption | flutter_image_editor.ImageEditorOption |

### ImageEditorOption

```dart
final editorOption = ImageEditorOption();
editorOption.addOption(FlipOption());
editorOption.addOption(ClipOption());
editorOption.addOption(RotateOption());
editorOption.addOption(); // and other option.

editorOption.outputFormat = OutputFormat.png(88);
```

### Option

#### Flip

```dart
FlipOption(horizontal:true, vertical:false);
```

#### Clip

```dart
ClipOption(x:0, y:0, width:1920, height:1920);
```

#### Rotate

```dart
RotateOption(degree: 180);
```

#### Color Martix

```dart
ColorOption();
```

it's use 5x4 matrix : <https://developer.android.google.cn/reference/android/graphics/ColorMatrix.html> Although it is an Android document, the color matrix is also applicable to iOS.

a, b, c, d, e,  
f, g, h, i, j,  
k, l, m, n, o,  
p, q, r, s, t

`ColorOption` has some factory constructor to help use change brightness, saturation and contrast. If you have more color matrix, you can open Pull Requests or issue.

#### Scale

```dart
ScaleOption(width, height, keepRatio: keepRatio, keepWidthFirst: keepWidthFirst);
```

`keepRatio` and `keepWidthFirst` are optional parameters used to maintain the aspect ratio of the original image to prevent image deformation.

`keepWidthFirst` takes effect only when `keepRatio` is true.

The following is a brief description:

| width | height | keepRatio | keepWidthFirst | src size  | dest size |
| ----- | ------ | --------- | -------------- | --------- | --------- |
| 500   | 300    | false     | true/false     | 1920x1920 | 500x300   |
| 500   | 300    | true      | true           | 1920x1920 | 500x500   |
| 500   | 300    | true      | false          | 1920x1920 | 300x300   |

#### AddText

All of unit is **pixel**.

```dart
final textOption = AddTextOption();
textOption.addText(
  EditorText(
    offset: Offset(0, 0),
    text: this._controller.text,
    fontSizePx: size,
    color: Colors.red,
    fontName: '', // You must register font before use. If the fontName is empty string, the text will use default system font.
  ),
);
```

##### FontManager

Here we can use `FontManager` to register font.

```dart
File fontFile = File(path)//;
final String fontName = await FontManager.registerFont(fontFile);

// The fontName can be use in EditorText.
// If you want to use system font, you can use empty string.
final textOption = AddTextOption();
textOption.addText(
  EditorText(
    offset: Offset(0, 0),
    text: this._controller.text,
    fontSizePx: size,
    color: Colors.red,
    fontName: fontName, // You must register font before use.
  ),
);
```

#### MixImage

```dart
void mix(BlendMode blendMode) async {
  final src = await loadFromAsset(R.ASSETS_SRC_PNG);
  final dst = await loadFromAsset(R.ASSETS_DST_PNG);
  final optionGroup = ImageEditorOption();
  optionGroup.outputFormat = OutputFormat.png();
  optionGroup.addOption(
    MixImageOption(
      x: 300,
      y: 300,
      width: 150,
      height: 150,
      target: MemoryImageSource(src),
      blendMode: blendMode,
    ),
  );
  final result =
      await ImageEditor.editImage(image: dst, imageEditorOption: optionGroup);
  this.image = MemoryImage(result);
  setState(() {});
}
```

##### BlendMode

Support next `BlendMode`, other will be ignored. You can also see [the document of flutter](https://api.flutter.dev/flutter/dart-ui/BlendMode.html).

| iOS/macOS                   | android(PorterDuff.Mode) | flutter(BlendMode) |
| --------------------------- | ------------------------ | ------------------ |
| kCGBlendModeClear           | CLEAR                    | clear              |
|                             | SRC                      | src                |
|                             | DST                      | dst                |
| kCGBlendModeNormal          | SRC_OVER                 | srcOver            |
| kCGBlendModeDestinationOver | DST_OVER                 | dstOver            |
| kCGBlendModeSourceIn        | SRC_IN                   | srcIn              |
| kCGBlendModeDestinationIn   | DST_IN                   | dstIn              |
| kCGBlendModeSourceOut       | SRC_OUT                  | srcOut             |
| kCGBlendModeDestinationOver | DST_OUT                  | dstOut             |
| kCGBlendModeSourceAtop      | SRC_ATOP                 | srcATop            |
| kCGBlendModeDestinationAtop | DST_ATOP                 | dstATop            |
| kCGBlendModeXOR             | XOR                      | xor                |
| kCGBlendModeDarken          | DARKEN                   | darken             |
| kCGBlendModeLighten         | LIGHTEN                  | lighten            |
| kCGBlendModeMultiply        | MULTIPLY                 | multiply           |
| kCGBlendModeScreen          | SCREEN                   | screen             |
| kCGBlendModeOverlay         | OVERLAY                  | overlay            |

### DrawOption

Main class : `DrawOption`

Support:

- Line
- Rect
- Oval
- Points
- Path
  - move
  - line
  - bezier2
  - bezier3

[Example](https://github.com/fluttercandies/flutter_image_editor/blob/main/image_editor/example/lib/draw_example_page.dart)

Style of paint: `DrawPaint`, user can set lineWeight,color,style(stroke,fill).

### OutputFormat

```dart
var outputFormat = OutputFormat.png();
var outputFormat = OutputFormat.jpeg(95); // The 95 is quality of jpeg.

```

## ImageMerge

```dart
    final slideLength = 180.0;
    final option = ImageMergeOption(
      canvasSize: Size(slideLength * count, slideLength * count),
      format: OutputFormat.png(),
    );

    final memory = await loadFromAsset(R.ASSETS_ICON_PNG);
    for (var i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(slideLength * i, slideLength * i),
            Size.square(slideLength),
          ),
        ),
      );
    }
    for (var i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(
                slideLength * count - slideLength * (i + 1), slideLength * i),
            Size.square(slideLength),
          ),
        ),
      );
    }

    final result = await ImageMerger.mergeToMemory(option: option);
    provider = MemoryImage(result);
    setState(() {});
```

## LICENSE

Apache License 2.0

### Third party

Under Apache 2.0 style:

Some martix code come from android sdk.

[TrueTypeParser](https://github.com/jaredrummler/TrueTypeParser) : Use it to read font name.
