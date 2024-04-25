# CONTRIBUTING

We love pull requests from everyone. By participating in this project, you agree to abide by the thoughtbot [code of conduct](https://thoughtbot.com/open-source-code-of-conduct).

## Quick guide

### Fork the repo

Here's a quick guide:

1. Fork the repo.
1. `git clone <fork_url>`
1. `cd flutter_image_editor`
1. `dart pub global activate melos`
1. melos bootstrap

### Android

Open `flutter_image_editor/image_editor/example/android` in Android Studio.

Or open `flutter_image_editor_common/example/android` in Android Studio.

Edit `image_editor_common/android/**.kotlin` files.

### iOS

```sh
open flutter_image_editor/image_editor/example/ios/Runner.xcworkspace
```

Then the project will be opened in Xcode.

Edit the `Pods/Development Pods/image_editor_common/**.m` files.

### macOS

```sh
open flutter_image_editor/image_editor/example/macos/Runner.xcworkspace
```

Edit the `Pods/Development Pods/image_editor_common/**.m` files.

### Open Harmony

Open `flutter_image_editor/image_editor/example/ohos` in DevEco Studio.

## For adminer of repo

Use git tag to publish a new version to `pub.dev`.

```sh
git tag <package name>-v<version>

# Such as:

git tag image_editor-v1.4.0
git push --tags
```

Or use [github release new](https://github.com/fluttercandies/flutter_image_editor/releases/new) page to create a new release.

The support package name is define in [publish.py](https://github.com/fluttercandies/flutter_image_editor/blob/main/publish.py#L7)

Now they are `image_editor`, `image_editor_common`, `image_editor_platform_interface` and `image_editor_ohos`.
