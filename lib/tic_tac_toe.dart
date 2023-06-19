import 'package:flutter/material.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({Key? key}) : super(key: key);

  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  final List<String> cells = List.generate(9, (index) => '');

  bool isCircleTurn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (BuildContext context, int index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          if (cells[index] == '') {
                            setState(() {
                              cells[index] = isCircleTurn ? 'O' : 'X';
                              isCircleTurn = !isCircleTurn;
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: _buildGridBorder(index, 'top'),
                              bottom: _buildGridBorder(index, 'bottom'),
                              left: _buildGridBorder(index, 'left'),
                              right: _buildGridBorder(index, 'right'),
                            ),
                          ),
                          child: Center(
                            child: cells[index] == 'O'
                                ? Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                  width: 4.0,
                                ),
                              ),
                            )
                                : cells[index] == 'X'
                                ? Icon(
                              Icons.close,
                              size: 40.0,
                              color: Colors.black,
                            )
                                : SizedBox.shrink(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _resetState,
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  BorderSide _buildGridBorder(int index, String direction) {
    if (direction == 'top') {
      return index < 3 ? BorderSide.none : const BorderSide(color: Colors.black, width: 2.0);
    } else if (direction == 'bottom') {
      return index >= 6 ? BorderSide.none : const BorderSide(color: Colors.black, width: 2.0);
    } else if (direction == 'left') {
      return index % 3 == 0 ? BorderSide.none : const BorderSide(color: Colors.black, width: 2.0);
    } else if (direction == 'right') {
      return (index + 1) % 3 == 0 ? BorderSide.none : const BorderSide(color: Colors.black, width: 2.0);
    }
    return BorderSide.none;
  }

  void _resetState() {
    setState(() {
      cells.fillRange(0, cells.length, '');
      isCircleTurn = true;
    });
  }
}
