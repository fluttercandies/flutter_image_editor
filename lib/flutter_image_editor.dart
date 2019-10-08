import 'dart:async';

import 'package:flutter/services.dart';

import 'src/image_wrapper.dart';
export 'src/image_wrapper.dart';
export 'src/edit_options.dart';
export 'src/error.dart';

class FlutterImageEditor {
  static Future<void> initialPlugin() async {
    ImageWrapper.initPath();
  }
}
