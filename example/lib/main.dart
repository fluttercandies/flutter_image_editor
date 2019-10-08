import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/home_page.dart';
import 'package:flutter_image_editor/flutter_image_editor.dart';

void main() {
  runApp(MyApp());
  FlutterImageEditor.initialPlugin();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
