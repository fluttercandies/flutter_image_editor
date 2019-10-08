import 'package:flutter/services.dart';
import 'package:flutter_image_editor/src/edit_options.dart';

class NativeChannel {
  static const MethodChannel _channel =
      const MethodChannel('top.kikt/flutter_image_editor');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> handleResult(
      String srcPath, ImageEditOption option, String targetPath) async {
    if (option.options.isEmpty) {
      return srcPath;
    }
    return _channel.invokeMethod("handleImage", {
      "src": srcPath,
      "target": targetPath,
      "options": option.toJson(),
    });
  }
}
