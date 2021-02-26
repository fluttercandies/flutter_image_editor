import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';

import 'expand_container.dart';

class FlipWidget extends StatefulWidget {
  const FlipWidget({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final ValueChanged<FlipOption>? onTap;

  @override
  _FlipWidgetState createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget> {
  bool horizontal = true;
  bool vertical = false;

  @override
  Widget build(BuildContext context) {
    return ExpandContainer(
      title: 'flip',
      child: Column(
        children: <Widget>[
          buildCheck('horizontal', horizontal, (bool v) => horizontal = v),
          buildCheck('vertical', vertical, (bool v) => vertical = v),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              child: const Text('flip'),
              onPressed: () {
                final FlipOption opt = FlipOption(
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
      onChanged: (bool? v) {
        if (v == null) return;
        setState(() {
          onChanged.call(v);
        });
      },
      title: Text(title),
      value: value,
    );
  }
}
