import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_editor_platform_interface/image_editor_platform_interface.dart';
export 'package:image_editor_platform_interface/image_editor_platform_interface.dart';

class ImageEditor {
  const ImageEditor._();

  static ImageEditorPlatform get platform => ImageEditorPlatform.instance;

  /// The [image] is a source of image.
  ///
  /// The [imageEditorOption] option for edit image.
  ///
  /// The method will return a [Uint8List] as image result.
  ///
  /// If result is null, it means handle image error.
  static Future<Uint8List?> editImage({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  }) async {
    return platform.editImage(
      image: image,
      imageEditorOption: imageEditorOption,
    );
  }

  /// The [file] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [Uint8List] as image result.
  ///
  /// If result is null, it means handle image error.
  static Future<Uint8List?> editFileImage({
    required File file,
    required ImageEditorOption imageEditorOption,
  }) async {
    return platform.editFileImage(
      file: file,
      imageEditorOption: imageEditorOption,
    );
  }

  /// The [file] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [File] as image result.
  ///
  /// If result is null, it means handle image error.
  static Future<File?> editFileImageAndGetFile({
    required File file,
    required ImageEditorOption imageEditorOption,
  }) async {
    return platform.editFileImageAndGetFile(
      file: file,
      imageEditorOption: imageEditorOption,
    );
  }

  /// The [image] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [File] as image result.
  ///
  /// If result is null, it means handle image error.
  static Future<File> editImageAndGetFile({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  }) async {
    return platform.editImageAndGetFile(
      image: image,
      imageEditorOption: imageEditorOption,
    );
  }
}

class ImageMerger {
  static ImageEditorPlatform get platform => ImageEditorPlatform.instance;

  const ImageMerger._();

  /// Merge multiple images.
  static Future<Uint8List?> mergeToMemory({required ImageMergeOption option}) {
    return platform.mergeToMemory(option: option);
  }

  /// Merge multiple images and get file.
  static Future<File?> mergeToFile({required ImageMergeOption option}) {
    return platform.mergeToFile(option: option);
  }
}
