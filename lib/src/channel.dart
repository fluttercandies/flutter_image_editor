import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'option/edit_options.dart';

class NativeChannel {
  const NativeChannel._();

  static const MethodChannel channel = MethodChannel(
    'top.kikt/flutter_image_editor',
  );

  static Future<Directory> getCachePath() async {
    final path = await channel.invokeMethod('getCachePath');
    return Directory(path);
  }

  static Future<String> memoryToFile(
    Uint8List memory,
    ImageEditorOption option,
    String targetPath,
  ) async {
    if (option.options.isEmpty || option.canIgnore) {
      return (File(targetPath)..writeAsBytesSync(memory)).path;
    }
    return await channel.invokeMethod('memoryToFile', {
      'image': memory,
      'target': targetPath,
      'options': option.toJson(),
      'fmt': option.outputFormat.toJson(),
    });
  }

  static Future<Uint8List> memoryToMemory(
    Uint8List memory,
    ImageEditorOption option,
  ) async {
    if (option.options.isEmpty || option.canIgnore) {
      return memory;
    }

    final result = await channel.invokeMethod('memoryToMemory', {
      'image': memory,
      'options': option.toJson(),
      'fmt': option.outputFormat.toJson(),
    });
    return result;
  }

  static Future<Uint8List> fileToMemory(
    String path,
    ImageEditorOption option,
  ) async {
    if (option.options.isEmpty || option.canIgnore) {
      return File(path).readAsBytesSync();
    }

    return await channel.invokeMethod('fileToMemory', {
      'src': path,
      'options': option.toJson(),
      'fmt': option.outputFormat.toJson(),
    });
  }

  static Future<String> fileToFile(
    String src,
    ImageEditorOption option,
    String target,
  ) async {
    if (option.options.isEmpty || option.canIgnore) {
      return src;
    }

    return await channel.invokeMethod('fileToFile', {
      'src': src,
      'target': target,
      'options': option.toJson(),
      'fmt': option.outputFormat.toJson(),
    });
  }
}
