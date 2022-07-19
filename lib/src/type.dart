/// Output Image format.
///
/// Other types are not supported.
enum ImageFormat {
  /// png
  png,

  /// jpeg
  jpeg
}

/// Image source type.
enum SrcType {
  /// The source is a file.
  ///
  /// Transform is a file path.
  file,

  /// The source is a [Uint8List].
  ///
  /// Transform is a [Uint8List].
  memory
}
