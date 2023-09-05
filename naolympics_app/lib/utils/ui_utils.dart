import 'package:flutter/material.dart';

class UIUtils {
  static Container getBorderedTextButton(VoidCallback onPressed,
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
              fontSize: 15.0,
            ),
          ),
        ));
  }

  static void showTemporaryAlert(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(title: Center(child:Text(text)));
        });
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
