import 'package:flutter/material.dart';
import 'package:image_editor/src/output_format.dart';

import '../convert_value.dart';
import '../image_source.dart';
import '../position.dart';

class ImageMergeOption with JsonAble {
  final Size canvasSize;

  final List<MergeImageConfig> mergeImageConfig = [];

  final OutputFormat format;

  ImageMergeOption({
    @required this.canvasSize,
    this.format = const OutputFormat.jpeg(90),
  })  : assert(canvasSize != null),
        assert(canvasSize.width > 0 && canvasSize.height > 0);

  void addImage(MergeImageConfig config) {
    mergeImageConfig.add(config);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'images': mergeImageConfig.map((e) => e.toJson()).toList(),
      'fmt': format.toJson(),
      'w': canvasSize.width.toInt(),
      'h': canvasSize.height.toInt(),
    };
  }
}

class MergeImageConfig with JsonAble {
  final ImageSource image;
  final ImagePosition position;

  MergeImageConfig({
    @required this.image,
    @required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'src': image.toJson(),
      'position': position.toJson(),
    };
  }
}
