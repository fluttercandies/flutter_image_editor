import 'dart:io';

import 'channel.dart';

class FontManager {
  static Future<String> registerFont(File file) {
    return NativeChannel.channel.invokeMethod(
      'registerFont',
      {
        'path': file.absolute.path,
      },
    );
  }
}
