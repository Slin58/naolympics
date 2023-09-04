import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import '../services/multiplayer_state.dart';
import 'bindings/ControllerBinding.dart';
import 'game_screens/connect_4_screen.dart';
import 'game_screens/connect_4_screen_multiplayer.dart';

void main() {
  runApp(const ConnectFourPage());
}

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});
  static final log = Logger((ConnectFourPage).toString());

  @override
  Widget build(BuildContext context) {
    var con = MultiplayerState.connection;
    log.info("In ConnectFourPage: Multiplayerstate.Connection is: $con");

    final initialRoute = con != null ? '/multiplayer' : '/singleplayer';

    return GetMaterialApp(
      initialBinding: ControllerBinding(),
      initialRoute: initialRoute,
      getPages: [
        (MultiplayerState.connection != null) ?
          GetPage(name: '/multiplayer', page: () => Connect4ScreenMultiplayer())
        :
          GetPage(name: '/singleplayer', page: () => Connect4Screen()),
      ],
    );
  }
}


