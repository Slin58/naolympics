import 'package:flutter/material.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';

import '../connect_four_page.dart';

class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({super.key});

  @override
  State<StatefulWidget> createState() => GameSelectionState();
}

class GameSelectionState extends State<GameSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final marginSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Naolympics",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          actions: getAppBarAction(context)),
      body: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getNavButtons(context, marginSize)),
      ),
    );
  }

  List<Widget> getAppBarAction(BuildContext context) {
    return [];
  }

  List<Widget> getNavButtons(BuildContext context, double marginSize) {
    return [
      createNavButton("Connect Four", context, const ConnectFourPage()),
      SizedBox(height: marginSize, width: marginSize),
      createNavButton("Tic Tac Toe", context, const TicTacToePage())
    ];
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
      onPressed: getOnPressedForNavButton(context, route),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          softWrap: false,
        ),
      ),
    );
  }

  VoidCallback getOnPressedForNavButton(BuildContext context, route) {
    return () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    };
  }
}
