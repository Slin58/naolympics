import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'coin.dart';

enum CellState {
  EMPTY,
  YELLOW,
  RED,
}

class Cell extends StatelessWidget {
  final currCellState;

  Cell({
    Key? key,
    required this.currCellState,
  }) : super(key: key);

  Coin _buildCoin() {
    switch (this.currCellState) {
      case CellState.YELLOW:
        return Coin(
          coinColor: Colors.yellow,
        );
      case CellState.RED:
        return Coin(
          coinColor: Colors.red,
        );
      default:
        return Coin(
          coinColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 95, width: 100, color: Colors.lightBlueAccent),
        Positioned.fill(
            child: Align(
          alignment: Alignment.center,
          child: _buildCoin(),
        ))
      ],
    );
  }
}
