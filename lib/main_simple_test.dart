import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: const Center(
          child: Text(
            'HELLO TEST',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
