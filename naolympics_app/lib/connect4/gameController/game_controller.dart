import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:naolympics_app/connect4/widgets/board_multiplayer.dart';
import 'package:naolympics_app/services/network/json/json_objects/connect4_data.dart';
import 'package:naolympics_app/utils/ui_utils.dart';
import '../../screens/game_selection/game_selection.dart';
import '../../screens/game_selection/game_selection_multiplayer.dart';
import '../../services/multiplayer_state.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import '../../services/network/json/json_data.dart';
import '../../services/network/json/json_objects/game_end_data.dart';
import '../../services/network/json/json_objects/navigation_data.dart';
import '../../services/routing/client_routing_service.dart';
import '../../services/routing/route_aware_widgets/route_aware_widget.dart';
import '../widgets/cell.dart';

class GameController extends GetxController {
  static final log = Logger((GameController).toString());
  List<List<int>> board = [];
  RxBool _turnYellow = true.obs;
  bool get turnYellow => _turnYellow.value;
  bool blockTurn = false;

  void buildBoard() {
    this.board = [
      List.filled(6, 0),
      List.filled(6, 0),
      List.filled(6, 0),
      List.filled(6, 0),
      List.filled(6, 0),
      List.filled(6, 0),
      List.filled(6, 0),
    ];
    update();
  }

  @override
  void onInit() {
    super.onInit();
    buildBoard();
  }

  Future<List<List<int>>?> getBoardFromOtherPlayer() {
    final completer = Completer<List<List<int>>?>();
    StreamSubscription<String> subscription =
        MultiplayerState.connection!.broadcastStream.listen((data) {
      List<List<int>> receivedBoard = jsonDecode(data);

      log.info("Server received '$data' and parsed it to '$receivedBoard'");
      completer.complete(receivedBoard);
    }, onError: (error) {
      log.info('Error: $error');
      completer.completeError(error);
    }, onDone: () {
      log.info("finished getting board from other player");
    });
    subscription.cancel();

    return completer.future.timeout(const Duration(seconds: 10));
  }

