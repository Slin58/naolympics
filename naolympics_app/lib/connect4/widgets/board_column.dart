import "package:flutter/cupertino.dart";
import "package:get/get.dart";
import "package:naolympics_app/connect4/gameController/game_controller.dart";
import "package:naolympics_app/connect4/widgets/cell.dart";
import "package:naolympics_app/services/multiplayer_state.dart";

class BoardColumn extends StatelessWidget {
  final GameController gameController = Get.find<GameController>(); //todo: test
  late final List<int> chipsInColumn;
  final int columnNumber;

  BoardColumn({
    required this.chipsInColumn, required this.columnNumber, Key? key,
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
      var playFunction = gameController.playColumnLocal;
      if (MultiplayerState.connection != null) {
        playFunction = gameController.playColumnMultiplayer;
      }

      bool moveWasMade = false;

      return GestureDetector( //nao specific
          onTap: () {
            if (!gameController.blockTurn && !moveWasMade) {
              playFunction(columnNumber);
              moveWasMade = true;
              return;
            }
          },
          onLongPress: () {
            if (!gameController.blockTurn && !moveWasMade) {
              playFunction(columnNumber);
              moveWasMade = true;
            }
          },
          onVerticalDragStart: (_) {
            if (!gameController.blockTurn && !moveWasMade) {
              playFunction(columnNumber);
              moveWasMade = true;
            }
          },
          onHorizontalDragStart: (_) {
            if (!gameController.blockTurn && !moveWasMade) {
              playFunction(columnNumber);
              moveWasMade = true;
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildBoardColumn(),
          ));
    }
}
