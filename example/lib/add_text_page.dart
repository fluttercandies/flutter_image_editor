import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';

import 'const/resource.dart';

class AddTextPage extends StatefulWidget {
  @override
  _AddTextPageState createState() => _AddTextPageState();
}

class _AddTextPageState extends State<AddTextPage> {
  ImageProvider target;

  String get asset => R.ASSETS_ICON_PNG;

  final TextEditingController _controller =
      TextEditingController(text: '输入文字, 添加足够长的字数, 以测试换行的效果是怎么样的.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add text'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2 / 1,
              child: Row(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      asset,
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: target != null
                        ? Image(
                            image: target,
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () async {
                const int size = 120;
                final ImageEditorOption option = ImageEditorOption();
                final AddTextOption textOption = AddTextOption();
                textOption.addText(
                  EditorText(
                    offset: const Offset(0, 0),
                    text: _controller.text,
                    fontSizePx: size,
                  ),
                );
                option.outputFormat = const OutputFormat.png();

                option.addOption(textOption);

                final Uint8List u = await getAssetImage();
                final Uint8List result = await ImageEditor.editImage(
                  image: u,
                  imageEditorOption: option,
                );
                print(option.toString());
                target = MemoryImage(result);
                setState(() {});
              },
              child: const Text('add'),
            ),
            TextField(
              controller: _controller,
            ),
            // Slider(value: null, onChanged: null),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> getAssetImage() async {
    final ByteData byteData = await rootBundle.load(asset);
    return byteData.buffer.asUint8List();
  }
}
