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

var connectFourPageBuildContext;

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});
  static final log = Logger((ConnectFourPage).toString());

  @override
  Widget build(BuildContext context) {
    connectFourPageBuildContext = context;
    return WillPopScope(
        onWillPop: () async {
      if(MultiplayerState.isClient()) {
        return false;
      }
      else {
        Navigator.of(context).pop(true);
        return false;
      }
        },
      child: GetMaterialApp(
      initialBinding: ControllerBinding(),
      initialRoute: "/",
      getPages: [
        (MultiplayerState.connection != null) ?
          GetPage(name: '/', page: () => Connect4ScreenMultiplayer())
        :
          GetPage(name: '/', page: () => Connect4Screen()),
      ],
    )
    );
  }
}


