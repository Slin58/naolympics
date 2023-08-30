import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Connect4Chip extends StatelessWidget {
  final Color chipColor;

  const Connect4Chip({
    Key? key,
    required this.chipColor,
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
/*
return Container(
height: 80,
width: 80,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(80), color: coinColor),
);
*/