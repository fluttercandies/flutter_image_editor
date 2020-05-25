import 'dart:io';
import 'dart:typed_data';

abstract class ImageSource {
  Uint8List get memory;

  Map<String, dynamic> toJson() => {
        "memory": memory,
      };
}

class MemoryImageSource extends ImageSource {
  MemoryImageSource(Uint8List uint8list) : memory = uint8list;

  @override
  final Uint8List memory;
}

class FileImageSource extends ImageSource {
  final File file;

  FileImageSource(this.file);

  FileImageSource.path(String path) : file = File(path);

  @override
  Uint8List get memory => file.readAsBytesSync();
}
