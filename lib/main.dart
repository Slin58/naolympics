import 'package:flutter/material.dart';
import 'package:naolympics_app/tic_tac_toe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
        ),
        body: const Center(
          child: TicTacToePage(),
        ),
      ),
    );
  }
}
