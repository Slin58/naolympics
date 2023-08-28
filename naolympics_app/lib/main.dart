import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/screens/connect_four_page.dart';
import 'package:naolympics_app/screens/home_page.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';
import 'package:naolympics_app/services/routing/observer_utils.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print("${record.time} ${record.level.name} '${record.loggerName}':\t\t${record.message}");
  });
  runApp(MaterialApp(
    home: const MyApp(),
    navigatorObservers: [ObserverUtils.getRouteObserver()],
  ));
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
