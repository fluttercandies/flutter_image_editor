import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_editor_example/widget/examples.dart';
import 'package:flutter_image_editor_example/widget/scale_widget.dart';

import 'package:image_editor/image_editor.dart'
    show
        ClipOption,
        FlipOption,
        ImageEditor,
        ImageEditorOption,
        Option,
        OutputFormat,
        RotateOption;

import 'const/resource.dart';
import 'widget/clip_widget.dart';
import 'widget/flip_widget.dart';
import 'widget/rotate_widget.dart';

class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index'),
      ),
      body: Examples(),
    );
  }
}

class SimpleExamplePage extends StatefulWidget {
  @override
  _SimpleExamplePageState createState() => _SimpleExamplePageState();
}

class _SimpleExamplePageState extends State<SimpleExamplePage> {
  ImageProvider? provider = AssetImage(R.ASSETS_ICON_PNG);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple usage'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: restore,
            tooltip: 'Restore image to default.',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (provider != null)
            AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: provider!,
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

  void setProvider(ImageProvider? provider) {
    this.provider = provider;
    setState(() {});
  }

  void restore() {
    setProvider(AssetImage(R.ASSETS_ICON_PNG));
  }

  Future<Uint8List> getAssetImage() async {
    final ByteData byteData = await rootBundle.load(R.ASSETS_ICON_PNG);
    return byteData.buffer.asUint8List();
  }

  Future<void> _flip(FlipOption flipOption) async {
    handleOption(<Option>[flipOption]);
  }

  Future<void> _clip(ClipOption clipOpt) async {
    handleOption(<Option>[clipOpt]);
  }

  Future<void> _rotate(RotateOption rotateOpt) async {
    handleOption(<Option>[rotateOpt]);
  }

  void _scale(Option value) {
    handleOption(<Option>[value]);
  }

  Future<void> handleOption(List<Option> options) async {
    final ImageEditorOption option = ImageEditorOption();
    for (int i = 0; i < options.length; i++) {
      final Option o = options[i];
      option.addOption(o);
    }

    option.outputFormat = const OutputFormat.png();

    final Uint8List assetImage = await getAssetImage();

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));
    final Uint8List? result = await ImageEditor.editImage(
      image: assetImage,
      imageEditorOption: option,
    );

    if (result == null) {
      setProvider(null);
      return;
    }

    final MemoryImage img = MemoryImage(result);
    setProvider(img);
  }
}

Widget buildButton(String text, VoidCallback onTap) {
  return TextButton(
    child: Text(text),
    onPressed: onTap,
  );
}
