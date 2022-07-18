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
    return Column(
      children: widgets.map((e) => _buildButton(e)).toList(),
    );
  }

  Widget _buildButton(Widget widget) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        width: 300,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute<void>(builder: (BuildContext ctx) => widget));
          },
          child: Text(toTitle(widget)),
        ),
      ),
    );
  }

  String toTitle(Widget widget) {
    final src = widget.runtimeType.toString();
    final regex = RegExp('([A-Z]){1}[a-z]+');
    return regex.allMatches(src).map((e) => e.group(0)).join(' ');
  }
}
