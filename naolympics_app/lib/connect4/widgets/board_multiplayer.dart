import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';
import 'package:naolympics_app/services/network/json/json_objects/game_end_data.dart';
import '../../screens/game_selection/game_selection_multiplayer.dart';
import '../../screens/home_page.dart';
import '../../services/network/json/json_objects/connect4_data.dart';
import '../../services/network/json/json_objects/navigation_data.dart';
import '../../services/routing/route_aware_widgets/route_aware_widget.dart';
import '../gameController/game_controller.dart';
import 'board_column.dart';

class BoardMultiplayer extends StatelessWidget {
  final GameController gameController = Get.find<GameController>();
  static final log = Logger((BoardMultiplayer).toString());

  List<BoardColumn> _buildBoardMultiplayer() {
    int currentColNumber = 0;

    if(MultiplayerState.isClient()) MultiplayerState.clientRoutingService?.pauseNavigator();

    startListening();

    return gameController.board
        .map((boardColumn) => BoardColumn(
      chipsInColumn: boardColumn,
      columnNumber: currentColNumber++,
    ))
        .toList();
  }

  Future<void> startListening() async {
    StreamSubscription<String>? subscription;
    final GameController gameController = Get.find<GameController>();
    subscription = MultiplayerState.connection!.broadcastStream.listen((data) {

      log.info("turnyellow: ${gameController.turnYellow}");
      log.info("!turnyellow: ${!gameController.turnYellow}");

      gameController.blockTurn = false;

      JsonData jsonData = JsonData.fromJsonString(data);

       if(jsonData is GameEndData && MultiplayerState.isClient()) {
        gameController.buildBoard();
        subscription!.cancel();
      }

      else if (jsonData is NavigationData) {
         MultiplayerState.clientRoutingService?.resumeNavigator();
    }
          else if(jsonData is Connect4Data) {
            List<List<int>> receivedBoard = jsonData.board;
            log.info("In startListening(): received '$data' and parsed it to '$receivedBoard'");
            int newMoveInColumn = gameController.getIndexOfNewElementOfList(gameController.board, receivedBoard);

            //TODO: WHY THE FUCK IS ONLY THE CLIENT PLAYER TITLE BEING UPDATED???? THAT MAKES NO FUCKING SENDE?????!!!!!

            gameController.setTurnYellow();
            gameController.update();
            log.info("new turn yellow: ${gameController.turnYellow}");

            var oldboard = gameController.board;
            log.info("Old board: $oldboard");
            log.info("New board: $receivedBoard");

            log.info("newMoveInColumn: $newMoveInColumn");
            gameController.board = receivedBoard;
            if (newMoveInColumn != -1) {
              gameController.checkForWinner(newMoveInColumn);
            }
            gameController.update();
            log.info("finished listening for new Board from other player");
          }
          else {
            log.info("Unknown Datatype received: $jsonData");
       }
    },
        onError: (error) {
          log.info("Error while trying to listen for Board Update");
          MultiplayerState.clientRoutingService?.resumeNavigator();
          subscription?.cancel();
          //completer.completeError(error);
        }, onDone: () {
          MultiplayerState.clientRoutingService?.resumeNavigator();
          log.info("Done method of startListening triggered");
          subscription!.cancel();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteAwareWidget(
                        (GameSelectionPageMultiplayer).toString(),
                        child: const GameSelectionPageMultiplayer())));
          },
        ),
        title: Obx(() => Text(
          gameController.turnYellow
              ? "Player 1 (yellow)"
              : "Player 2 (red)",
          style: TextStyle(
            color: gameController.turnYellow ? Colors.yellow : Colors.red,
          ),
        )),
      ),
    body: Column(
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
                    builder: (gameController) => Row(
                      children: _buildBoardMultiplayer(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }

}