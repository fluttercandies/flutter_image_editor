import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/const/resource.dart';
import 'package:image_editor/image_editor.dart';

import 'main.dart';

class MergeImagePage extends StatefulWidget {
  @override
  _MergeImagePageState createState() => _MergeImagePageState();
}

class _MergeImagePageState extends State<MergeImagePage> {
  int count = 2;
  ImageProvider? provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'merge',
        ),
      ),
      body: Column(
        children: <Widget>[
          TextButton(
            onPressed: _merge,
            child: const Text('merge'),
          ),
          Slider(
            value: count.toDouble(),
            divisions: 4,
            label: 'count : $count',
            min: 2,
            max: 6,
            onChanged: (double v) {
              count = v.toInt();
              setState(() {});
            },
          ),
          buildImageResult(),
        ],
      ),
    );
  }

  Widget buildImageResult() {
    if (provider != null)
      return Container(
        child: Image(image: provider!),
        width: 300,
        height: 300,
      );
    return Container();
  }

  Future<void> _merge() async {
    const double slideLength = 180.0;
    final ImageMergeOption option = ImageMergeOption(
      canvasSize: Size(slideLength * count, slideLength * count),
      format: const OutputFormat.png(),
    );

    final Uint8List memory = await loadFromAsset(R.ASSETS_ICON_PNG);
    for (int i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(slideLength * i, slideLength * i),
            const Size.square(slideLength),
          ),
        ),
      );
    }
    for (int i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(
                slideLength * count - slideLength * (i + 1), slideLength * i),
            const Size.square(slideLength),
          ),
        ),
      );
    }

    final Uint8List? result = await ImageMerger.mergeToMemory(option: option);
    if (result == null) {
      provider = null;
    } else {
      provider = MemoryImage(result);
    }
    setState(() {});
  }
}
