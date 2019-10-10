import 'package:flutter/material.dart';
import 'package:flutter_image_editor_example/home_page.dart';
import 'package:image_editor/image_editor.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  ImageEditor.initialPlugin();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
