import 'dart:io';

import 'channel.dart';

class FontManager {
  static Future<String> registerFont(File file) async {
    return await NativeChannel.channel.invokeMethod(
      'registerFont',
      {
        'path': file.absolute.path,
      },
    );
  }
}
