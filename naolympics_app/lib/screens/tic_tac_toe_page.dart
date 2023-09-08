import 'package:flutter/material.dart';
import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';
import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe_multiplayer.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/utils/routing_utls.dart';

import '../services/gamemodes/tictactoe/tictactoe_local.dart';
import '../utils/ui_utils.dart';

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
      MultiplayerState.clientRoutingService?.pauseNavigator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoutingUtils.handlePopScope(
        context,
        Scaffold(
            appBar: AppBar(
              title: const Text('Tic Tac Toe'),
              actions: [_displayCurrentTurn()],
            ),
            body: _buildTicTacToeField()));
  }

  _displayCurrentTurn() {
    const double size = 20;
    Icon icon = ticTacToe.currentTurn == TicTacToeFieldValues.o
        ? _getCircleIcon(size)
        : _getCrossIcon(size);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Current Turn:"),
      const SizedBox(width: 8.0),
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
                          onTap: () async {
                            TicTacToeWinner winner =
                                await ticTacToe.move(row, col);
                            setState(() {});
                            // move to TicTacToe.dart
                            if (winner != TicTacToeWinner.ongoing) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext localContext) =>
                                      _showWinner(winner, localContext));
                            }
                          },
                          child: _buildTicTacToeCell(row, col, cellSize)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildTicTacToeCell(int row, int col, double cellSize) {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
        ),
      ),
      child: Center(child: _setIcon(row, col, cellSize)),
    );
  }

  AlertDialog _showWinner(TicTacToeWinner winner, BuildContext localContext) {
    const double iconSize = 40;
    const double buttonWidth = 130;
    Icon winnerIcon;
    String winnerText = "Winner: ";

    if (winner == TicTacToeWinner.o) {
      winnerIcon = _getCircleIcon(iconSize);
    } else if (winner == TicTacToeWinner.x) {
      winnerIcon = _getCrossIcon(iconSize);
    } else {
      winnerIcon =
          const Icon(Icons.bolt_outlined, size: iconSize, color: Colors.amber);
      winnerText = "It's a tie!";
    }
    return AlertDialog(
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(winnerText), const SizedBox(width: 8.0), winnerIcon],
        ),
      ),
      content: Row(mainAxisSize: MainAxisSize.min, children: [
        UIUtils.getBorderedTextButton(() {
          if (MultiplayerState.isHosting()) {
            (ticTacToe as TicTacToeMultiplayer).handleGoBack();
          }

          Navigator.pop(localContext);
          Navigator.pop(context);
        }, Icons.arrow_back, 'Go Back', Theme.of(context).primaryColor,
            buttonWidth),
        const SizedBox(width: buttonWidth / 100000),
        UIUtils.getBorderedTextButton(() {
          Navigator.pop(localContext);
          setState(() {
            ticTacToe.init();
          });
        }, Icons.refresh, 'Reset', Theme.of(context).primaryColor, buttonWidth),
      ]),
    );
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

  Icon _getCircleIcon(double size) {
    return Icon(Icons.circle_outlined, size: size, color: Colors.red);
  }

  Icon _getCrossIcon(double size) {
    return Icon(Icons.close, size: size, color: Colors.black);
  }
}
