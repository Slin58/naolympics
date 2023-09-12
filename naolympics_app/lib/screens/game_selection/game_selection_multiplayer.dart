import "package:flutter/material.dart";
import "package:naolympics_app/screens/connect_four_page.dart";
import "package:naolympics_app/screens/game_selection/game_selection.dart";
import "package:naolympics_app/screens/tic_tac_toe_page.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/services/network/json/json_objects/navigation_data.dart";
import "package:naolympics_app/services/routing/route_aware_widgets/route_aware_widget.dart";
import "package:naolympics_app/utils/ui_utils.dart";

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
            Icons.stop_outlined,
            size: 40,
            color: Colors.white,
          ),
          label: const Text(
            "Close connection",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            final closeConn =
                NavigationData("stop", NavigationType.closeConnection);
            await MultiplayerState.connection!.writeJsonData(closeConn);

            MultiplayerState.closeConnection();
            Navigator.popUntil(context, (route) => !Navigator.canPop(context));
          },
        ),
      )
    ];
  }


  @override
  List<Widget> getNavButtons(BuildContext context) {
    return [
      getTicTacToeImageButton(
          context,
          RouteAwareWidget((TicTacToePage).toString(),
              child: const TicTacToePage())),
      //SizedBox(height: marginSize, width: marginSize),
      getConnectFourImageButton(
          context,
          RouteAwareWidget((ConnectFourPage).toString(),
              child: const ConnectFourPage()))
    ];
  }

  @override
  VoidCallback getOnPressedForNavButton(BuildContext context, route) {
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
