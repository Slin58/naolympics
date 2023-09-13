import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart";
import "package:naolympics_app/services/gamemodes/tictactoe/tictactoe_local.dart";
import "package:naolympics_app/services/gamemodes/tictactoe/tictactoe_multiplayer.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/utils/routing_utils.dart";
import "package:naolympics_app/utils/ui_utils.dart";

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  TicTacToeState createState() => TicTacToeState();
}

class TicTacToeState extends State<TicTacToePage> {
  late TicTacToe ticTacToe;

  @override
  void initState() {
    super.initState();
    if (MultiplayerState.connection == null) {
      ticTacToe = TicTacToeLocal();
    } else {
      ticTacToe = TicTacToeMultiplayer(MultiplayerState.connection!, setState);
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _showWinner());

    return RoutingUtils.handlePopScope(
        context,
        Scaffold(
            appBar: AppBar(
              title: const Text("Tic Tac Toe"),
              actions: [_displayCurrentTurn()],
            ),
            body: _buildTicTacToeField()));
  }

  Row _displayCurrentTurn() {
    const double size = 20;
    Icon icon = ticTacToe.currentTurn == TicTacToeFieldValues.o
        ? _getCircleIcon(size)
        : _getCrossIcon(size);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Current Turn:"),
      const SizedBox(width: 8),
      icon
    ]);
  }

  Widget _buildTicTacToeField() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final double smallerValue = height < width ? height : width;
    final double cellSize = smallerValue * 0.7 / 3;

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int row = 0; row < 3; row++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int col = 0; col < 3; col++)
                      GestureDetector(
                          onTap: () => _tapAction(row, col),
                          onLongPress: () => _tapAction(row, col),
                          onVerticalDragStart: (_) => _tapAction(row, col),
                          onHorizontalDragStart: (_) => _tapAction(row, col),
                          child: _buildCell(row, col, cellSize)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _tapAction(int row, int col) {
    setState(() => ticTacToe.move(row, col));
  }

  Container _buildCell(int row, int col, double cellSize) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(border: Border.all()),
      child: Center(child: _setIcon(row, col, cellSize)),
    );
  }

  void _showWinner() {
    final winner = ticTacToe.winner;
    if (winner != TicTacToeWinner.ongoing) {
      showDialog(
          context: context,
          builder: (alertContext) => _winnerAlertDialog(winner, alertContext));
    }
  }

  AlertDialog _winnerAlertDialog(TicTacToeWinner winner,
      BuildContext alertContext) {
    const double iconSize = 40;
    Icon winnerIcon;
    String winnerText = "Winner: ";

    if (winner == TicTacToeWinner.o) {
      winnerIcon = _getCircleIcon(iconSize);
    } else if (winner == TicTacToeWinner.x) {
      winnerIcon = _getCrossIcon(iconSize);
    } else {
      winnerIcon = const Icon(Icons.bolt_outlined, size: iconSize, color: Colors.amber);
      winnerText = "It's a tie!";
    }
    const double buttonWidth = 130;
    final color = Theme.of(context).primaryColor;

    return AlertDialog(
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(winnerText), const SizedBox(width: 8), winnerIcon],
        ),
      ),
      content: Row(mainAxisSize: MainAxisSize.min, children: [
        UIUtils.getBorderedTextButton(_setGoBackAction(alertContext),
            Icons.arrow_back, "Go Back", color, buttonWidth),
        const SizedBox(width: buttonWidth / 100000),
        UIUtils.getBorderedTextButton(_setResetAction(alertContext),
            Icons.refresh, "Reset", color, buttonWidth),
      ]),
    );
  }

  void Function() _setGoBackAction(BuildContext alertContext) {
    return () {
      if (MultiplayerState.isClient()) {
        UIUtils.showTemporaryAlert(context, "The Host chooses how to continue");
      } else {
        if (MultiplayerState.isHosting()) {
          (ticTacToe as TicTacToeMultiplayer).handleGoBack();
        }
        Navigator.pop(alertContext);
        Navigator.pop(context);
      }
    };
  }

  void Function() _setResetAction(BuildContext alertContext) {
    return () {
      if (MultiplayerState.isClient()) {
        UIUtils.showTemporaryAlert(context, "The Host chooses how to continue");
      } else {
        setState(() => ticTacToe.init());
        Navigator.pop(alertContext);
      }
    };
  }

  Icon? _setIcon(int row, int col, double iconSize) {
    TicTacToeFieldValues fieldValue = ticTacToe.playField[row][col];

    if (fieldValue == TicTacToeFieldValues.o) {
      return _getCircleIcon(iconSize);
    } else if (fieldValue == TicTacToeFieldValues.x) {
      return _getCrossIcon(iconSize);
    } else {
      return null;
    }
  }

  static Icon _getCircleIcon(double size) {
    return Icon(Icons.circle_outlined, size: size, color: Colors.red);
  }

  static Icon _getCrossIcon(double size) {
    return Icon(Icons.close, size: size, color: Colors.black);
  }
}
