import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/services/gamemodes/connect_4/bindings/controller_binding.dart";
import "package:naolympics_app/services/gamemodes/connect_4/connect_4_screen.dart";
import "package:naolympics_app/services/gamemodes/connect_4/connect_4_screen_multiplayer.dart";
import "package:naolympics_app/services/multiplayer_state.dart";

void main() {
  runApp(const ConnectFourPage());
}

BuildContext? connectFourPageBuildContext;

class ConnectFourPage extends StatelessWidget {
  const ConnectFourPage({super.key});

  static final log = Logger((ConnectFourPage).toString());

  @override
  Widget build(BuildContext context) {
    connectFourPageBuildContext = context;
    return WillPopScope(
        onWillPop: () async {
          if (MultiplayerState.isClient()) {
            return false;
          } else {
            Navigator.of(context).pop(true);
            return false;
          }
        },
        child: GetMaterialApp(
          initialBinding: ControllerBinding(),
          initialRoute: "/",
          getPages: [
            if (MultiplayerState.connection != null)
              GetPage(name: "/", page: Connect4ScreenMultiplayer.new)
            else
              GetPage(name: "/", page: Connect4Screen.new),
          ],
        ));
  }
}
