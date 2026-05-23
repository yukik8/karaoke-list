import 'package:flutter/material.dart';
import 'pages/screenshot_page.dart';

void main() {
  runApp(const _ScreenshotApp());
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Screenshot Preview',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ScreenshotPage(),
    );
  }
}
