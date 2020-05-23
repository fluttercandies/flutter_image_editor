import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_editor/src/channel.dart';
import 'src/edit_options.dart';
import 'src/image_handler.dart';

export 'src/edit_options.dart' hide IgnoreAble, OptionGroup;
export 'src/error.dart';
export 'src/output_format.dart';

class ImageEditor {
  /// [image] Uint8List
  /// [imageEditorOption] option of
  static Future<Uint8List> editImage({
    @required Uint8List image,
    @required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List tmp = image;
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

  static Future<Uint8List> editFileImage({
    @required File file,
    @required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List tmp;
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

  static Future<File> editFileImageAndGetFile({
    @required File file,
    @required ImageEditorOption imageEditorOption,
  }) async {
    File tmp = file;
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

  static Future<File> editImageAndGetFile({
    @required Uint8List image,
    @required ImageEditorOption imageEditorOption,
  }) async {
    Uint8List tmp = image;

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

    return file.writeAsBytes(tmp);
  }

  static Future<String> _createTmpFilePath() async {
    final cacheDir = await NativeChannel.getCachePath();
    final name = DateTime.now().millisecondsSinceEpoch;
    return "${cacheDir.path}/$name";
  }
}
