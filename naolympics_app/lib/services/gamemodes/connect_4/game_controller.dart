import "dart:async";

import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/screens/connect_4/connect_four_page.dart";
import "package:naolympics_app/screens/connect_4/widgets/cell.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/services/network/json/json_data.dart";
import "package:naolympics_app/services/network/json/json_objects/connect4_data.dart";
import "package:naolympics_app/services/network/json/json_objects/game_end_data.dart";
import "package:naolympics_app/utils/ui_utils.dart";

class GameController extends GetxController {
  static final log = Logger((GameController).toString());
  List<List<int>> board = [];
  final RxBool _turnYellow = true.obs;

  bool get turnYellow => _turnYellow.value;
  bool blockTurn = false;

  void resetBoard() {
    initBoard();
    _turnYellow.value = true;
    if (MultiplayerState.hasConnection()) {
      if (MultiplayerState.isHosting()) {
        blockTurn = false;
      } else {
        startListening();
        blockTurn = true;
      }
    }
  }

  void initBoard() {
    board = [
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
    initBoard();
  }

  Future<void> playColumnMultiplayer(int columnNumber) async {
    log.finer("Move made by playColumnMultiplayer");
    if (board[columnNumber].contains(0)) {
      makeMoveOnField(columnNumber);
      await MultiplayerState.getConnection().writeJsonData(Connect4Data(board));
      startListening(); // ignore: unawaited_futures
      update();
    } else {
      Get.snackbar("Not available", "This column is full already",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> playColumnLocal(int columnNumber) async {
    log.finer("Move made by playColumnLocal");
    if (board[columnNumber].contains(0)) {
      makeMoveOnField(columnNumber);
      //nao specific => prevents rapid clicking of nao due to the aluminum foil
      blockTurn = await Future.delayed(const Duration(seconds: 1), () => false);
    } else {
      Get.snackbar("Not available", "This column is full already",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void makeMoveOnField(int columnNumber) {
    final int playerNumber = getPlayerNumber();
    final int row = board[columnNumber].indexWhere((cell) => cell == 0);
    board[columnNumber][row] = playerNumber;
    update();
    checkForWinner(columnNumber);
    checkForFullBoard();
    _turnYellow.value = !_turnYellow.value;
    blockTurn = true;
  }

  int checkForWinner(int columnNumber) {
    final int horizontalWinCond = checkForHorizontalWin(columnNumber);
    final int verticalWinCond = checkForVerticalWin(columnNumber);
    final int diagonalWinCond = checkDiagonalWinCond(columnNumber);

    final int winner = (horizontalWinCond != 0)
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

  int getPlayerNumber() {
    return turnYellow ? 1 : 2;
  }

  int getIndexOfNewElementOfList(
      List<List<int>> previousBoard, List<List<int>> newBoard) {
    for (int i = 0; i < previousBoard.length; i++) {
      if (!(const ListEquality().equals(previousBoard[i], newBoard[i]))) {
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
        title: const Text("Draw"),
        content: Obx(
          () => buttonVisible.value
              ? TextButton(
                  onPressed: () {
                    resetBoard();
                    buttonVisible.value = false;
                    Get.back(id: dialogKey.currentContext!.hashCode);
                  },
                  child: const Text("OK"),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  void checkForFullBoard() {
    for (List<int> elem in board) {
      for (int cell in elem) {
        if (cell == 0) {
          return;
        }
      }
    }
    log.finer("FullBoard!");
    showFullBoardDialog();
  }

  Future<void> declareWinner(int winner) async {
    blockTurn = true;
    BuildContext? diaContext;
    //ignore: unawaited_futures
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        diaContext = context;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            winner == 1 ? "Player 1 (yellow) won" : "Player 2 (red) won",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 90,
            child: Center(
              child: Cell(
                currCellState: winner == 1 ? CellState.yellow : CellState.red,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () async {
                    if (!MultiplayerState.hasConnection()) {
                      resetBoard();
                      Navigator.pop(context);
                      Navigator.pop(connectFourPageBuildContext!);
                    } else if (MultiplayerState.isClient()) {
                      UIUtils.showTemporaryAlert(context, "Wait for the host");
                    } else {
                      resetBoard();
                      await MultiplayerState.getConnection()
                          .writeJsonData(GameEndData(false, true));
                      await Future.delayed(const Duration(milliseconds: 500));
                      Navigator.pop(context);
                      Navigator.pop(connectFourPageBuildContext!);
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Go back",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    if (!MultiplayerState.hasConnection()) {
                      Navigator.of(context).pop(true);
                      resetBoard();
                    } else if (MultiplayerState.isClient()) {
                      UIUtils.showTemporaryAlert(context, "Wait for the host");
                    } else {
                      MultiplayerState.getConnection()
                          .writeJsonData(GameEndData(true, false));
                      Navigator.of(context).pop(true);
                      resetBoard();
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Replay",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        );
      },
    );

    StreamSubscription<String>? subscription;
    if (MultiplayerState.isClient()) {
      subscription =
          MultiplayerState.getConnection().broadcastStream.listen((data) {
        JsonData jsonData = JsonData.fromJsonString(data);
        if (jsonData is GameEndData) {
          if (jsonData.reset) {
            Navigator.pop(diaContext!);
            resetBoard();
          } else if (jsonData.goBack) {
            resetBoard();
            Navigator.pop(diaContext!);

            log
              ..finer(
                  "Routing service is: ${MultiplayerState.clientRoutingService != null} ")
              ..finer("Received the following data: $jsonData");
          }
          subscription!.cancel();
        }
      });
    }
  }

  int checkForVerticalWin(int columnNumber) {
    return checkForConsecutiveNumber(board[columnNumber]);
  }

  int checkForHorizontalWin(int columnNumber) {
    return checkForConsecutiveNumber(getRowAsList(columnNumber));
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
    int rowIndex = (board[columnNumber].length - 1) -
        board[columnNumber].reversed.toList().indexWhere((cell) => cell != 0);
    List<int> rowEntries = [];
    board.forEach((column) => rowEntries.add(column[rowIndex]));
    return rowEntries;
  }

  int checkDiagonalWinCond(int columnNumber) {
    int columnMax = 6;
    int rowMax = 5;
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
      //left upper
      colCounter--;
      rowCounter++;
      List<int> curColumn = board[colCounter];
      downwardsDiagonal.insert(0, curColumn[rowCounter]);
    }
    colCounter = columnNumber;
    rowCounter = rowIndex;
    while (colCounter < columnMax && rowCounter > 0) {
      //right down
      colCounter++;
      rowCounter--;
      List<int> curColumn = board[colCounter];
      downwardsDiagonal.add(curColumn[rowCounter]);
    }
    log.finer("DownardsDiagonal: $downwardsDiagonal");
    return downwardsDiagonal;
  }

  List<int> getUpwardsDiagonalAsList(
      int columnNumber, int rowIndex, int columnMax, int rowMax) {
    List<int> upwardsDiagonal = [board[columnNumber][rowIndex]];
    int colCounter = columnNumber;
    int rowCounter = rowIndex;
    while (colCounter < columnMax && rowCounter < rowMax) {
      //right upper
      colCounter++;
      rowCounter++;
      List<int> curColumn = board[colCounter];
      upwardsDiagonal.add(curColumn[rowCounter]);
    }
    colCounter = columnNumber;
    rowCounter = rowIndex;
    while (colCounter > 0 && rowCounter > 0) {
      //left down
      colCounter--;
      rowCounter--;
      List<int> curColumn = board[colCounter];
      upwardsDiagonal.insert(0, curColumn[rowCounter]);
    }
    log.finer("UpwardsDiagonal: $upwardsDiagonal");
    return upwardsDiagonal;
  }

  Future<void> startListening() async {
    log.finer("stillListening has jus been called.");
    late StreamSubscription<String>? subscription;
    subscription = MultiplayerState.getConnection().broadcastStream.listen((data) {
      blockTurn = false;
      JsonData jsonData = JsonData.fromJsonString(data);

      if (jsonData is GameEndData && MultiplayerState.isClient()) {
        log.finer("stopping listening.");
        subscription!.cancel();
        return;
      } else if (jsonData is Connect4Data) {
        List<List<int>> receivedBoard = jsonData.board;
        log.finer(
            "In startListening(): received '$data' and parsed it to '$receivedBoard'");
        int newMoveInColumn = getIndexOfNewElementOfList(board, receivedBoard);
        if (newMoveInColumn == -1) {
          subscription!.cancel();
          return;
        }
        _turnYellow.value = !_turnYellow.value;
        var oldBoard = board;
        log
          ..finer("Old board: $oldBoard")
          ..finer("New board: $receivedBoard")
          ..finer("newMoveInColumn: $newMoveInColumn");
        board = receivedBoard;
        if (newMoveInColumn != -1) {
          if (checkForWinner(newMoveInColumn) != 0) {
            subscription!.cancel();
            return;
          }
        }
        update();
        log.finer("finished listening for new Board from other player.");
        subscription!.cancel();
      } else {
        log
          ..finer("Unknown Datatype received in startListning: $jsonData")
          ..finer(
              "Navigator status: ${MultiplayerState.clientRoutingService != null}");
      }
      log.finer("Still listening and received: $data");
    }, onError: (error) {
      log.finer("Error while trying to listen for Board Update");
      MultiplayerState.clientRoutingService?.resumeNavigator();

      subscription?.cancel();
    }, onDone: () {
      MultiplayerState.clientRoutingService?.resumeNavigator();
      log.info("Done method of startListening triggered");

      subscription!.cancel();
    });
  }
}
