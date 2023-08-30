import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import '../../gameController/game_controller.dart';
import 'cell.dart';

class BoardColumn extends StatelessWidget {
  GameController gameController = Get.find<GameController>();
  late final List<int> chipsInColumn;
  final int columnNumber;

  BoardColumn({
    Key? key,
    required this.chipsInColumn,
    required this.columnNumber,
  }) : super(key: key);

  List<Cell> _buildBoardColumn() {
    //print(coinsInColumn.length);
    return chipsInColumn.reversed
        .map((chip) => chip == 1
            ? Cell(currCellState: CellState.YELLOW)
            : chip == 2
                ? Cell(currCellState: CellState.RED)
                : Cell(currCellState: CellState.EMPTY))
        .toList();
  }

    @override
    Widget build(BuildContext context) {
      var playFunction = gameController.playColumnLocal;
      if (MultiplayerState.connection != null)
        playFunction = gameController.playColumnMultiplayer;

      return GestureDetector( //nao specific
          onTap: () {
            if (!gameController.blockTurn) {
              playFunction(columnNumber);
            }
          },
          onLongPress: () {
            if (!gameController.blockTurn) {
              playFunction(columnNumber);
            }
          },
          onVerticalDragStart: (details) {
            if (!gameController.blockTurn) {
              playFunction(columnNumber);
            }
          },
          onHorizontalDragStart: (details) {
            if (!gameController.blockTurn) {
              playFunction(columnNumber);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildBoardColumn(),
          ));
    }
}
