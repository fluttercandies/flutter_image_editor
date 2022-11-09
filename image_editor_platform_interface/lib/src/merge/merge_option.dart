import 'package:flutter/material.dart';

import '../convert_value.dart';
import '../image_source.dart';
import '../output_format.dart';
import '../position.dart';

/// Merge multiple images option.
class ImageMergeOption with JsonAble {
  ImageMergeOption({
    required this.canvasSize,
    this.format = const OutputFormat.jpeg(90),
  }) : assert(canvasSize > Size.zero);

  /// The canvas size. (output image size)
  final Size canvasSize;

  /// Output format for result image.
  final OutputFormat format;

  /// All merge image options.
  final List<MergeImageConfig> _mergeImageConfig = <MergeImageConfig>[];

  /// Add a merge image option.
  void addImage(MergeImageConfig config) {
    _mergeImageConfig.add(config);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'images': _mergeImageConfig.map((e) => e.toJson()).toList(),
      'fmt': format.toJson(),
      'w': canvasSize.width.toInt(),
      'h': canvasSize.height.toInt(),
    };
  }
}

/// Merge image option.
class MergeImageConfig with JsonAble {
  /// Merge image option.
  const MergeImageConfig({
    required this.image,
    required this.position,
  });

  /// The image source.
  final ImageSource image;

  /// The position of image.
  final ImagePosition position;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'src': image.toJson(),
      'position': position.toJson(),
    };
  }
}
