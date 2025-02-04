import "dart:async";

import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart";
import "package:naolympics_app/services/multiplayer_state.dart";
import "package:naolympics_app/services/network/json/json_data.dart";
import "package:naolympics_app/services/network/json/json_objects/game_end_data.dart";
import "package:naolympics_app/services/network/json/json_objects/tictactoe_data.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

class TicTacToeMultiplayer extends TicTacToe {
  static final log = Logger((TicTacToeMultiplayer).toString());

  TicTacToeFieldValues playerSymbol;
  BuildContext? _alertBuildContext;
  final void Function(VoidCallback) setState;
  late StreamSubscription<String> _gameSubscription;

  SocketManager socketManager;

  TicTacToeMultiplayer(this.socketManager, this.setState)
      : playerSymbol = MultiplayerState.isHosting()
            ? TicTacToeFieldValues.o
            : TicTacToeFieldValues.x {
    _gameSubscription = _setGameSubscription(socketManager);
    MultiplayerState.clientRoutingService?.pauseNavigator();
  }

  @override
  void init() {
    super.init();
    _sendReset();
  }

  @override
  Future<void> move(int row, int col) async {
    if (currentTurn == playerSymbol &&
        super.playField[row][col] == TicTacToeFieldValues.empty) {
      makeMove(row, col);
      // ignore: unawaited_futures
      _sendMove(row, col);
    }
  }

  StreamSubscription<String> _setGameSubscription(SocketManager socketManager) {
    return socketManager.broadcastStream.listen(_onData(),
        onError: (error) => log.severe("Error while receiving gamedata", error),
        onDone: () => log.info("Done handling game data."));
  }

  void Function(String data) _onData() {
    return (data) {
      log.finer("received $data");
      final jsonData = JsonData.fromJsonString(data);

      if (jsonData is TicTacToeData) {
        _handleGameData(jsonData);
      } else if (jsonData is GameEndData) {
        _handleGameEndData(jsonData);
      } else {
        log.warning("Unknown JsonData received: '${jsonData.runtimeType}'");
      }
    };
  }

  void _handleGameData(TicTacToeData data) {
    setState.call(() => makeMove(data.row, data.column));
  }

  void _handleGameEndData(GameEndData data) {
    if (data.reset) {
      setState.call(() => super.init());
    }
    if (data.goBack) {
      _cancelGameSubscription();
      if (MultiplayerState.isClient()) {
        MultiplayerState.clientRoutingService!.resumeNavigator();
      }
    }
    _closeAlert();
  }

  void _closeAlert() {
    if (MultiplayerState.isClient() && _alertBuildContext != null) {
      NavigatorState navigator = Navigator.of(_alertBuildContext!);
      if (navigator.canPop()) {
        navigator.pop();
        _alertBuildContext = null;
      }
    }
  }

  void handleGoBack() {
    _cancelGameSubscription();
    _sendGoBack();
  }

  void _cancelGameSubscription() {
    _gameSubscription.cancel();
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

  Future<void> _sendMove(int row, int col) async {
    final ticTacToeData = TicTacToeData(row, col, super.currentTurn);
    log.fine("Sending move '$ticTacToeData' to ${MultiplayerState.getRemoteAddress()}");
    await socketManager.writeJsonData(ticTacToeData);
  }

  set alertBuildContext(BuildContext value) {
    _alertBuildContext = value;
  }
}
