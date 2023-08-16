import 'package:flutter/material.dart';

class UIUtils {
  static Container getBorderedTextButton(void Function()? onPressed,
      IconData iconData, String text, Color color, double width) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: width,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(iconData, color: color),
          label: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18.0,
            ),
          ),
        ));
  }

  static Container debugBorder(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2.0),
      ),
      child: child,
    );
  }
}
