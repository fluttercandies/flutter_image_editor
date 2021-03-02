import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/widget/expand_container.dart';
import 'package:image_editor/image_editor.dart';

class ClipWidget extends StatefulWidget {
  const ClipWidget({
    Key? key,
    this.onTap,
  }) : super(key: key);
  final ValueChanged<ClipOption>? onTap;
  @override
  _ClipWidgetState createState() => _ClipWidgetState();
}

class _ClipWidgetState extends State<ClipWidget> {
  int x = 0;
  int y = 0;
  int width = 100;
  int height = 100;

  @override
  Widget build(BuildContext context) {
    return ExpandContainer(
      title: 'clip',
      child: Column(
        children: <Widget>[
          buildSlider('x', onChanged: (int v) => x = v, value: x),
          buildSlider('y', onChanged: (int v) => y = v, value: y),
          buildSlider('width',
              onChanged: (int v) => width = v, value: width, min: 1),
          buildSlider('height',
              onChanged: (int v) => height = v, value: height, min: 1),
          TextButton(
            child: const Text('clip'),
            onPressed: clip,
          ),
        ],
      ),
    );
  }

  Widget buildSlider(
    String title, {
    int min = 0,
    int max = 1920,
    required ValueChanged<int> onChanged,
    required int value,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Slider(
            onChanged: (double value) {
              setState(() {
                onChanged.call(value.toInt());
              });
            },
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            label: title,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text('$title:$value'),
        ),
      ],
    );
  }

  void clip() {
    final ClipOption opt = ClipOption(
      x: x,
      y: y,
      width: width,
      height: height,
    );

    widget.onTap?.call(opt);
  }
}
