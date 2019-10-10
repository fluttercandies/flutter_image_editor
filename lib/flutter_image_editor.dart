import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'src/edit_options.dart';
import 'src/image_handler.dart';

export 'src/edit_options.dart';
export 'src/image_handler.dart';
export 'src/error.dart';

class FlutterImageEditor {
  static Future<void> initialPlugin() async {
    await ImageHandler.initPath();
  }

  static Future<Uint8List> editImage({
    @required Uint8List image,
    @required ImageEditOption imageEditOption,
  }) async {
    Uint8List tmp = image;
    for (final group in imageEditOption.groupList) {
      if (group.canIgnore) {
        continue;
      }
      final handler = ImageHandler.memory(tmp);
      final editOption = ImageEditOption();
      for (final option in group) {
        editOption.addOption(option);
      }

      tmp = await handler.handleAndGetUint8List(editOption);
    }

    return tmp;
  }

  static Future<Uint8List> editFileImage({
    @required File file,
    @required ImageEditOption imageEditOption,
  }) async {
    Uint8List tmp;
    bool handle = false;
    for (final option in imageEditOption.options) {
      if (option.canIgnore) {
        continue;
      }
      final handler = ImageHandler.file(file);
      tmp = await handler
          .handleAndGetUint8List(ImageEditOption()..addOption(option));
      handle = true;
    }

    if (handle) {
      return tmp;
    } else {
      return file.readAsBytesSync();
    }
  }
}
