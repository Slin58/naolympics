import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naolympics_app/connect4/screens/game_screens/connect_4_screen.dart';
import 'package:naolympics_app/connect4/screens/game_screens/connect_4_screen_multiplayer.dart';
import '../services/multiplayer_state.dart';
import 'core/bindings/ControllerBinding.dart';

void main() {
  runApp(const ConnectFourPage());
}

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      initialRoute: '/',
      getPages: [
        if (MultiplayerState.connection != null)
          GetPage(name: '/', page: () => Connect4ScreenMultiplayer()),
        if (MultiplayerState.connection == null)
        GetPage(name: '/', page: () => Connect4Screen()),
      ],
    );
  }
}

