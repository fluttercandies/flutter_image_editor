import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' show pi;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/const/resource.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';

class AdvancedPage extends StatefulWidget {
  @override
  _AdvancedPageState createState() => _AdvancedPageState();
}

class _AdvancedPageState extends State<AdvancedPage> {
  final editorKey = GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: crop,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ExtendedImage.asset(
              R.ASSETS_ICON_PNG,
              extendedImageEditorKey: editorKey,
              mode: ExtendedImageMode.editor,
              initEditorConfigHandler: (state) {
                return EditorConfig(
                  maxScale: 8.0,
                  cropRectPadding: EdgeInsets.all(20.0),
                  hitTestSize: 20.0,
                  cropAspectRatio: 1,
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.flip),
                onPressed: flip,
              ),
              IconButton(
                icon: Icon(Icons.rotate_left),
                onPressed: () => rotate(false),
              ),
              IconButton(
                icon: Icon(Icons.rotate_right),
                onPressed: () => rotate(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void crop() async {
    final state = editorKey.currentState;
    final rect = state.getCropRect();
    final radian = state.editAction.rotateAngle;

    final img = await getAssetImage();
    final wrapper = ImageWrapper.memory(img);

    ImageEditOption option = ImageEditOption();

    option.addOption(RotateOption.radian(radian));
    option.addOption(ClipOption.fromRect(rect));

    var result = await wrapper.handleAndGetUint8List(option);

    // final tmp = ImageWrapper.memory(result);
    // option.reset();
    // final h = state.editAction.flipX;
    // final v = state.editAction.flipY;
    // option.addOption(FlipOption(vertical: v, horizontal: h));
    // result = await tmp.handleAndGetUint8List(option);

    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.white,
          child: Center(
            child: SizedBox.fromSize(
              size: Size.square(200),
              child: Image.memory(result),
            ),
          ),
        ),
      ),
    );
  }

  void flip() {
    editorKey.currentState.flip();
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

  rotate(bool right) {
    editorKey.currentState.rotate(right: right);
  }
}
