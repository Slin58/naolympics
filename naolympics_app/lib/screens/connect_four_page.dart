import 'package:flutter/material.dart';

class ConnectFourPage extends StatefulWidget {
  const ConnectFourPage({Key? key}) : super(key: key);

  @override
  ConnectFourState createState() => ConnectFourState();
}

class ConnectFourState extends State<ConnectFourPage> {
  late List<List<Color>> gameBoard;
  final int rows = 6;
  final int columns = 7;

  @override
  void initState() {
    super.initState();
    initializeGameBoard();
  }

  void initializeGameBoard() {
    gameBoard = List.generate(rows, (_) => List.filled(columns, Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Four'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FractionallySizedBox(
            alignment: Alignment.center,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 1.0,
              ),
              itemCount: rows * columns,
              itemBuilder: (context, index) {
                final row = index ~/ columns;
                final col = index % columns;
                final color = gameBoard[row][col];

                return GestureDetector(
                  onTap: () {
                    handleMove(row, col);
                  },
                  child: Container(
                    color: color,
                    margin: EdgeInsets.all(2.0),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void handleMove(int row, int col) {
    setState(() {
      gameBoard[row][col] = Colors.blue; // Replace with the player's color
    });
  }
}
