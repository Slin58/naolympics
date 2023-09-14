import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/screens/connect_4/widgets/board.dart";
import "package:naolympics_app/screens/game_selection/game_selection.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";
import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart";

class Connect4Screen extends StatelessWidget {
  final GameController gameController = Get.put(GameController());
  static final log = Logger((Connect4Screen).toString());

  Connect4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      log.info("Triggered WillPopScope in Connect4Screen");
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RouteAwareWidget(
                  (GameSelectionPage).toString(),
                  child: const GameSelectionPage())));
      return false;
    },
    child: Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteAwareWidget(
                        (GameSelectionPage).toString(),
                        child: const GameSelectionPage())));
          },
        ),
        title: Obx(() => Text(
              gameController.turnYellow
                  ? "Player 1 (yellow)"
                  : "Player 2 (red)",
              style: TextStyle(
                  color:
                      gameController.turnYellow ? Colors.yellow : Colors.red),
            )),
      ),
      body: Board(),
    )
    );
  }
}
