import 'package:flutter/material.dart';
import 'package:speech2text/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech2text',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SpeechRecognitionExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}
