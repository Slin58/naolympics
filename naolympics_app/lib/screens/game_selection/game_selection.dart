import "package:flutter/material.dart";
import "package:naolympics_app/screens/connect_4/connect_four_page.dart";
import "package:naolympics_app/screens/tic_tac_toe_page.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/utils/ui_utils.dart";

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

    return WillPopScope(
        onWillPop: () async {
      Navigator.of(context).pop(true);
      await Future.delayed(const Duration(milliseconds: 500));
      MultiplayerState.closeConnection();
      return false;
    },
    child: Scaffold(appBar: appBar, body: Center(child: _getGameSelection()),
    ));
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
      getTicTacToeButtonWithRoute(context),
      getDivider(),
      getConnectFourButtonWithRoute(context),
    ];
  }

  Widget getTicTacToeButtonWithRoute(BuildContext context) {
    return getTicTacToeImageButton(context, const TicTacToePage());
  }

  Widget getDivider() {
    const double indent = 10;

    return orientation == Orientation.landscape
        ? const VerticalDivider(indent: indent, endIndent: indent, thickness: 0, color: Colors.white,)
        : const Divider(indent: indent, endIndent: indent, thickness: 0, color: Colors.white,);
  }

  Widget getConnectFourButtonWithRoute(BuildContext context) {
    return getConnectFourImageButton(context, const ConnectFourPage());
  }

  Widget getTicTacToeImageButton(BuildContext context, Widget route) {
    return _getImageButton(
        context, route, "Tic Tac Toe", "assets/images/tictactoe.png");
  }

  Widget getConnectFourImageButton(BuildContext context, Widget route) {
    return _getImageButton(
        context, route, "Connect Four", "assets/images/connect4.png");
  }

  Widget _getImageButton(
      BuildContext context, Widget route, String text, String imagePath) {
    const double fontSize = 80;

    return Expanded(
        child: GestureDetector(
            onTap: getOnPressedForNavButton(context, route),
            child: UIUtils.getStackWithImageAndOutlinedText(
                imagePath, text, fontSize, "Impact")));
  }

  VoidCallback getOnPressedForNavButton(BuildContext context, route) {
    return () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    };
  }
}
