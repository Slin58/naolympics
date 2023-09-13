import "package:flutter/material.dart";
import "package:naolympics_app/logger/logger.dart";
import "package:naolympics_app/screens/connect_four_page.dart";
import "package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart";
import "package:naolympics_app/screens/home_page.dart";
import "package:naolympics_app/screens/tic_tac_toe_page.dart";
import "package:naolympics_app/services/routing/route_observer/observer_utils.dart";

void main() {
  LoggerConfig.setLoggerConfig();

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
