# Flutter Image Editor Platform Interface

The Flutter Image Editor Platform Interface is a platform interface for the Flutter Image Editor plugin.

To use the plugin, add `image_editor` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

This interface allows platform-specific implementations of the `image_editor` plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Support platforms

Now, the plugin supports the following platforms:
    - Android
    - iOS
    - macOS

Welcome to contribute other platforms.

## Implementing the interface

To implement the interface, extend `ImageEditorPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `ImageEditorPlatform` by calling `ImageEditorPlatform.instance = MyPlatformImageEditor()`.

To see an example of how the interface is implemented, see the [image_editor_common][]

[image_editor_common]: https://pub.flutter-io.cn/packages/image_editor_common
