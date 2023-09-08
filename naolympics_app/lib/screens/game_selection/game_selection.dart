import 'package:flutter/material.dart';
import 'package:naolympics_app/screens/tic_tac_toe_page.dart';
import 'package:naolympics_app/utils/ui_utils.dart';

import '../connect_four_page.dart';

class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({super.key});

  @override
  State<StatefulWidget> createState() => GameSelectionState();
}

class GameSelectionState extends State<GameSelectionPage> {
  late Orientation orientation;
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text("Choose game mode",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      backgroundColor: Theme.of(context).primaryColor,
      actions: getAppBarAction(context),
    );

    orientation = MediaQuery.of(context).orientation;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height - appBar.preferredSize.height;

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: _getGameSelection(),
      ),
    );
  }

  Widget _getGameSelection() {
    List<Widget> games = getNavButtons(context);
    Flex gameList;

    if (orientation == Orientation.landscape) {
      gameList =
          Row(mainAxisAlignment: MainAxisAlignment.center, children: games);
    } else {
      gameList =
          Column(mainAxisAlignment: MainAxisAlignment.center, children: games);
    }

    return Center(child: gameList);
  }

  List<Widget> getAppBarAction(BuildContext context) {
    return [];
  }

  List<Widget> getNavButtons(BuildContext context) {
    return [
      getTicTacToeImageButton(context, const TicTacToePage()),
      getConnectFourImageButton(context, const ConnectFourPage()),
    ];
  }

  Widget getTicTacToeImageButton(BuildContext context, Widget route) {
    return _getImageButton(
        context, route, "Tic Tac Toe", 'assets/images/tictactoe.png');
  }

  Widget getConnectFourImageButton(BuildContext context, Widget route) {
    return _getImageButton(
        context, route, "Connect Four", 'assets/images/connect4.png');
  }

  Widget _getImageButton(
      BuildContext context, Widget route, String text, String imagePath) {
    double boxHeight;
    double boxWidth;
    // TODO BESSERE Möglichkeit finden.
    const errorMagin = 50;
    if (orientation == Orientation.landscape) {
      boxHeight = height - errorMagin; //error margin
      boxWidth = width / 2 - 6;
    } else {
      boxHeight = height / 2 - errorMagin;
      boxWidth = width - errorMagin;
    }

    const double fontSize = 60;

    return Center(
        child: GestureDetector(
            onTap: getOnPressedForNavButton(context, route),
            child: UIUtils.getSizedBoxWIthImageAndText(
                boxWidth, boxHeight, imagePath, text, fontSize, "Impact")));
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
