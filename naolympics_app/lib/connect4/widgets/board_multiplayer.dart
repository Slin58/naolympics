import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import '../../screens/game_selection/game_selection.dart';
import '../../screens/game_selection/game_selection_multiplayer.dart';
import '../../screens/home_page.dart';
import '../../services/network/json/json_objects/navigation_data.dart';
import '../../services/routing/route_aware_widgets/route_aware_widget.dart';
import '../gameController/game_controller.dart';
import 'board_column.dart';

class BoardMultiplayer extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();
  static final log = Logger((BoardMultiplayer).toString());

  List<BoardColumn> _buildBoardMultiplayer() {
    gameController.turnYellow = MultiplayerState.isHosting() ? true : false;
    int currentColNumber = 0;

    startListening();

    return gameController.board
        .map((boardColumn) => BoardColumn(
      chipsInColumn: boardColumn,
      columnNumber: currentColNumber++,
    ))
        .toList();
  }

  Future<void> startListening() async {
   // Completer<List<List<int>>> completer = Completer<List<List<int>>>();
    StreamSubscription<String>? subscription;
    final GameController gameController = Get.find<GameController>();
    subscription = MultiplayerState.connection!.broadcastStream.listen((data) {
      NavigationData? jsonAsNavData = tryToReadNavDataFromJson(data);

      log.info("Your route retard: ${jsonAsNavData?.route}");

      if(json.decode(data) == "New Game") {
        Navigator.of(Get.context!).pop(true);
        gameController.buildBoard();
      }
      else if(jsonAsNavData?.route == "Homepage") {
        Navigator.push(
            Get.context!,
            MaterialPageRoute(
                builder: (context) => RouteAwareWidget(
                    ( (MultiplayerState.connection != null) ? GameSelectionPageMultiplayer : GameSelectionPage).toString(),
                    child: ((MultiplayerState.connection != null) ? const GameSelectionPageMultiplayer() : const GameSelectionPage()))));
      }

      else {
        try {
        }
        on Error {
          if (jsonAsNavData ==
              NavigationData("stop", NavigationType.closeConnection)) {
            MultiplayerState.closeConnection();
            Navigator.pushAndRemoveUntil(
                Get.context!,
                MaterialPageRoute(
                  builder: (context) =>
                      RouteAwareWidget(
                        (HomePage).toString(),
                        child: const HomePage(),),), (route) => false);
          }
          else {
            List<List<int>> receivedBoard = json.decode(data).map<List<int>>((
                dynamic innerList) {
              return (innerList as List<dynamic>).cast<int>().toList();
            }).toList();
            log.info(
                "In startListening(): received '$data' and parsed it to '$receivedBoard'");

            gameController.turnYellow = !gameController.turnYellow;
            gameController.blockTurn = false;
            int newMoveInColumn = gameController.getIndexOfNewElementOfList(
                gameController.board, receivedBoard);

            var oldboard = gameController.board;
            log.info("Old board: $oldboard");
            log.info("New board: $receivedBoard");

            log.info("newMoveInColumn: $newMoveInColumn");
            gameController.board = receivedBoard;
            if (newMoveInColumn != -1) {
              gameController.checkForWinner(
                  newMoveInColumn);
            }
            gameController.update();
            log.info("finished listening for new Board from oter player");

            subscription?.cancel();
          }
          //completer.complete(receivedBoard);
        }
      }

    },
        onError: (error) {
          log.info("Error while trying to listen for Board Update");
          subscription?.cancel();
          //completer.completeError(error);
        }, onDone: () {
          //TODO: On stop Connection close stream subscription and set MultiplayerState.connection to null
          subscription!.cancel();
          log.info("Done method of startListening triggered");
        });
  }

  NavigationData? tryToReadNavDataFromJson(String data) {
    try {
      NavigationData? jsonAsNavData = NavigationData.fromJson(json.decode(data));
      return jsonAsNavData;
    }
    on Error {
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 100),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            color: Colors.blueAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GetBuilder<GameController>(
                    builder: (GetxController gameController) => Row(
                      children: _buildBoardMultiplayer(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}