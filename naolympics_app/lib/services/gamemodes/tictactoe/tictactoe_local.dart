import 'package:naolympics_app/services/gamemodes/tictactoe/tictactoe.dart';

class TicTacToeLocal extends TicTacToe {
  @override
  Future<TicTacToeWinner> move(int row, int col) {
    return Future(() => makeMove(row, col));
  }
}
