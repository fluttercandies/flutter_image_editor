import 'dart:io';
import 'dart:typed_data';

import 'convert_value.dart';

/// Used to describe the source of an image.
abstract class ImageSource with JsonAble {
  /// Used to describe the source of an image.
  const ImageSource();

  /// Used to describe the memory image.
  factory ImageSource.memory(Uint8List uint8list) {
    return MemoryImageSource(uint8list);
  }

  /// Used to describe the file image.
  factory ImageSource.file(File file) {
    return FileImageSource(file);
  }

  /// Used to describe the file image.
  factory ImageSource.path(String path) {
    return FileImageSource.path(path);
  }

  /// The image data as [Uint8List].
  Uint8List get memory;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'memory': memory};
}

/// The memory image source.
class MemoryImageSource extends ImageSource {
  const MemoryImageSource(Uint8List uint8list) : memory = uint8list;

  @override
  final Uint8List memory;
}

/// The file image source.
class FileImageSource extends ImageSource {
  /// Use [file] to create image source.
  const FileImageSource(this.file);

  /// Use [path] to create image source.
  FileImageSource.path(String path) : file = File(path);

  /// The file of image.
  final File file;

  @override
  Uint8List get memory {
    assert(file.existsSync(), 'The file must exists.');
    return file.readAsBytesSync();
  }
}
