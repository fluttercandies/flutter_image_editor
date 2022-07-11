import 'package:flutter/material.dart';

import '../convert_value.dart';
import '../image_source.dart';
import '../output_format.dart';
import '../position.dart';

class ImageMergeOption with JsonAble {
  const ImageMergeOption({
    required this.canvasSize,
    this.format = const OutputFormat.jpeg(90),
  })  : _mergeImageConfig = const <MergeImageConfig>[],
        assert(canvasSize > Size.zero);

  final Size canvasSize;
  final OutputFormat format;
  final List<MergeImageConfig> _mergeImageConfig;

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

class MergeImageConfig with JsonAble {
  const MergeImageConfig({
    required this.image,
    required this.position,
  });

  final ImageSource image;
  final ImagePosition position;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'src': image.toJson(),
      'position': position.toJson(),
    };
  }
}
