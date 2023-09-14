import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/screens/connect_4/widgets/board_column.dart";
import "package:naolympics_app/screens/game_selection/game_selection_multiplayer.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";
import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart";

class BoardMultiplayer extends StatelessWidget {
  BoardMultiplayer({super.key});

  final GameController gameController = Get.find<GameController>();

  static final log = Logger((BoardMultiplayer).toString());

  List<BoardColumn> _buildBoardMultiplayer() {
    int currentColNumber = 0;
    return gameController.board
        .map((boardColumn) => BoardColumn(
              chipsInColumn: boardColumn,
              columnNumber: currentColNumber++,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
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
                              (GameSelectionPageMultiplayer).toString(),
                              child: const GameSelectionPageMultiplayer())));
                },
              ),
              title: Obx(() => Text(
                    gameController.turnYellow
                        ? "Player 1 (yellow)"
                        : "Player 2 (red)",
                    style: TextStyle(
                      color: gameController.turnYellow
                          ? Colors.yellow
                          : Colors.red,
                    ),
                  )),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    color: Colors.blueAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GetBuilder<GameController>(
                            builder: (gameController) => Row(
                              children: _buildBoardMultiplayer(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
