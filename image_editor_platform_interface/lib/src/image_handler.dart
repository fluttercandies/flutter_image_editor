import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'channel.dart';
import 'error.dart';
import 'option/edit_options.dart';
import 'type.dart';

/// Wrapper for use channel to handle image.
class ImageHandler {
  ImageHandler.memory(this._memory)
      : _type = SrcType.memory,
        _file = null;

  ImageHandler.file(this._file)
      : _type = SrcType.file,
        _memory = null;

  final SrcType _type;
  final File? _file;
  final Uint8List? _memory;

  Future<File?> handleAndGetFile(
    ImageEditorOption option,
    String targetPath,
  ) async {
    return _handle(() async {
      final String path;
      switch (_type) {
        case SrcType.file:
          path = await NativeChannel.fileToFile(
            _file!.path,
            option,
            targetPath,
          );
          break;
        case SrcType.memory:
          path = await NativeChannel.memoryToFile(_memory!, option, targetPath);
          break;
      }
      return File(path);
    });
  }

  Future<Uint8List?> handleAndGetUint8List(ImageEditorOption option) async {
    return _handle(() async {
      switch (_type) {
        case SrcType.file:
          return NativeChannel.fileToMemory(_file!.path, option);
        case SrcType.memory:
          return NativeChannel.memoryToMemory(_memory!, option);
      }
    });
  }

  Future<T> _handle<T>(Future<T> Function() fn) {
    try {
      return fn();
    } on PlatformException catch (e) {
      throw HandleError(e.code);
    } on Exception catch (e) {
      throw HandleError('Unhandled exception: $e');
    } on Error catch (e) {
      throw HandleError('Unhandled error: $e');
    }
  }
}
