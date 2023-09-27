import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:naolympics_app/screens/connect_4/widgets/board_column.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";

class Board extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();

  Board({super.key});

  List<BoardColumn> _buildBoard() {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 100),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                      children: _buildBoard(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
