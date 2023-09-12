import "package:flutter/material.dart";

class UIUtils {
  static Container getBorderedTextButton(VoidCallback onPressed,
      IconData iconData, String text, Color color, double width) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        width: width,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(iconData, color: color),
          label: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 15,
            ),
          ),
        ));
  }

  static SizedBox getSizedBoxWIthImageAndText(double boxWidth, double boxHeight,
      String imagePath, String text, double fontSize, String fontFamily) {
    final strokeSize = fontSize / 10;

    return SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Stack(
        children: <Widget>[
          Center(
              child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          )),
          Center(
              child: Text(text,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: "Impact",
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = strokeSize
                        ..color = Colors.black))),
          Center(
              child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
          )),
        ],
      ),
    );
  }

  static void showTemporaryAlert(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 1),
              () => Navigator.of(context).pop(true));
          return AlertDialog(title: Center(child: Text(text)));
        });
  }

  static Container debugBorder(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: child,
    );
  }
}
