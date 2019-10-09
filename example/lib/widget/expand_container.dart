import 'package:flutter/material.dart';

class ExpandContainer extends StatefulWidget {
  final Widget child;

  final String title;

  const ExpandContainer({
    Key key,
    this.child,
    this.title,
  }) : super(key: key);

  @override
  _ExpandContainerState createState() => _ExpandContainerState();
}

class _ExpandContainerState extends State<ExpandContainer> {
  bool show = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                show = !show;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          if (show) Divider(),
          child,
        ],
      ),
    );
  }

  Widget get child {
    if (show) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: widget.child,
      );
    } else {
      return Container(
        height: 0,
        child: widget.child,
      );
    }
  }
}
