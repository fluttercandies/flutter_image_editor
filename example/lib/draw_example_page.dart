import 'dart:math';
import 'dart:typed_data';

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
  Uint8List? bytes;

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
                bytes == null ? Container() : Image.memory(bytes!),
              ],
            ),
          ),
          addLine(),
          addRect(),
          addOval(),
          addPoints(),
          buildDrawPath(),
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

  PaintingStyle randomPaintStyle() {
    return PaintingStyle.values[Random().nextInt(10) % 2];
  }

  Widget addRect() {
    return ElevatedButton(
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
    return ElevatedButton(
      onPressed: () async {
        List<DrawPart> parts = [];
        for (var i = 0; i < 5; i++) {
          final startOffset = randomOffset();
          final endOffset = randomOffset();
          parts.add(
            LineDrawPart(
              start: startOffset,
              end: endOffset,
              paint: DrawPaint(
                  lineWeight: 30,
                  paintingStyle: PaintingStyle.stroke,
                  color: randomColor()),
            ),
          );
        }
        addDrawParts(parts);
      },
      child: Text('add line'),
    );
  }

  Future<void> addDrawPart(DrawPart part) async {
    await addDrawParts([part]);
  }

  Future<void> addDrawParts(List<DrawPart> parts) async {
    print(parts.map((e) => e.toString()).join('\n'));

    final tu = TimeUtils();

    if (bytes == null) {
      bytes = await loadFromAsset(R.ASSETS_ICON_PNG);
    }
    final opt = ImageEditorOption();
    opt.outputFormat = OutputFormat.png(100);

    for (var item in parts) {
      opt.addOption(
        DrawOption()..addDrawPart(item),
      );
    }

    tu.start();

    bytes = await ImageEditor.editImage(image: bytes!, imageEditorOption: opt);

    print(tu.currentMs());

    setState(() {});
  }

  Widget addOval() {
    return ElevatedButton(
      onPressed: () {
        addDrawPart(
          OvalDrawPart(
            rect: Rect.fromCenter(
              center: randomOffset(),
              width: randomOffset().dx,
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
    return ElevatedButton(
      onPressed: () {
        final dp = PointDrawPart(
          paint: DrawPaint(
            paintingStyle: randomPaintStyle(),
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

  Widget buildDrawPath() {
    return ElevatedButton.icon(
      onPressed: () async {
        final paint = DrawPaint(
          lineWeight: 10,
          paintingStyle: randomPaintStyle(),
          color: randomColor(),
        );
        final path = PathDrawPart(
          autoClose: false,
          paint: paint,
        );
        path.move(Offset.zero);
        path.lineTo(randomOffset(), paint);
        path.lineTo(randomOffset(), paint);
        path.bezier2To(randomOffset(), randomOffset());
        path.bezier3To(randomOffset(), randomOffset(), randomOffset());
        await addDrawPart(path);
      },
      icon: Icon(Icons.format_paint),
      label: Text('paint'),
    );
  }
}
