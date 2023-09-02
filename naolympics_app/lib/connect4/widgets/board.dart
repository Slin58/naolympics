import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../gameController/game_controller.dart';
import 'board_column.dart';

class Board extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();

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
          margin: EdgeInsets.symmetric(horizontal: 100),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
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
                offset: Offset(0, 3),
              )
            ],
          ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GetBuilder<GameController>(
                      builder: (GetxController gameController) => Row(
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
