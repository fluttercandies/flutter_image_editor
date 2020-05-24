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
      - [ScaleOption](#scaleoption)
    - [OutputFormat](#outputformat)
  - [Common issue](#common-issue)
    - [iOS](#ios)
      - [Privacy of camera](#privacy-of-camera)
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

a, b, c, d, e,  
f, g, h, i, j,  
k, l, m, n, o,  
p, q, r, s, t

---

In iOS, it's use 4x4 matrix. The last of line will be ignored.

a, b, c, d,  
f, g, h, i,  
k, l, m, n,  
p, q, r, s

#### ScaleOption

```dart
ScaleOption(width,height);
```

After specifying the width and height, it is not clipped, but stretched to the specified width and height (Does not maintain the aspect ratio of the image).

### OutputFormat

```dart
var outputFormat = OutputFormat.png();
var outputFormat = OutputFormat.jpeg(95);
```

## Common issue

### iOS

#### Privacy of camera

Because, I include `[GPUImage](https://github.com/BradLarson/GPUImage.git)` to handle image data, and the library have Camera api, so you must add next Usage String in info.plist. It was introduced in version 0.3.x, if you don't need the new features added after 0.3, you can keep using the old version.

[Why need add it by apple](https://developer.apple.com/library/archive/qa/qa1937/_index.html)  
[How to add it by apple](https://help.apple.com/xcode/mac/8.0/#/dev3f399a2a6)

## LICENSE

MIT Style.

### Third party

Under BSD3 style:
[GPUImage](https://github.com/BradLarson/GPUImage.git)

Under Apache 2.0 style:
Some martix code come from android sdk.
