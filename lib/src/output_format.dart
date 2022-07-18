import 'convert_value.dart';
import 'type.dart';

class OutputFormat with JsonAble {
  const OutputFormat.jpeg(this.quality)
      : format = ImageFormat.jpeg,
        assert(quality > 0 && quality <= 100);

  const OutputFormat.png([this.quality = 100])
      : format = ImageFormat.png,
        assert(quality > 0 && quality <= 100);

  /// See [ImageFormat].
  final ImageFormat format;

  /// Range from 1 to 100.
  /// If format is png, then ios will ignore it.
  final int quality;

  @override
  Map<String, Object> toJson() {
    return <String, Object>{'format': format.index, 'quality': quality};
  }
}
