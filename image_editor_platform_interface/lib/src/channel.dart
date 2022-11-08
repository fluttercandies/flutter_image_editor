import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'option/edit_options.dart';

/// Wrapper for [MethodChannel].
class NativeChannel {
  const NativeChannel._();

  /// The channel for use native method.
  static const MethodChannel channel = MethodChannel(
    'com.fluttercandies/image_editor',
  );

  /// Get the cache directory path.
  static Future<Directory> getCachePath() async {
    final path = await channel.invokeMethod('getCachePath');
    return Directory(path);
  }

  /// Handle memory source and get file result.
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

  /// Handle memory source and get momory result.
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

  /// Handle file source and get momory result.
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

  /// Handle file source and get file result.
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
