# Flutter Image Editor Platform Interface

The Flutter Image Editor Platform Interface is a platform interface for the Flutter Image Editor plugin.

It is not recommended to use this library directly

The main pacakge, please add [`image_editor`][image_editor] to [your pubspec.yaml file](https://flutter.dev/platform-plugins/).

This interface allows platform-specific implementations of the [`image_editor`][image_editor] plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Support platforms

Now, the plugin supports the following platforms:
    - Android
    - iOS
    - macOS

Welcome to contribute other platforms.

## Implementing the interface

To implement the interface, extend `ImageEditorPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `ImageEditorPlatform` by calling `ImageEditorPlatform.instance = MyPlatformImageEditor()`.

Such as:

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:image_editor_platform_interface/image_editor_platform_interface.dart';

class MyImageEditor extends ImageEditorPlatform {
  static void registerWith() {
    ImageEditorPlatform.instance = MyImageEditor();
  }

  // ... other methods
}
```

To see an whole example of how the interface is implemented, see the [image_editor_common][]

[image_editor_common]: https://pub.dev/packages/image_editor_common
[image_editor]: https://pub.dev/packages/image_editor
