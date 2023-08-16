import 'package:flutter/material.dart';
import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';

import '../services/gamemodes/tictactoe/tictactoe_local.dart';
import '../utils/utils.dart';

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
    ticTacToe = TicTacToeLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
        ),
        body: _buildTicTacToeField());
  }

  Widget _buildTicTacToeField() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final double smallerValue = height < width ? height : width;
    final double fieldSize = smallerValue * 0.7;

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
                          onTap: () {
                            setState(() {
                              TicTacToeWinner winner =
                                  ticTacToe.makeMove(row, col);
                              if (winner != TicTacToeWinner.ongoing) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return showWinner(winner);
                                  },
                                );
                              }
                            });
                          },
                          child: _buildTicTacToeCell(row, col, fieldSize)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildTicTacToeCell(int row, int col, double fieldSize) {
    return Container(
      width: fieldSize / 3,
      height: fieldSize / 3,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
        ),
      ),
      child: Center(child: setIcon(row, col)),
    );
  }

  AlertDialog showWinner(TicTacToeWinner winner) {
    const double iconSize = 40;
    const double buttonWidth = 130;
    Icon winnerIcon;
    String winnerText = "Winner: ";

    if (winner == TicTacToeWinner.o) {
      winnerIcon = getCircleIcon(iconSize);
    } else if (winner == TicTacToeWinner.x) {
      winnerIcon = getCrossIcon(iconSize);
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
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }, Icons.arrow_back, 'Go Back', Theme.of(context).primaryColor,
            buttonWidth),
        const SizedBox(width: buttonWidth / 4),
        UIUtils.getBorderedTextButton(() {
          Navigator.of(context).pop();
          setState(() {
            ticTacToe.init();
          });
        }, Icons.refresh, 'Reset', Theme.of(context).primaryColor, buttonWidth),
      ]),
    );
  }

  Icon? setIcon(int row, int col) {
    const double iconSize = 120;
    TicTacToeFieldValues fieldValue = ticTacToe.playField[row][col];

    if (fieldValue == TicTacToeFieldValues.o) {
      return getCircleIcon(iconSize);
    } else if (fieldValue == TicTacToeFieldValues.x) {
      return getCrossIcon(iconSize);
    } else {
      return null;
    }
  }

  Icon getCircleIcon(double size) {
    return Icon(Icons.circle_outlined, size: size, color: Colors.red);
  }

  Icon getCrossIcon(double size) {
    return Icon(Icons.close, size: size, color: Colors.black);
  }
}
