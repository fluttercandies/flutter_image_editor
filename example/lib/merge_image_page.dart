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
  ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'merge',
        ),
      ),
      body: Column(
        children: <Widget>[
          FlatButton(
            onPressed: _merge,
            child: Text('merge'),
          ),
          Slider(
            value: count.toDouble(),
            divisions: 4,
            label: 'count : $count',
            min: 2,
            max: 6,
            onChanged: (v) {
              this.count = v.toInt();
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
        child: Image(image: provider),
        width: 300,
        height: 300,
      );
    return Container();
  }

  void _merge() async {
    final slideLength = 180.0;
    final option = ImageMergeOption(
      canvasSize: Size(slideLength * count, slideLength * count),
      format: OutputFormat.png(),
    );

    final memory = await loadFromAsset(R.ASSETS_ICON_PNG);
    for (var i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(slideLength * i, slideLength * i),
            Size.square(slideLength),
          ),
        ),
      );
    }
    for (var i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(
            Offset(
                slideLength * count - slideLength * (i + 1), slideLength * i),
            Size.square(slideLength),
          ),
        ),
      );
    }

    final result = await ImageMerger.mergeToMemory(option: option);
    provider = MemoryImage(result);
    setState(() {});
  }
}
