import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/services/gamemodes/connect_4/bindings/controller_binding.dart";
import "package:naolympics_app/services/gamemodes/connect_4/connect_4_screen.dart";
import "package:naolympics_app/services/gamemodes/connect_4/connect_4_screen_multiplayer.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";
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
          theme: ThemeData(
            primaryColor: const Color.fromRGBO(255, 130, 0, 1),
            useMaterial3: true,
          ),          getPages: [
            if (MultiplayerState.connection != null)
              GetPage(name: "/", page: Connect4ScreenMultiplayer.new)
            else
              GetPage(name: "/", page: Connect4Screen.new),
          ],
        ));
  }

  static Widget getPlayerTurnIndicator() {
    GameController gameController = Get.find<GameController>();
    return Stack (
      children: <Widget>[
        Text(
          gameController.turnYellow
              ? "Player 1 (yellow)"
              : "Player 2 (red)",
          style: TextStyle(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.7
              ..color = Colors.black,
              fontSize: 30,
          ),
        ),
        Text(
          gameController.turnYellow
              ? "Player 1 (yellow)"
              : "Player 2 (red)",
          style: TextStyle(
              color: gameController.turnYellow ? Colors.yellow : Colors.red, fontSize: 30),
        )],
    );
  }

}
