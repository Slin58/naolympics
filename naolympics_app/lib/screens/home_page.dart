import 'package:flutter/material.dart';
import 'package:naolympics_app/screens/find_player_page.dart';
import 'game_selection/game_selection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final marginSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Naolympics",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createNavButton("Local", context, const GameSelectionPage()),
            SizedBox(height: marginSize / 3.0),
            createNavButton(
                "Multiplayer", context, const FindPlayerPage()) //placeholder
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
          side: const BorderSide(
            color: Colors.blue,
            width: 2.5,
          ),
        ),
        padding: const EdgeInsets.all(40.0),
        backgroundColor: Colors.transparent,
        fixedSize: const Size.fromWidth(700)),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        title,
        softWrap: false,
        style: const TextStyle(fontSize: 30),
      ),
    ),
  );
}
