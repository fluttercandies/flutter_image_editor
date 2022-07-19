import 'dart:io';
import 'dart:typed_data';

import 'package:image_editor/src/channel.dart';

import 'merge_option.dart';

/// Use the class to merge multiple images.
class ImageMerger {
  const ImageMerger._();

  /// Merge multiple images.
  static Future<Uint8List?> mergeToMemory({required ImageMergeOption option}) {
    return NativeChannel.channel.invokeMethod('mergeToMemory', {
      'option': option.toJson(),
    });
  }

  /// Merge multiple images and get file.
  static Future<File?> mergeToFile({required ImageMergeOption option}) {
    return NativeChannel.channel.invokeMethod('mergeToFile', {
      'option': option.toJson(),
    });
  }
}
