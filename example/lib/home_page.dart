import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'const/resource.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings_backup_restore),
            onPressed: restore,
            tooltip: "Restore image to default.",
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Image(
            image: provider,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  buildButton("flip", _flip),
                  buildButton("clip", _clip),
                ],
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
    final completer = Completer<Uint8List>();

    final config = createLocalImageConfiguration(context);
    final asset = AssetImage(R.ASSETS_ICON_PNG);
    final key = await asset.obtainKey(config);
    final comp = asset.load(key);
    ImageStreamListener listener;
    listener = ImageStreamListener((info, flag) {
      comp.removeListener(listener);
      info.image.toByteData(format: ui.ImageByteFormat.png).then((data) {
        final l = data.buffer.asUint8List();
        completer.complete(l);
      });
    }, onError: (e, s) {
      completer.completeError(e, s);
    });

    comp.addListener(listener);

    asset.resolve(config);

    return completer.future;
  }

  _flip() async {
    final assetImage = await getAssetImage();

    ImageEditOption option = ImageEditOption();
    option.addOption(FlipOption(FlipType.vertical));

    final result =
        await ImageWrapper.memory(assetImage).handleAndGetUint8List(option);

    final img = MemoryImage(result);
    setProvider(img);
  }

  _clip() async {
    final assetImage = await getAssetImage();

    ImageEditOption option = ImageEditOption();
    option.addOption(ClipOption(
      width: 1800,
      height: 1800,
    ));

    final result =
        await ImageWrapper.memory(assetImage).handleAndGetUint8List(option);

    final img = MemoryImage(result);
    setProvider(img);
  }
}

Widget buildButton(String text, Function onTap) {
  return FlatButton(
    child: Text(text),
    onPressed: onTap,
  );
}
