import "package:flutter/material.dart";

class Connect4Chip extends StatelessWidget {
  final Color chipColor;

  const Connect4Chip({
    required this.chipColor, Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.black,
      child: CircleAvatar(
        backgroundColor: chipColor,
        radius: 38,
      ),
    );
  }
}