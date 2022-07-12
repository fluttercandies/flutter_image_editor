import 'dart:io';

import 'channel.dart';

class FontManager {
  const FontManager._();

  static Future<String> registerFont(File file) async {
    return await NativeChannel.channel.invokeMethod(
      'registerFont',
      <String, Object?>{'path': file.absolute.path},
    );
  }
}
