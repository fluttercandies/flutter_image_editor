import 'dart:io';
import 'dart:typed_data';

import 'package:image_editor_platform_interface/image_editor_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ImageEditorPlatform extends PlatformInterface {
  static const _token = Object();

  static ImageEditorPlatform instance = UnsupportedImageEditor();

  ImageEditorPlatform() : super(token: _token);

  /// The [image] is a source of image.
  ///
  /// The [imageEditorOption] option for edit image.
  ///
  /// The method will return a [Uint8List] as image result.
  ///
  /// If result is null, it means handle image error.
  Future<Uint8List?> editImage({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  });

  /// The [file] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [Uint8List] as image result.
  ///
  /// If result is null, it means handle image error.
  Future<Uint8List?> editFileImage({
    required File file,
    required ImageEditorOption imageEditorOption,
  });

  /// The [file] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [File] as image result.
  ///
  /// If result is null, it means handle image error.
  Future<File?> editFileImageAndGetFile({
    required File file,
    required ImageEditorOption imageEditorOption,
  });

  /// The [image] is the source of image.
  ///
  /// The [imageEditorOption] is the option for edit image.
  ///
  /// The method will return a [File] as image result.
  ///
  /// If result is null, it means handle image error.
  Future<File> editImageAndGetFile({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  });

  /// Merge multiple images.
  Future<Uint8List?> mergeToMemory({required ImageMergeOption option});

  /// Merge multiple images and get file.
  Future<File?> mergeToFile({required ImageMergeOption option});
}

class UnsupportedImageEditor extends ImageEditorPlatform {
  @override
  Future<Uint8List?> editFileImage(
      {required File file, required ImageEditorOption imageEditorOption}) {
    throw UnimplementedError();
  }

  @override
  Future<File?> editFileImageAndGetFile(
      {required File file, required ImageEditorOption imageEditorOption}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> editImage(
      {required Uint8List image,
      required ImageEditorOption imageEditorOption}) {
    throw UnimplementedError();
  }

  @override
  Future<File> editImageAndGetFile(
      {required Uint8List image,
      required ImageEditorOption imageEditorOption}) {
    throw UnimplementedError();
  }

  @override
  Future<File?> mergeToFile({required ImageMergeOption option}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> mergeToMemory({required ImageMergeOption option}) {
    throw UnimplementedError();
  }
}
