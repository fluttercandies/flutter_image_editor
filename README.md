# image_editor

![CI](https://github.com/fluttercandies/flutter_image_editor/workflows/CI/badge.svg)

Support android ios, use the native way to flip, crop, rotate pictures.

The version of readme pub and github may be inconsistent, please refer to [github](https://github.com/fluttercandies/flutter_image_editor).

- [image_editor](#image_editor)
  - [Screenshot](#screenshot)
  - [Usage](#usage)
    - [ImageEditor method params](#imageeditor-method-params)
    - [ImageEditorOption](#imageeditoroption)
    - [Option](#option)
      - [Flip](#flip)
      - [Clip](#clip)
      - [Rotate](#rotate)
      - [Color](#color)
    - [OutputFormat](#outputformat)
  - [Common issue](#common-issue)
  - [LICENSE](#license)
    - [Third party](#third-party)

## Screenshot

![img](https://github.com/kikt-blog/image/raw/master/github/flutter_image_editor_ss.gif)

## Usage

[![pub package](https://img.shields.io/pub/v/image_editor.svg)](https://pub.dev/packages/image_editor) [![GitHub](https://img.shields.io/github/license/fluttercandies/flutter_image_editor.svg)](https://github.com/fluttercandies/flutter_image_editor) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/flutter_image_editor.svg?style=social&label=Stars)](https://github.com/fluttercandies/flutter_image_editor)

```yaml
dependencies:
  image_editor: ^0.2.0
```

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

[Example used alone](https://github.com/CaiJingLong/flutter_image_editor/blob/master/example/lib/advanced_page.dart)

[Example](https://github.com/CaiJingLong/flutter_image_editor/blob/master/example/lib/advanced_page.dart) of [extended_image](https://github.com/fluttercandies/extended_image)

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

#### Color

```dart
ColorOption();
```

In android, it's use 5x4 matrix : https://developer.android.google.cn/reference/android/graphics/ColorMatrix.html

In iOS, it's use 4x4 matrix.

### OutputFormat

```dart
var outputFormat = OutputFormat.png();
var outputFormat = OutputFormat.jpeg(95);
```

## Common issue

```bash
..../image_editor-0.1.4/ios/Classes/FlutterImageEditorPlugin.m:2:9: 'image_editor/image_editor-Swift.h' file not found
```

See [#10](https://github.com/fluttercandies/flutter_image_editor/issues/10)

## LICENSE

MIT Style.

### Third party

Under BSD3 style:
[GPUImage](https://github.com/BradLarson/GPUImage.git)

Under Apache 2.0 style:
Some martix code come from android sdk.
