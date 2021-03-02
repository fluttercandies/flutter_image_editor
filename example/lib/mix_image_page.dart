import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_editor_example/const/resource.dart';
import 'package:image_editor/image_editor.dart';

class MixImagePage extends StatefulWidget {
  @override
  _MixImagePageState createState() => _MixImagePageState();
}

class _MixImagePageState extends State<MixImagePage> {
  ImageProvider? image;

  BlendMode blendMode = BlendMode.srcOver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mix image'),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 1,
            child: Row(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(R.ASSETS_SRC_PNG),
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(R.ASSETS_DST_PNG),
                ),
              ],
            ),
          ),
          Container(
            width: 270,
            height: 270,
            child: image != null
                ? Image(
                    image: image!,
                  )
                : Container(),
          ),
          DropdownButton<BlendMode>(
            items:
                supportBlendModes.map((BlendMode e) => _buildItem(e)).toList(),
            onChanged: _onChange,
            value: blendMode,
          ),
          ElevatedButton(
            child: const Text('mix'),
            onPressed: () {
              mix();
            },
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<BlendMode> _buildItem(BlendMode e) {
    return DropdownMenuItem<BlendMode>(
      child: Text(e.toString()),
      value: e,
    );
  }

  void _onChange(BlendMode? value) {
    if (value == null) {
      return;
    }
    setState(() {
      blendMode = value;
    });
  }

  Future<void> mix() async {
    final Uint8List src = await loadFromAsset(R.ASSETS_SRC_PNG);
    final Uint8List dst = await loadFromAsset(R.ASSETS_DST_PNG);
    final ImageEditorOption optionGroup = ImageEditorOption();
    optionGroup.outputFormat = const OutputFormat.png();
    optionGroup.addOption(
      MixImageOption(
        x: 300,
        y: 300,
        width: 150,
        height: 150,
        target: MemoryImageSource(src),
        blendMode: blendMode,
      ),
    );
    final Uint8List? result =
        await ImageEditor.editImage(image: dst, imageEditorOption: optionGroup);
    if (result == null) {
      image = null;
    } else {
      image = MemoryImage(result);
    }
    setState(() {});
  }

  Future<Uint8List> loadFromAsset(String key) async {
    final ByteData byteData = await rootBundle.load(key);
    return byteData.buffer.asUint8List();
  }
}
