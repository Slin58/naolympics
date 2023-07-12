import 'package:flutter/material.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  TicTacToeState createState() => TicTacToeState();
}

class TicTacToeState extends State<TicTacToePage> {
  late List<List<String>> _board;
  late bool _isCircleTurn;
  late String _winner;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    setState(() {
      _board = List.generate(3, (_) => List.filled(3, ''));
      _isCircleTurn = true;
      _winner = "";
    });
  }

  void _makeMove(int row, int col) {
    if (_board[row][col] == '' && _winner == "") {
      setState(() {
        _board[row][col] = _isCircleTurn ? 'O' : 'X';
        _checkWinner(row, col);
        _isCircleTurn = !_isCircleTurn;
      });
    }
  }

  void _checkWinner(int row, int col) {
    String currentSymbol = _board[row][col];
    bool won = false;
    bool isBoardFull = true;

    // Check row
    if (_board[row][0] == currentSymbol &&
        _board[row][1] == currentSymbol &&
        _board[row][2] == currentSymbol) {
      won = true;
    }

    // Check column
    if (_board[0][col] == currentSymbol &&
        _board[1][col] == currentSymbol &&
        _board[2][col] == currentSymbol) {
      won = true;
    }

    // Check diagonal (top-left to bottom-right)
    if (_board[0][0] == currentSymbol &&
        _board[1][1] == currentSymbol &&
        _board[2][2] == currentSymbol) {
      won = true;
    }

    // Check diagonal (top-right to bottom-left)
    if (_board[0][2] == currentSymbol &&
        _board[1][1] == currentSymbol &&
        _board[2][0] == currentSymbol) {
      won = true;
    }

    // check for tie
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == "") {
          isBoardFull = false;
          break;
        }
      }
      if (!isBoardFull) {
        break;
      }
    }

    if (won) {
      setState(() {
        _winner = currentSymbol;
      });
    } else if (isBoardFull) {
      setState(() {
        _winner = "tie";
      });
    }
  }

  Icon? setIcon(int row, int col) {
    const double iconSize = 120;

    if (_board[row][col] == 'O') {
      return getCircleIcon(iconSize);
    } else if (_board[row][col] == 'X') {
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

  AlertDialog showWinner() {
    const double iconSize = 40;
    Icon winnerIcon;
    String winnerText;

    if (_winner == 'O') {
      winnerIcon = getCircleIcon(iconSize);
      winnerText = "Winner: ";
    } else if (_winner == 'X') {
      winnerIcon = getCrossIcon(iconSize);
      winnerText = "Winner:";
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeBoard();
              },
              icon: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
              label: Text(
                'Reset',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double smallerValue = height < width ? height : width;
    final double fieldSize = smallerValue * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      body: Column(
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
                            _makeMove(row, col);
                            if (_winner != "") {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return showWinner();
                                },
                              );
                            }
                          },
                          child: Container(
                            width: fieldSize / 3,
                            height: fieldSize / 3,
                            decoration: BoxDecoration(
                              border: Border(
                                right: col < 2
                                    ? const BorderSide(color: Colors.black)
                                    : BorderSide.none,
                                bottom: row < 2
                                    ? const BorderSide(color: Colors.black)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Center(child: setIcon(row, col)),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
