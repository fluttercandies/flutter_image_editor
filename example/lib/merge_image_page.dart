import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          if (provider != null)
            Container(
              child: Image(image: provider),
              width: 300,
              height: 300,
            ),
        ],
      ),
    );
  }

  void _merge() async {
    final option = ImageMergeOption(
      canvasSize: Size(360, 360.0 * count),
      format: OutputFormat.png(),
    );

    final memory = await loadFromAsset(R.ASSETS_ICON_PNG);
    for (var i = 0; i < count; i++) {
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(memory),
          position: ImagePosition(Offset(0, 360.0 * i), Size.square(360)),
        ),
      );
    }

    final result = await ImageMerger.mergeToMemory(option: option);
    provider = MemoryImage(result);
    setState(() {});
  }
}
