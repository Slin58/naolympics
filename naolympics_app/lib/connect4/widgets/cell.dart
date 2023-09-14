import "package:flutter/material.dart";
import "package:naolympics_app/connect4/widgets/connect_4_chip.dart";

enum CellState {
  empty,
  yellow,
  red,
}

class Cell extends StatelessWidget {
  final CellState currCellState;

  const Cell({
    required this.currCellState,
    Key? key,
  }) : super(key: key);

  Connect4Chip _buildChip() {
    switch (currCellState) {
      case CellState.yellow:
        return const Connect4Chip(
          chipColor: Colors.yellow,
        );
      case CellState.red:
        return const Connect4Chip(
          chipColor: Colors.red,
        );
      default:
        return const Connect4Chip(
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
          child: _buildChip(),
        ))
      ],
    );
  }
}
