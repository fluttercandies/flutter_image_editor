import 'dart:io';
import 'dart:typed_data';

import 'convert_value.dart';

abstract class ImageSource with JsonAble {
  const ImageSource();

  factory ImageSource.memory(Uint8List uint8list) {
    return MemoryImageSource(uint8list);
  }

  factory ImageSource.file(File file) {
    return FileImageSource(file);
  }

  factory ImageSource.path(String path) {
    return FileImageSource.path(path);
  }

  Uint8List get memory;

  @override
  Map<String, Object?> toJson() => <String, Object?>{'memory': memory};
}

class MemoryImageSource extends ImageSource {
  const MemoryImageSource(Uint8List uint8list) : memory = uint8list;

  @override
  final Uint8List memory;
}

class FileImageSource extends ImageSource {
  const FileImageSource(this.file);

  FileImageSource.path(String path) : file = File(path);

  final File file;

  @override
  Uint8List get memory {
    assert(file.existsSync(), 'The file must exists.');
    return file.readAsBytesSync();
  }
}
