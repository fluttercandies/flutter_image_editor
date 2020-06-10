class OutputFormat {
  /// see [ImageFormat].
  final ImageFormat format;

  /// Rangel from 1 to 100.
  /// If format is png, then ios will ignore it.
  final int quality;

  const OutputFormat.jpeg(this.quality)
      : format = ImageFormat.jpeg,
        assert(quality > 0 && quality <= 100);

  const OutputFormat.png([this.quality = 100]) : format = ImageFormat.png;

  Map<String, Object> toJson() {
    return {
      "format": format.index,
      "quality": quality,
    };
  }
}

enum ImageFormat {
  png,
  jpeg,
}
