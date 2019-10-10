import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_image_editor/src/channel.dart';
import 'package:flutter_image_editor/src/edit_options.dart';
import 'package:flutter_image_editor/src/error.dart';

class ImageHandler {
  static String _tmpDir;

  static Future<void> initPath() async {
    _tmpDir = (await NativeChannel.getCachePath()).absolute.path;
  }

  String _path;

  ImageHandler._();

  factory ImageHandler.memory(Uint8List uint8list) {
    ImageHandler image = ImageHandler._();
    final tmp = DateTime.now().microsecondsSinceEpoch;
    final path = "$_tmpDir/$tmp";
    image._path = path;
    final f = File(path);
    f.writeAsBytesSync(uint8list);
    return image;
  }

  factory ImageHandler.file(File file) {
    ImageHandler image = ImageHandler._();
    image._path = file.absolute.path;
    return image;
  }

  Future<File> handleAndGetFile(
      ImageEditOption option, String targetPath) async {
    try {
      final String path =
          await NativeChannel.handleResult(_path, option, targetPath);
      if (path == null) {
        throw HandleError("Processing failed.");
      }
      return File(path);
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

  Future<Uint8List> handleAndGetUint8List(ImageEditOption option) async {
    File file = File("$_tmpDir/${DateTime.now().microsecondsSinceEpoch}");
    file.createSync(recursive: true);
    final result = await handleAndGetFile(option, file.absolute.path);
    final list = result.readAsBytesSync();
    result.deleteSync();
    return list;
  }
}
