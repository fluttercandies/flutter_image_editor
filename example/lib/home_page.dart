import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_editor_example/advanced_page.dart';
import 'package:flutter_image_editor_example/mix_image_page.dart';
import 'package:flutter_image_editor_example/widget/scale_widget.dart';

import 'add_text_page.dart';
import 'const/resource.dart';
import 'package:image_editor/image_editor.dart';

import 'widget/clip_widget.dart';
import 'widget/flip_widget.dart';
import 'widget/rotate_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImageProvider provider;

  @override
  void initState() {
    super.initState();
    provider = AssetImage(R.ASSETS_ICON_PNG);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple usage"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.extension),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AdvancedPage(),
            )),
            tooltip: "Use extended_image library",
          ),
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: restore,
            tooltip: "Restore image to default.",
          ),
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: _addText,
            tooltip: "Add text",
          ),
          IconButton(
            icon: Icon(Icons.branding_watermark),
            onPressed: _mixImage,
            tooltip: "Mix image",
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Image(
              image: provider,
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    FlipWidget(
                      onTap: _flip,
                    ),
                    ClipWidget(
                      onTap: _clip,
                    ),
                    RotateWidget(
                      onTap: _rotate,
                    ),
                    ScaleWidget(
                      onTap: _scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setProvider(ImageProvider provider) {
    this.provider = provider;
    setState(() {});
  }

  void restore() {
    setProvider(AssetImage(R.ASSETS_ICON_PNG));
  }

  Future<Uint8List> getAssetImage() async {
    final byteData = await rootBundle.load(R.ASSETS_ICON_PNG);
    return byteData.buffer.asUint8List();
  }

  void _flip(FlipOption flipOption) async {
    handleOption([flipOption]);
  }

  _clip(ClipOption clipOpt) async {
    handleOption([clipOpt]);
  }

  void _rotate(RotateOption rotateOpt) async {
    handleOption([rotateOpt]);
  }

  void _scale(Option value) {
    handleOption([value]);
  }

  void handleOption(List<Option> options) async {
    ImageEditorOption option = ImageEditorOption();
    for (final o in options) {
      option.addOption(o);
    }

    option.outputFormat = OutputFormat.png();

    final assetImage = await getAssetImage();

    print(JsonEncoder.withIndent('  ').convert(option.toJson()));
    final result = await ImageEditor.editImage(
      image: assetImage,
      imageEditorOption: option,
    );

    final img = MemoryImage(result);
    setProvider(img);
  }

  void _addText() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddTextPage(),
    ));
  }

  void _mixImage() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MixImagePage(),
    ));
  }
}

Widget buildButton(String text, Function onTap) {
  return FlatButton(
    child: Text(text),
    onPressed: onTap,
  );
}
