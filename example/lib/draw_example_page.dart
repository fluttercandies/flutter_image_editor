import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/utils/time_utils.dart';
import 'package:image_editor/image_editor.dart';

import 'const/resource.dart';
import 'main.dart';

class DrawExamplePage extends StatefulWidget {
  @override
  _DrawExamplePageState createState() => _DrawExamplePageState();
}

class _DrawExamplePageState extends State<DrawExamplePage> {
  Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('draw example'),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 2 / 1,
            child: Row(
              children: <Widget>[
                Image.asset(
                  R.ASSETS_ICON_PNG,
                ),
                bytes == null ? Container() : Image.memory(bytes),
              ],
            ),
          ),
          addLine(),
          addRect(),
          addOval(),
          addPoints(),
        ],
      ),
    );
  }

  Offset randomOffset() {
    final x = Random().nextInt(1919) + 1;
    final y = Random().nextInt(1919) + 1;
    return Offset(x.toDouble(), y.toDouble());
  }

  Color randomColor() {
    final rand = Random();
    final r = rand.nextInt(255);
    final g = rand.nextInt(255);
    final b = rand.nextInt(255);
    final a = rand.nextInt(100) + 155;
    return Color.fromARGB(a, r, g, b);
  }

  Widget addRect() {
    return RaisedButton(
      onPressed: () async {
        addDrawPart(
          RectDrawPart(
            paint: DrawPaint(
              lineWeight: 5,
              paintingStyle: PaintingStyle.fill,
              color: randomColor(),
            ),
            rect: Rect.fromPoints(randomOffset(), randomOffset()),
          ),
        );
      },
      child: Text('add rect'),
    );
  }

  Widget addLine() {
    return RaisedButton(
      onPressed: () async {
        final startOffset = randomOffset();
        final endOffset = randomOffset();
        addDrawPart(
          LineDrawPart(
            start: startOffset,
            end: endOffset,
            paint: DrawPaint(lineWeight: 5),
          ),
        );
      },
      child: Text('add line'),
    );
  }

  void addDrawPart(DrawPart part) async {
    print(part.toString());

    final tu = TimeUtils();

    if (bytes == null) {
      bytes = await loadFromAsset(R.ASSETS_ICON_PNG);
    }
    final opt = ImageEditorOption();
    opt.outputFormat = OutputFormat.png(100);

    opt.addOption(
      DrawOption()..addDrawPart(part),
    );

    tu.start();

    bytes = await ImageEditor.editImage(image: bytes, imageEditorOption: opt);

    print(tu.currentMs());

    setState(() {});
  }

  Widget addOval() {
    return RaisedButton(
      onPressed: () {
        addDrawPart(
          OvalDrawPart(
            rect: Rect.fromCenter(
              center: randomOffset(),
              width: 300,
              height: 300,
            ),
            paint: DrawPaint(
              paintingStyle: PaintingStyle.values[Random().nextInt(10) % 2],
              color: randomColor(),
            ),
          ),
        );
      },
      child: Text('add circle'),
    );
  }

  Widget addPoints() {
    return RaisedButton(
      onPressed: () {
        final dp = PointDrawPart(
          paint: DrawPaint(
            paintingStyle: PaintingStyle.values[Random().nextInt(10) % 2],
            color: randomColor(),
            lineWeight: 150,
          ),
        );
        dp.points.addAll(
          <Offset>[
            randomOffset(),
            randomOffset(),
            randomOffset(),
          ],
        );
        addDrawPart(dp);
      },
      child: Text('add points'),
    );
  }
}
