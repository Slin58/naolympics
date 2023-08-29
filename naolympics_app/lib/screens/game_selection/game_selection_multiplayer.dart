import 'package:flutter/material.dart';
import 'package:naolympics_app/screens/socket_test.dart';
import 'package:naolympics_app/services/MultiplayerState.dart';
import 'package:naolympics_app/services/routing/route_aware_widget.dart';
import 'package:naolympics_app/utils/utils.dart';

import '../connect_four_page.dart';
import '../tic_tac_toe_page.dart';
import 'game_selection.dart';

// das ist so anders hirntot, aber juckt absolut null
class GameSelectionPageMultiplayer extends GameSelectionPage {
  const GameSelectionPageMultiplayer({super.key});

  @override
  State<StatefulWidget> createState() => GameSelectionStateMultiplayer();
}

class GameSelectionStateMultiplayer extends GameSelectionState {
  @override
  List<Widget> getAppBarAction(BuildContext context) {
    return [
      SizedBox(
        child: TextButton.icon(
          icon: const Icon(
            Icons.computer,
            size: 40,
            color: Colors.white,
          ),
          label: const Text(
            "Host game or find players",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SocketTest()));
            });
          },
        ),
      ),
    ];
  }

  @override
  List<Widget> getNavButtons(BuildContext context, double marginSize) {
    return [
      createNavButton(
          "Connect Four",
          context,
          RouteAwareWidget((ConnectFourPage).toString(),
              child: const ConnectFourPage())),
      SizedBox(height: marginSize, width: marginSize),
      createNavButton(
          "Tic Tac Toe",
          context,
          RouteAwareWidget((TicTacToePage).toString(),
              child: const TicTacToePage()))
    ];
  }

  @override
  void Function() getOnPressedForNavButton(BuildContext context, route) {
    return () {
      if (MultiplayerState.isHosting()) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      } else if (MultiplayerState.isClient()) {
        UIUtils.showTemporaryAlert(context, "Wait for the host");
      } else {
        UIUtils.showTemporaryAlert(context, "You are currently not connected");
      }
    };
  }
}
