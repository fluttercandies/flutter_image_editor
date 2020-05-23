import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/widget/expand_container.dart';
import 'package:image_editor/image_editor.dart';

class ScaleWidget extends StatefulWidget {
  final ValueChanged<Option> onTap;

  const ScaleWidget({
    Key key,
    this.onTap,
  }) : super(key: key);

  @override
  _ScaleWidgetState createState() => _ScaleWidgetState();
}

class _ScaleWidgetState extends State<ScaleWidget> {
  int width = 1920;
  int height = 1920;

  @override
  Widget build(BuildContext context) {
    return ExpandContainer(
      title: "width: $width, height: $height",
      child: Column(
        children: <Widget>[
          Slider(
            onChanged: (v) => setState(() => width = v.toInt()),
            value: width.toDouble(),
            min: 1,
            max: 1920,
          ),
          Slider(
            onChanged: (v) => setState(() => height = v.toInt()),
            value: height.toDouble(),
            min: 1,
            max: 1920,
          ),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              child: Text("scale"),
              onPressed: _rotate,
            ),
          ),
        ],
      ),
    );
  }

  void _rotate() {
    final opt = ScaleOption(width, height);
    widget.onTap?.call(opt);
  }
}
