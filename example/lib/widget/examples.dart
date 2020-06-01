import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/add_text_page.dart';
import 'package:flutter_image_editor_example/advanced_page.dart';
import 'package:flutter_image_editor_example/home_page.dart';
import 'package:flutter_image_editor_example/merge_image_page.dart';
import 'package:flutter_image_editor_example/mix_image_page.dart';

class Examples extends StatefulWidget {
  @override
  _ExamplesState createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  static get widgets => <Widget>[
        SimpleExamplePage(),
        ExtendedImageExample(),
        AddTextPage(),
        MixImagePage(),
        MergeImagePage(),
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
    return RaisedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => widget));
      },
      child: Text(widget.runtimeType.toString()),
    );
  }
}
