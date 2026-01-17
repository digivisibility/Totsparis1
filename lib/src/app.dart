import 'package:flutter/material.dart';
import 'package:totsparis2/src/webview_container.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewContainer(url: 'http://totsparis.com/', title: 'Tots Paris'),
    );
  }
}
