/// The main library that contains all functions integrating with photo library.
///
/// To use, import `package:image_editor/image_editor.dart`.
library image_editor_common;

import 'dart:io';
import 'dart:typed_data';

import 'package:image_editor_platform_interface/image_editor_platform_interface.dart';

class ImageEditorOhos extends ImageEditorPlatform {
  static void registerWith() {
    ImageEditorPlatform.instance = ImageEditorOhos();
  }

  @override
  Future<Uint8List?> editImage({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List? tmp = image;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.memory(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }
      editOption.outputFormat = imageEditorOption.outputFormat;
      tmp = await handler.handleAndGetUint8List(editOption);
    }
    return tmp;
  }

  @override
  Future<Uint8List?> editFileImage({
    required File file,
    required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List? tmp;
    bool isHandle = false;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.file(file);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }
      editOption.outputFormat = imageEditorOption.outputFormat;
      tmp = await handler.handleAndGetUint8List(editOption);
      isHandle = true;
    }
    if (isHandle) {
      return tmp;
    } else {
      return file.readAsBytesSync();
    }
  }

  @override
  Future<File?> editFileImageAndGetFile({
    required File file,
    required ImageEditorOption imageEditorOption,
  }) async {
    File? tmp = file;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.file(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }
      editOption.outputFormat = imageEditorOption.outputFormat;
      final target = await _createTmpFilePath();
      tmp = await handler.handleAndGetFile(editOption, target);
    }
    return tmp;
  }

  @override
  Future<File> editImageAndGetFile({
    required Uint8List image,
    required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List? tmp = image;
    for (final group in imageEditorOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.memory(tmp);
      final editOption = ImageEditorOption();
      for (final option in group) {
        editOption.addOption(option);
      }
      editOption.outputFormat = imageEditorOption.outputFormat;
      tmp = await handler.handleAndGetUint8List(editOption);
    }
    final file = File(await _createTmpFilePath());
    if (tmp != null) {
      await file.writeAsBytes(tmp);
    }
    return file;
  }

  /// The method will create a temp file path.
  static Future<String> _createTmpFilePath() async {
    final cacheDir = await NativeChannel.getCachePath();
    final name = DateTime.now().millisecondsSinceEpoch;
    return '${cacheDir.path}/$name';
  }

  @override
  Future<File?> mergeToFile({required ImageMergeOption option}) async {
    String? filePath = await NativeChannel.channel.invokeMethod('mergeToFile', {
      'option': option.toJson(),
    });
    return filePath != null ? File(filePath) : null;
  }

  @override
  Future<Uint8List?> mergeToMemory({required ImageMergeOption option}) {
    return NativeChannel.channel.invokeMethod('mergeToMemory', {
      'option': option.toJson(),
    });
  }
}
