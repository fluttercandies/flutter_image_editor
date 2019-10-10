# image_editor

Support android ios, use the native way to flip, crop, rotate pictures.

- [image_editor](#imageeditor)
  - [Screenshot](#screenshot)
  - [Usage](#usage)
    - [ImageEditor method params](#imageeditor-method-params)
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
import 'package:image_editor/image_editor.dart';
```

Initial plugin (Must do it):

```dart
void main(){
    runApp();
    /// init plugin
    ImageEditor.initialPlugin();
}

// or

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ImageEditor.initialPlugin();
  runApp(MyApp());
}

// This method initializes a cache directory for subsequent operations, you can call it before you want to use this plugin.`
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
