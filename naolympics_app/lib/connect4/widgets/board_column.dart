import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import '../gameController/game_controller.dart';
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
