import 'package:flutter/material.dart';
import 'package:naolympics_app/screens/socket_test.dart';
import 'package:naolympics_app/services/MultiplayerState.dart';
import 'package:naolympics_app/utils/utils.dart';

import '../../utils/observer_utils.dart';
import 'game_selection.dart';

// das ist so anders hirntot, aber juckt absolut null
class GameSelectionPageMultiplayer extends GameSelectionPage {
  const GameSelectionPageMultiplayer({super.key});

  @override
  State<StatefulWidget> createState() => GameSelectionStateMultiplayer();
}

class GameSelectionStateMultiplayer extends GameSelectionState with RouteAware {

  @override
  void didChangeDependencies() {
    print("Ich wurde aufgerufen");
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }


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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SocketTest()));
            },
          ),
        ),
      ];
    }

    @override
    void Function() getOnPressedForNavButton(BuildContext context, route) {
      return () {
        if (MultiplayerState.isHosting()) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => route));
        } else if (MultiplayerState.isClient()) {
          UIUtils.showTemporaryAlert(context, "Wait for the host");
        } else {
          UIUtils.showTemporaryAlert(
              context, "You are currently not connected");
        }
      };
    }
  }
