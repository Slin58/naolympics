import "package:flutter/cupertino.dart";
import "package:get/get.dart";
import "package:naolympics_app/screens/connect_4/widgets/cell.dart";
import "package:naolympics_app/services/gamemodes/connect_4/game_controller.dart";
import "package:naolympics_app/services/multiplayer_state.dart";

class BoardColumn extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();
  late final List<int> chipsInColumn;
  final int columnNumber;

  BoardColumn({
    required this.chipsInColumn,
    required this.columnNumber,
    Key? key,
  }) : super(key: key);

  List<Cell> _buildBoardColumn() {
    return chipsInColumn.reversed
        .map((chip) => chip == 1
            ? const Cell(currCellState: CellState.yellow)
            : chip == 2
                ? const Cell(currCellState: CellState.red)
                : const Cell(currCellState: CellState.empty))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var makeMove = gameController.playColumnLocal;
    if (MultiplayerState.connection != null) {
      makeMove = gameController.playColumnMultiplayer;
    }
    bool madeMove = false;
    return GestureDetector(
        //nao specific
        onTap: () {
          if (!madeMove && !gameController.blockTurn) {
            makeMove(columnNumber);
            madeMove = true;
          }
        },
        onLongPress: () {
          if (!madeMove && !gameController.blockTurn) {
            makeMove(columnNumber);
            madeMove = true;
          }
        },
        onVerticalDragStart: (_) {
          if (!madeMove && !gameController.blockTurn) {
            makeMove(columnNumber);
            madeMove = true;
          }
        },
        onHorizontalDragStart: (_) {
          if (!madeMove && !gameController.blockTurn) {
            makeMove(columnNumber);
            madeMove = true;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildBoardColumn(),
        ));
  }
}
