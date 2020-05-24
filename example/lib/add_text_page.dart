import 'dart:convert';
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

  TextEditingController _controller = TextEditingController(text: "输入文字");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add text'),
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
                final size = 120;
                final option = ImageEditorOption();
                final textOption = AddTextOption();
                textOption.addText(
                  EditorText(
                    offset: Offset(0, 0),
                    text: this._controller.text,
                    fontSizePx: size,
                  ),
                );
                option.outputFormat = OutputFormat.png();

                option.addOption(textOption);

                final u = await getAssetImage();
                final result = await ImageEditor.editImage(
                  image: u,
                  imageEditorOption: option,
                );
                print(JsonEncoder.withIndent('  ').convert(option.toJson()));
                this.target = MemoryImage(result);
                setState(() {});
              },
              child: Text('add'),
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
    final byteData = await rootBundle.load(asset);
    return byteData.buffer.asUint8List();
  }
}
