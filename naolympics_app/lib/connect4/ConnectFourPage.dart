import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/multiplayer_state.dart';
import 'bindings/ControllerBinding.dart';
import 'game_screens/connect_4_screen.dart';
import 'game_screens/connect_4_screen_multiplayer.dart';

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

