import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:naolympics_app/screens/connect_four_page.dart';
import 'package:naolympics_app/screens/home_page.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';

void main() {
  Logger.level = Level.debug;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        "TicTacToe": (context) => const TicTacToePage(),
        "ConnectFour": (connect) => const ConnectFourPage()
      },
    );
  }
}
