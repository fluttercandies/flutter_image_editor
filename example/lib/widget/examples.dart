import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/add_text_page.dart';
import 'package:flutter_image_editor_example/advanced_page.dart';
import 'package:flutter_image_editor_example/draw_example_page.dart';
import 'package:flutter_image_editor_example/home_page.dart';
import 'package:flutter_image_editor_example/merge_image_page.dart';
import 'package:flutter_image_editor_example/mix_image_page.dart';

class Examples extends StatefulWidget {
  @override
  _ExamplesState createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  static List<Widget> get widgets => <Widget>[
        SimpleExamplePage(),
        ExtendedImageExample(),
        AddTextPage(),
        MixImagePage(),
        MergeImagePage(),
        DrawExamplePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildButton(widgets[index]);
      },
    );
  }

  Widget _buildButton(Widget widget) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute<void>(builder: (BuildContext ctx) => widget));
      },
      child: Text(widget.runtimeType.toString()),
    );
  }
}
