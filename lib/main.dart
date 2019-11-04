import 'package:clean_architecture_tdd_course/injection_container.dart' as di;
import 'package:flutter/material.dart';

void main() async {
  // It's important to await the Future even though it only contains void.
  // We definitely don't want the UI to be built up before ​any of the dependencies had a chance to be registered.​​
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue);
  }
}
