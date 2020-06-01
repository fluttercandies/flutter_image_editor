import 'package:flutter/material.dart';

import 'const/resource.dart';

class DrawExamplePage extends StatefulWidget {
  @override
  _DrawExamplePageState createState() => _DrawExamplePageState();
}

class _DrawExamplePageState extends State<DrawExamplePage> {

  ImageProvider provider;

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
                // if(provider!=null)
                // Image.asset(
                //   R.ASSETS_ICON_PNG,
                // ),
                // else
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
