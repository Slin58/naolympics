import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Connect4Chip.dart';


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

  Connect4Chip _buildChip() {
    switch (this.currCellState) {
      case CellState.YELLOW:
        return Connect4Chip(
          chipColor: Colors.yellow,
        );
      case CellState.RED:
        return Connect4Chip(
          chipColor: Colors.red,
        );
      default:
        return Connect4Chip(
          chipColor: Colors.white,
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
          child: _buildChip(),
        ))
      ],
    );
  }
}
