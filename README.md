# flutter_image_editor

Support android ios, use the native way to flip, crop, rotate pictures.

- [flutter_image_editor](#flutterimageeditor)
  - [Screenshot](#screenshot)
  - [Usage](#usage)
    - [FlutterImageEditor method params](#flutterimageeditor-method-params)
    - [ImageEditorOption](#imageeditoroption)
    - [Option](#option)
      - [Flip](#flip)
      - [Clip](#clip)
      - [Rotate](#rotate)
  - [LICENSE](#license)

## Screenshot

![img](https://github.com/kikt-blog/image/raw/master/github/flutter_image_editor_ss.gif)

## Usage

Import

```dart
import 'package:flutter_image_editor/flutter_image_editor.dart';
```

Initial plugin (Must do it):

```dart
void main(){
    runApp();
    /// init plugin
    FlutterImageEditor.initialPlugin();
}
```

Method list:

```dart
FlutterImageEditor.editImage();
FlutterImageEditor.editFileImage();
FlutterImageEditor.editFileImageAndGetFile();
FlutterImageEditor.editImageAndGetFile();
```

[Example used alone](https://github.com/CaiJingLong/flutter_image_editor/blob/master/example/lib/advanced_page.dart)

[Example](https://github.com/CaiJingLong/flutter_image_editor/blob/master/example/lib/advanced_page.dart) of [extended_image](https://github.com/fluttercandies/extended_image)

### FlutterImageEditor method params

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

## LICENSE

MIT Style.
