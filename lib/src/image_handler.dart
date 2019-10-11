import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'channel.dart';
import 'edit_options.dart';
import 'error.dart';
import 'type.dart';

class ImageHandler {
  static String _tmpDir;

  static Future<void> initPath() async {
    _tmpDir = (await NativeChannel.getCachePath()).absolute.path;
  }

  SrcType _type;

  File _file;

  Uint8List _memory;

  ImageHandler.memory(this._memory) : _type = SrcType.memory;

  ImageHandler.file(this._file) : _type = SrcType.file;

  Future<File> handleAndGetFile(
      ImageEditorOption option, String targetPath) async {
    try {
      if (_type == SrcType.file) {
        return File(
            await NativeChannel.fileToFile(_file.path, option, targetPath));
      } else if (_type == SrcType.memory) {
        return File(
            await NativeChannel.memoryToFile(_memory, option, targetPath));
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      throw HandleError(e.code);
    } on Exception catch (e) {
      print(e.toString());
      throw HandleError("Unhandled exception : $e");
    } on Error catch (e) {
      print(e.stackTrace.toString());
      throw HandleError("Unhandled error : $e");
    }
  }

  Future<Uint8List> handleAndGetUint8List(ImageEditorOption option) async {
    try {
      if (_type == SrcType.file) {
        return NativeChannel.fileToMemory(_file.path, option);
      } else if (_type == SrcType.memory) {
        return NativeChannel.memoryToMemory(_memory, option);
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      throw HandleError(e.code);
    } on Exception catch (e) {
      print(e.toString());
      throw HandleError("Unhandled exception : $e");
    } on Error catch (e) {
      print(e.stackTrace.toString());
      throw HandleError("Unhandled error : $e");
    }
  }
}
