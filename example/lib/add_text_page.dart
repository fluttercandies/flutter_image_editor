import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:http/http.dart' as http;

import 'const/resource.dart';

class AddTextPage extends StatefulWidget {
  @override
  _AddTextPageState createState() => _AddTextPageState();
}

class _AddTextPageState extends State<AddTextPage> {
  ImageProvider? target;

  String get asset => R.ASSETS_ICON_PNG;

  final TextEditingController _controller =
      TextEditingController(text: '输入文字, 添加足够长的字数, 以测试换行的效果是怎么样的.');

  String fontName = '';

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
                            image: target!,
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await addText(fontName);
                  },
                  child: const Text('add'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await addText('');
                  },
                  child: const Text('add use defaultFont'),
                ),
              ],
            ),
            ElevatedButton(
              child: Text('download and register font'),
              onPressed: () async {
                final aliFontUrl =
                    'https://cdn.jsdelivr.net/gh/kikt-blog/ali_font@master/Alibaba-PuHuiTi-Medium.ttf';

                final body = await http.get(Uri.parse(aliFontUrl));

                final tmpDir = await pp.getTemporaryDirectory();
                final f = File(
                    '${tmpDir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.ttf');
                f.writeAsBytesSync(body.bodyBytes);

                fontName = await FontManager.registerFont(f);

                showToast('register $fontName success');
              },
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

  Future addText(String fontName) async {
    const int size = 120;
    final ImageEditorOption option = ImageEditorOption();
    final AddTextOption textOption = AddTextOption();
    textOption.addText(
      EditorText(
        offset: const Offset(0, 0),
        text: _controller.text,
        fontSizePx: size,
        textColor: const Color(0xFF995555),
        fontName: fontName,
      ),
    );
    option.outputFormat = const OutputFormat.png();

    option.addOption(textOption);

    final Uint8List u = await getAssetImage();
    final Uint8List? result = await ImageEditor.editImage(
      image: u,
      imageEditorOption: option,
    );
    print(option.toString());

    if (result == null) {
      return;
    }
    target = MemoryImage(result);
    setState(() {});
  }

  Future<Uint8List> getAssetImage() async {
    final ByteData byteData = await rootBundle.load(asset);
    return byteData.buffer.asUint8List();
  }
}
