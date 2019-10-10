import 'dart:io';

import 'package:flutter/services.dart';

import 'edit_options.dart';

class NativeChannel {
  static const MethodChannel _channel =
      const MethodChannel('top.kikt/flutter_image_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Directory> getCachePath() async {
    final path = await _channel.invokeMethod("getCachePath");
    return Directory(path);
  }

  static Future<String> handleResult(
      String srcPath, ImageEditorOption option, String targetPath) async {
    if (option.options.isEmpty) {
      return srcPath;
    }

    if (option.canIgnore) {
      return srcPath;
    }

    return _channel.invokeMethod("handleImage", {
      "src": srcPath,
      "target": targetPath,
      "options": option.toJson(),
    });
  }
}
