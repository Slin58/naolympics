import 'package:flutter/material.dart';

import 'tic_tac_toe_page.dart';
import 'connect_four_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final marginSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Naolympics", style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary, // Use onPrimary color for text
        ),),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createNavButton("Connect Four", context, const ConnectFourPage()),
            SizedBox(width: marginSize),
            createNavButton("Tic Tac Toe", context, const TicTacToePage())
          ],
        ),
      ),
    );
  }
}

TextButton createNavButton(String title, BuildContext context, Widget route) {
  return TextButton(
    style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: Colors.blue),
        ),
        padding: const EdgeInsets.all(16.0),
        backgroundColor: Colors.transparent,
        fixedSize: const Size.square(150)),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        title,
        softWrap: false,
      ),
    ),
  );
}
