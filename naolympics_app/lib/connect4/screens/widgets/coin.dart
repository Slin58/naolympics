import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Coin extends StatelessWidget {
  final Color coinColor;

  const Coin({
    Key? key,
    required this.coinColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.black,
      child: CircleAvatar(
        backgroundColor: coinColor,
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