  Future<void> playColumnMultiplayer(int columnNumber) async {
    final int playerNumber = turnYellow ? 1 : 2;
    log.info("Move made by playColumnMultiplayer");

    if (board[columnNumber].contains(0)) {
      final int row = board[columnNumber].indexWhere((cell) => cell == 0);
      board[columnNumber][row] = playerNumber;
      update();

      checkForWinner(columnNumber);

      if (checkForFullBoard() == 1) {
        int fB = checkForFullBoard();
        print("FullBoard: $fB");
        showFullBoardDialog();
      }
      blockTurn = true;
      _turnYellow.value = !_turnYellow.value;
      MultiplayerState.connection!.writeJsonData(Connect4Data(board));
    } else {
      Get.snackbar("Not available", "This column is full already",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> playColumnLocal(int columnNumber) async {
    final int playerNumber = turnYellow ? 1 : 2;
    log.info("Move made by playColumnLocal");

    if (board[columnNumber].contains(0)) {
      final int row = board[columnNumber].indexWhere((cell) => cell == 0);
      board[columnNumber][row] = playerNumber;
      update();
      checkForWinner(columnNumber);
      _turnYellow.value = !_turnYellow.value;
      if (checkForFullBoard() == 1) {
        int fB = checkForFullBoard();
        print("FullBoard: $fB");
        showFullBoardDialog();
      }
      blockTurn = true;
      blockTurn = await Future.delayed(const Duration(seconds: 1), () => false);
    } else {
      Get.snackbar("Not available", "This column is full already",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  int checkForWinner(int columnNumber) {
    int horizontalWinCond = checkForHorizontalWin(columnNumber);
    int verticalWinCond = checkForVerticalWin(columnNumber);
    int diagonalWinCond = checkDiagonalWinCond(columnNumber);
    print("Horizontal Winner: $horizontalWinCond");
    print("Vertical Winner: $verticalWinCond");

    int winner = (horizontalWinCond != 0)
        ? horizontalWinCond
        : (verticalWinCond != 0)
            ? verticalWinCond
            : (diagonalWinCond != 0)
                ? diagonalWinCond
                : 0;

    if (winner != 0) {
      declareWinner(winner);
    }
    return winner;
  }

  int getIndexOfNewElementOfList(
      List<List<int>> previousBoard, List<List<int>> newBoard) {
    Function eq = const ListEquality().equals;
    for (int i = 0; i < previousBoard.length; i++) {
      if (!eq(previousBoard[i], newBoard[i])) {
        return newBoard.indexOf(newBoard[i]);
      }
    }
    return -1;
  }

  void showFullBoardDialog() {
    final RxBool buttonVisible = true.obs;
    final GlobalKey<State> dialogKey = GlobalKey<State>();

    Get.dialog(
      AlertDialog(
        key: dialogKey,
        title: Text('Draw'),
        content: Obx(
          () => buttonVisible.value
              ? TextButton(
                  onPressed: () {
                    buildBoard();
                    buttonVisible.value = false;
                    Get.back(id: dialogKey.currentContext!.hashCode);
                  },
                  child: Text('OK'),
                )
              : SizedBox(),
        ),
      ),
    );
  }

  int checkForFullBoard() {
    for (List<int> elem in board) {
      for (int cell in elem) {
        if (cell == 0) {
          return 0;
        }
      }
    }
    return 1;
  }

  BuildContext getContext() {
    return Get.context!;
  }

  Future<void> declareWinner(int winner) async {

    blockTurn = true;
    BuildContext? diaContext;
    showDialog(context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        diaContext = context;
            return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            winner == 1 ? 'Player 1 (yellow) won' : 'Player 2 (red) won',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 90,
            child: Center(
              child: Cell(
                currCellState: winner == 1 ? CellState.YELLOW : CellState.RED,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {

                    if(MultiplayerState.connection == null) {
                      Navigator.of(context).pop(true);
                      buildBoard();
                    }
                    else if (MultiplayerState.isClient()) {
                      UIUtils.showTemporaryAlert(context, "Wait for the host");
                    }
                    else {
                      MultiplayerState.connection!
                          .writeJsonData(GameEndData(true, false));
                      Navigator.of(context).pop(true);
                      buildBoard();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Replay'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {

                    if(MultiplayerState.connection == null) {
                      Navigator.of(context).pop(true);
                      buildBoard();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RouteAwareWidget(
                                  (GameSelectionPage).toString(),
                                  child: const GameSelectionPage())));


                    }
                    else if (MultiplayerState.isClient()) {
                      UIUtils.showTemporaryAlert(context, "Wait for the host");
                    } else {
                      buildBoard();
                      await MultiplayerState.connection!.writeJsonData(GameEndData(false, true));
                      //Navigator.of(context).pop(true);
                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RouteAwareWidget(
                                  (GameSelectionPageMultiplayer).toString(),
                                  child: const GameSelectionPageMultiplayer() )));

                      //MultiplayerState.connection!.write("\"dataType\":\"navigation\",\"route\":\"GameSelectionPageMultiplayer\",\"navigationType\":\"push\"");

                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Go Back'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    StreamSubscription<String>? subscription;

    if(MultiplayerState.isClient()) {

      subscription = MultiplayerState.connection!.broadcastStream.listen((data) {
        buildBoard();
        JsonData jsonData = JsonData.fromJsonString(data);

        if(jsonData is GameEndData) {
          if(jsonData.reset) {
            buildBoard();
            Navigator.of(diaContext!).pop(true);
            subscription!.cancel();
            startListening();
          }

          else if(jsonData.goBack) {
            //Navigator.of(diaContext!).pop(true);
            log.info("Navigator was resumed");
            Navigator.of(diaContext!).pop(true);

            MultiplayerState.clientRoutingService?.resumeNavigator();

            log.info("Routing service is: ${MultiplayerState.clientRoutingService != null} ");
            stillListening = false;

            subscription!.cancel();
          }
        }
      });
    }


  }

  int checkForVerticalWin(int columnNumber) {
    List<int> column = board[columnNumber];
    return checkForConsecutiveNumber(column);
  }

  int checkForHorizontalWin(int columnNumber) {
    List<int> rowEntries = getRowAsList(columnNumber);
    return checkForConsecutiveNumber(rowEntries);
  }

  int checkForConsecutiveNumber(List<int> list) {
    int consecutiveYellows = 0;
    int consecutiveReds = 0;

    for (var i = 0; i < list.length; i++) {
      if (consecutiveYellows >= 4 || consecutiveReds >= 4) {
        break;
      }
      if (list[i] == 1) {
        consecutiveYellows++;
        consecutiveReds = 0;
      } else if (list[i] == 2) {
        consecutiveReds++;
        consecutiveYellows = 0;
      } else {
        consecutiveReds = 0;
        consecutiveYellows = 0;
      }
    }
    if (consecutiveYellows >= 4) {
      return 1;
    } else if (consecutiveReds >= 4) {
      return 2;
    } else {
      return 0;
    }
  }

  List<int> getRowAsList(int columnNumber) {
    List<int> colm = board[columnNumber].reversed.toList();
    print("Column: $colm");
    int rowIndex = (board[columnNumber].length - 1) -
        board[columnNumber].reversed.toList().indexWhere((cell) => cell != 0);
    List<int> rowEntries = [];
    board.forEach((column) => rowEntries.add(column[rowIndex]));
    print("row: $rowEntries");

    return rowEntries;
  }

  int checkDiagonalWinCond(int columnNumber) {
    int columnMax = 6; //max indices of the lists representing the field
    int rowMax = 5; //max indices of the lists representing the field
    int rowIndex = (board[columnNumber].length - 1) -
        board[columnNumber].reversed.toList().indexWhere((cell) => cell != 0);

    List<int> upwardsDiagonal =
        getUpwardsDiagonalAsList(columnNumber, rowIndex, columnMax, rowMax);
    List<int> downwardsDiagonal =
        getDownwardsDiagonalAsList(columnNumber, rowIndex, columnMax, rowMax);

    return checkForConsecutiveNumber(upwardsDiagonal) != 0
        ? checkForConsecutiveNumber(upwardsDiagonal)
        : checkForConsecutiveNumber(downwardsDiagonal);
  }

  List<int> getDownwardsDiagonalAsList(
      int columnNumber, int rowIndex, int columnMax, int rowMax) {
    List<int> downwardsDiagonal = [board[columnNumber][rowIndex]];
    int colCounter = columnNumber;
    int rowCounter = rowIndex;

    colCounter = columnNumber;
    rowCounter = rowIndex;
    while (colCounter > 0 && rowCounter < rowMax) {
      //links oben
      colCounter--;
      rowCounter++;
      List<int> curColumn = board[colCounter];
      downwardsDiagonal.insert(0, curColumn[rowCounter]);
    }

    colCounter = columnNumber;
    rowCounter = rowIndex;
    while (colCounter < columnMax && rowCounter > 0) {
      //rechts unten
      colCounter++;
      rowCounter--;
      List<int> curColumn = board[colCounter];
      downwardsDiagonal.add(curColumn[rowCounter]);
    }

    print("DownardsDiagonal: $downwardsDiagonal");

    return downwardsDiagonal;
  }

  List<int> getUpwardsDiagonalAsList(
      int columnNumber, int rowIndex, int columnMax, int rowMax) {
    List<int> upwardsDiagonal = [board[columnNumber][rowIndex]];

    int colCounter = columnNumber;
    int rowCounter = rowIndex;
    while (colCounter < columnMax && rowCounter < rowMax) {
      //rechts oben
      colCounter++;
      rowCounter++;
      List<int> curColumn = board[colCounter];
      upwardsDiagonal.add(curColumn[rowCounter]);
    }

    colCounter = columnNumber;
    rowCounter = rowIndex;
    while (colCounter > 0 && rowCounter > 0) {
      //links unten
      colCounter--;
      rowCounter--;
      List<int> curColumn = board[colCounter];
      upwardsDiagonal.insert(0, curColumn[rowCounter]);
    }

    print("UpwardsDiagonal: $upwardsDiagonal");

    return upwardsDiagonal;
  }


  //todo: startListening() in GameController verschieben?
  Future<void> startListening() async {

    stillListening = true;

    if(MultiplayerState.isClient() && !MultiplayerState.clientRoutingService!.isNavigatorPaused()) {
      MultiplayerState.clientRoutingService?.pauseNavigator();
    }

    StreamSubscription<String>? subscription;
    final GameController gameController = Get.find<GameController>();
    subscription = MultiplayerState.connection!.broadcastStream.listen((data) {
      gameController.blockTurn = false;

      JsonData jsonData = JsonData.fromJsonString(data);

      if(jsonData is GameEndData && MultiplayerState.isClient()) {
       /* if(jsonData.reset) {
          gameController.buildBoard();
        }
        else if(jsonData.goBack) {
          MultiplayerState.clientRoutingService?.resumeNavigator();
          gameController.buildBoard();
        }
        */
        log.info("stopping listening");
        subscription!.cancel();
      }

     /* else if (jsonData is NavigationData) {
        MultiplayerState.clientRoutingService?.resumeNavigator();
      } */

      else if(jsonData is Connect4Data) {
        List<List<int>> receivedBoard = jsonData.board;
        log.info("In startListening(): received '$data' and parsed it to '$receivedBoard'");
        int newMoveInColumn = gameController.getIndexOfNewElementOfList(gameController.board, receivedBoard);

        _turnYellow.value = !_turnYellow.value;

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
        log.info("removed \\n: ${ jsonData.toString().replaceAll("\\n", "") }");
        log.info("normal form: ${jsonData.toString()}");

        log.info("Unknown Datatype received: ${jsonData}");
        log.info("Navigator status: ${MultiplayerState.clientRoutingService != null}");

      }

      log.info("Still listening and received: $data");


    },
        onError: (error) {
          log.info("Error while trying to listen for Board Update");
          MultiplayerState.clientRoutingService?.resumeNavigator();
          stillListening = false;

          subscription?.cancel();
          //completer.completeError(error);
        }, onDone: () {
          MultiplayerState.clientRoutingService?.resumeNavigator();
          log.info("Done method of startListening triggered");
          stillListening = false;

          subscription!.cancel();
        });
  }



}
