## 1.6.0

 - **FIX**: error for new sdk.
 - **FEAT**: upgrade android sdk to 35.
 - **DOCS**(README): external link BlendMode (#137).

## 1.5.1

 - Update a dependency to the latest release.

# CHANGELOG

## 1.5.0

- Support draw, merge, mix image for OpenHarmony
- Fix: mergeToFile return parameter type error
- Feat: Support `TextAlign` for `EditorText`.
- deps: Bump `image_editor_platform_interface` to `1.1.0`.
- deps: Bump `image_editor_common` to `1.1.1`.
- deps: Bump `image_editor_ohos` to `0.0.7`.

## 1.4.0

- Support OpenHarmony. [#122](https://github.com/fluttercandies/flutter_image_editor/issues/122)
- Added AGP 8 Support for Android. [#117](https://github.com/fluttercandies/flutter_image_editor/issues/117)
- Fix: Create JPEG images without embedded ICC profile. [#116](https://github.com/fluttercandies/flutter_image_editor/issues/116)

## 1.3.0

- Migration to platform interface.
- Fix the problem of `DrawOption`.

## 1.2.0

Fix:

- Android:
  - Rotate error
- Clean up code for flutter sdk 3.x

## 1.1.0

### What's Changed in 1.1.0

- iOS write to file critical bug by @MagTuxGit in <https://github.com/fluttercandies/flutter_image_editor/pull/61>
- fix: memory leak rotating cropping, closes #85 by @paricleu in <https://github.com/fluttercandies/flutter_image_editor/pull/88>
- Fixes scaling on android and added aspect ratio by @ruerob in <https://github.com/fluttercandies/flutter_image_editor/pull/70>
- 🔥 Clean by @AlexV525 in <https://github.com/fluttercandies/flutter_image_editor/pull/90>
- Support macOS by @CaiJingLong in <https://github.com/fluttercandies/flutter_image_editor/pull/92>

### New Contributors in 1.1.0

- @MagTuxGit made their first contribution in <https://github.com/fluttercandies/flutter_image_editor/pull/61>
- @paricleu made their first contribution in <https://github.com/fluttercandies/flutter_image_editor/pull/88>
- @ruerob made their first contribution in <https://github.com/fluttercandies/flutter_image_editor/pull/70>

**Full Changelog**: <https://github.com/fluttercandies/flutter_image_editor/compare/1.0.2...1.1.0>

## 1.0.2

- Avoid unnecessary memory consuming by temp bitmaps on Android. (#81)

## 1.0.1

- Migrate to Android embedding v2.
- Remove unnecessary files.
- Fix `cacheRawData` issue in the example.

## 1.0.0

First nullsafety version.

## 0.7.3

Fix: rotate error.

## 0.7.2

Fix: #43

## 0.7.1+1

Clean up readme.

## 0.7.1

Add text support custom font.

## 0.7.0

Support draw options.

## 0.6.1

Support 5x4 color matrix
The ImageSource code has been slightly optimized.

## 0.6.0

Merge multi images.

## 0.5.1

Fix some png background error.

## 0.5.0

Support add text.

## 0.4.1

Split option file.

## 0.4.0+2

Update readme.

## 0.4.0+1

Update readme.

## 0.4.0

New Feature:

- ScaleOption

Fix:

- output format

## 0.3.0

Support some color option.

- [x] brightness
- [x] contrast
- [x] saturation

## 0.2.0

Migrate swift to objc.

## 0.1.6

Fix:

- error of editImageAndGetFile.

## 0.1.5

Fix:

- Fix `cachePath` error.

## 0.1.4

Feature:

- Round the trimming data to prevent errors caused by precision problems.
- Use gcd to handle image on iOS.

Fix :

- Problem with a rotation angle of 180 degrees on IOS.

## 0.1.3

Fix

- Image orientation of camera on ios.

## 0.1.2

Fix

- If the exif contains the orientation information, it will be automatically corrected.

Add

- Support output format.

## 0.1.1

Optimized the process of processing code.

Reduce the number of encoding and decoding to improve efficiency.

## 0.1.0

First version.

- [crop]
- [rotate]
- [flip]
