import 'dart:io';
import 'dart:typed_data';

import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';
import 'package:naolympics_app/services/network/network_service.dart';

class TicTacToeMultiplayer extends TicTacToe {
  NetworkService networkService;

  TicTacToeMultiplayer(Socket connection)
      : networkService = NetworkService(connection);

  @override
  Future<TicTacToeWinner> move(int x, int y) async {
    if (super.playField[x][y] == TicTacToeFieldValues.empty) {
      makeMove(x, y);
      await networkService.sendData(Uint8List.fromList([x, y]));
      Uint8List enemyTurn = await networkService.receiveData();
      return makeMove(enemyTurn[0], enemyTurn[1]);
    }
    return TicTacToeWinner.ongoing;
  }
}
