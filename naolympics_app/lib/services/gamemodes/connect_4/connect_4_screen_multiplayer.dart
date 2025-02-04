import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:naolympics_app/screens/connect_4/widgets/board_multiplayer.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";

class Connect4ScreenMultiplayer extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();

  Connect4ScreenMultiplayer({super.key});

  @override
  Widget build(BuildContext context) {
    gameController.resetBoard();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    return BoardMultiplayer();
  }
}
