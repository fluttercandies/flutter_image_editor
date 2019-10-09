import 'package:flutter/material.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';

import 'expand_container.dart';

class FlipWidget extends StatefulWidget {
  final ValueChanged<FlipOption> onTap;

  const FlipWidget({Key key, this.onTap}) : super(key: key);

  @override
  _FlipWidgetState createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget> {
  bool horizontal = true;
  bool vertical = false;

  @override
  Widget build(BuildContext context) {
    return ExpandContainer(
      title: "flip",
      child: Column(
        children: <Widget>[
          buildCheck("horizontal", horizontal, (v) => horizontal = v),
          buildCheck("vertical", vertical, (v) => vertical = v),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              child: Text("flip"),
              onPressed: () {
                final opt = FlipOption(
                  horizontal: horizontal,
                  vertical: vertical,
                );
                widget.onTap?.call(opt);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCheck(String title, bool value, ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      onChanged: (v) {
        setState(() {
          onChanged?.call(v);
        });
      },
      title: Text(title),
      value: value,
    );
  }
}
