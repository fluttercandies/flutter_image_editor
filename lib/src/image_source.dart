import 'dart:io';
import 'dart:typed_data';

abstract class ImageSource {
  Uint8List get memory;

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

  Map<String, Object> toJson() => {
        "memory": memory,
      };
}

class MemoryImageSource extends ImageSource {
  @override
  final Uint8List memory;

  const MemoryImageSource(Uint8List uint8list) : memory = uint8list;
}

class FileImageSource extends ImageSource {
  final File file;

  const FileImageSource(this.file);

  FileImageSource.path(String path) : file = File(path);

  @override
  Uint8List get memory {
    assert(file.existsSync(), 'The file must exists');
    return file.readAsBytesSync();
  }
}
