import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:naolympics_app/screens/connect_4/widgets/board_multiplayer.dart";
import "package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";
import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart";

class Connect4ScreenMultiplayer extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();

  Connect4ScreenMultiplayer({super.key});
  @override
  Widget build(BuildContext context) {
  gameController.resetBoard();
    return WillPopScope(
        onWillPop: () async {
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => RouteAwareWidget(
                      (GameSelectionPageMultiplayer).toString(),
                      child: const GameSelectionPageMultiplayer() )));
        return false;
    },
          child: BoardMultiplayer());
  }
}
