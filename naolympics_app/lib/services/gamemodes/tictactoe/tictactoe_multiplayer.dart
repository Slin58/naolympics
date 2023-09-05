import 'dart:async';
import 'dart:ui';

import 'package:logging/logging.dart';
import 'package:naolympics_app/services/gamemodes/gamemode.dart';
import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';
import 'package:naolympics_app/services/multiplayer_state.dart';
import 'package:naolympics_app/services/network/json/json_objects/game_end_data.dart';
import 'package:naolympics_app/services/network/json/json_objects/tictactoe_data.dart';

import '../../network/json/json_data.dart';
import '../../network/socket_manager.dart';

class TicTacToeMultiplayer extends TicTacToe {
  static final log = Logger((TicTacToeMultiplayer).toString());
  static List<MoveData> moveStack = [];

  TicTacToeFieldValues playerSymbol;
  final void Function(VoidCallback) setState;
  late StreamSubscription<String> _gameSubscription;

  SocketManager socketManager;

  TicTacToeMultiplayer(this.socketManager, this.setState)
      : playerSymbol = MultiplayerState.isHosting()
            ? TicTacToeFieldValues.o
            : TicTacToeFieldValues.x {
    _gameSubscription = _setGameSubscription(socketManager);
  }

  StreamSubscription<String> _setGameSubscription(SocketManager socketManager) {
    return socketManager.broadcastStream.listen((data) {
      final ticTacToeData = JsonData.fromJsonString(data);
      log.finer("received $data");
      _handleIncomingData(ticTacToeData);
    }, onError: (error) {
      log.severe("Error while receiving routing instructions", error);
    }, onDone: () {
      log.info("Done routing.");
    });
  }

  void _handleIncomingData(JsonData data) {
    final type = data.runtimeType;
    if (type == TicTacToeData) {
      _handleGameData(data as TicTacToeData);
    } else if (type == GameEndData) {
      _handleGameEndData(data as GameEndData);
    } else {
      log.warning("Unknown JsonData type received: '$type'");
    }
  }

  void _handleGameData(TicTacToeData data) {
    setState.call(() => makeMove(data.row, data.column));
  }

  void _handleGameEndData(GameEndData data) {
    if (data.reset) {
      super.init();
    }
    if (data.goBack) {
      _cancelGameSubscription();
      if (MultiplayerState.isClient()) {
        MultiplayerState.clientRoutingService!.resumeNavigator();
      }
    }
  }

  void handleGoBack() {
    _cancelGameSubscription();
    _sendGoBack();
  }

  void _cancelGameSubscription(){
    _gameSubscription.cancel();
  }

  @override
  void init() {
    super.init();
    _sendReset();
  }

  Future<void> _sendReset() async {
    final gameEndData = GameEndData.getReset();
    log.fine("Sending move reset to ${MultiplayerState.getRemoteAddress()}");
    await socketManager.writeJsonData(gameEndData);
  }

  Future<void> _sendGoBack() async {
    final gameEndData = GameEndData.getGoBack();
    log.fine("Sending move goBack to ${MultiplayerState.getRemoteAddress()}");
    await socketManager.writeJsonData(gameEndData);
  }


  @override
  Future<TicTacToeWinner> move(int row, int col) async {
    if (currentTurn == playerSymbol &&
        super.playField[row][col] == TicTacToeFieldValues.empty) {
      TicTacToeWinner winner = makeMove(row, col);

      _sendMove(row, col);
      return winner;
    }
    return TicTacToeWinner.ongoing;
  }

  Future<void> _sendMove(int row, int col, {bool? reset}) async {
    reset = reset ?? false;
    final ticTacToeData =
        TicTacToeData(row, col, super.currentTurn, reset: reset);
    log.fine(
        "Sending move $ticTacToeData to ${MultiplayerState.getRemoteAddress()}");
    await socketManager.writeJsonData(ticTacToeData);
  }
}
