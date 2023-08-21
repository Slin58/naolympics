import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';
import 'package:naolympics_app/services/network/network_service.dart';

import '../../../screens/tic_tac_toe_page.dart';

class TicTacToeMultiplayer extends TicTacToe {
  NetworkService networkService;

  TicTacToeMultiplayer(Socket connection)
      : networkService = NetworkService(connection);

  @override
  Future<TicTacToeWinner> move(int row, int col) async {
    if (super.playField[row][col] == TicTacToeFieldValues.empty) {
      makeMove(row, col);
      await networkService.sendData(Uint8List.fromList([row, col]));
      Uint8List enemyTurn = await networkService.receiveData();
      return makeMove(enemyTurn[0], enemyTurn[1]);
    }
    return TicTacToeWinner.ongoing;
  }


}
