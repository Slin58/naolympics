import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';
import 'package:naolympics_app/services/network/json/json_objects/game_end_data.dart';
import '../../screens/home_page.dart';
import '../../services/network/json/json_objects/connect4_data.dart';
import '../../services/network/json/json_objects/navigation_data.dart';
import '../../services/routing/route_aware_widgets/route_aware_widget.dart';
import '../gameController/game_controller.dart';
import 'board_column.dart';

class BoardMultiplayerPage extends StatefulWidget {
  const BoardMultiplayerPage({super.key});

  @override
  State<StatefulWidget> createState() => BoardMultiplayerState();
}

class BoardMultiplayerState extends State<BoardMultiplayerPage> {
  final GameController gameController = Get.find<GameController>();
  static final log = Logger((BoardMultiplayerState).toString());

  List<BoardColumn> _buildBoardMultiplayer() {
    gameController.turnYellow = MultiplayerState.isHosting() ? true : false;
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
   // Completer<List<List<int>>> completer = Completer<List<List<int>>>();
    StreamSubscription<String>? subscription;
    final GameController gameController = Get.find<GameController>();
    subscription = MultiplayerState.connection!.broadcastStream.listen((data) {

      JsonData jsonData = JsonData.fromJsonString(data);

      if(jsonData is GameEndData && MultiplayerState.isClient()) {
        if(jsonData.goBack) MultiplayerState.clientRoutingService?.resumeNavigator();
        //Navigator.of(context).pop(true);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RouteAwareWidget(
                    (BoardMultiplayerPage).toString(),
                    child: const BoardMultiplayerPage(),),), (route) => false);

        gameController.buildBoard();
      }
      else if (jsonData is NavigationData) {
       if(jsonData == NavigationData("stop", NavigationType.closeConnection)) {
            MultiplayerState.closeConnection();
            Navigator.pushAndRemoveUntil(
                Get.context!,
                MaterialPageRoute(
                  builder: (context) =>
                      RouteAwareWidget(
                        (HomePage).toString(),
                        child: const HomePage(),),), (route) => false);
          }
    }
          else {
            List<List<int>> receivedBoard = (jsonData as Connect4Data).board;
            log.info("In startListening(): received '$data' and parsed it to '$receivedBoard'");

            gameController.turnYellow = !gameController.turnYellow;
            gameController.blockTurn = false;
            int newMoveInColumn = gameController.getIndexOfNewElementOfList(gameController.board, receivedBoard);

            var oldboard = gameController.board;
            log.info("Old board: $oldboard");
            log.info("New board: $receivedBoard");

            log.info("newMoveInColumn: $newMoveInColumn");
            gameController.board = receivedBoard;
            int winner = 0;
            if (newMoveInColumn != -1) {
              winner = gameController.checkForWinner(newMoveInColumn);
            }
            gameController.update();
            log.info("finished listening for new Board from oter player");

            if(winner != 0) subscription?.cancel();
          }
          //completer.complete(receivedBoard);
    },
        onError: (error) {
          log.info("Error while trying to listen for Board Update");
          subscription?.cancel();
          //completer.completeError(error);
        }, onDone: () {
          subscription!.cancel();
          log.info("Done method of startListening triggered");
        });
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