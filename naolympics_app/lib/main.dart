import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/screens/connect_four_page.dart';
import 'package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart';
import 'package:naolympics_app/screens/home_page.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';
import 'package:naolympics_app/services/routing/route_observer/observer_utils.dart';

void main() {
  Logger.root.level = Level.FINER; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    String baseMessage = "${record.time} ${record.level.name} '${record.loggerName}':\t\t${record.message}";
    if(record.level == Level.SEVERE) {
      baseMessage += "\n${record.error}\n${record.stackTrace}";
    }
    print(baseMessage);
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
        "HomePage": (context) => const HomePage(),
        "TicTacToePage": (context) => const TicTacToePage(),
        "ConnectFourPage": (connect) => const ConnectFourPage(),
        "GameSelectionPageMultiplayer": (connect) => const GameSelectionPageMultiplayer()
      },
    );
  }
}
