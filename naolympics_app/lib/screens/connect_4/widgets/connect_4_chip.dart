import "package:flutter/material.dart";

class Connect4Chip extends StatelessWidget {
  final Color chipColor;

  const Connect4Chip({
    required this.chipColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final double smallerValue = height < width ? height : width;
    double radius = smallerValue / 15.5;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black,
      child: CircleAvatar(
        backgroundColor: chipColor,
        radius: radius - 2.0,
      ),
    );
  }
}
