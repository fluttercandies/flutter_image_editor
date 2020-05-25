import 'dart:io';
import 'dart:typed_data';

abstract class ImageSource {
  Uint8List get memory;

  Map<String, dynamic> toJson() => {
        "memory": memory,
      };
}

class MemorySource extends ImageSource {
  MemorySource(Uint8List uint8list) : memory = uint8list;

  @override
  final Uint8List memory;
}

class FileSource extends ImageSource {
  final File file;

  FileSource(this.file);

  FileSource.path(String path) : file = File(path);

  @override
  Uint8List get memory => file.readAsBytesSync();
}
