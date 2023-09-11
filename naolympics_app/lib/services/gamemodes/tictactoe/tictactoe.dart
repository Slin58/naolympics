import 'package:logging/logging.dart';
import 'package:naolympics_app/services/gamemodes/gamemode.dart';

abstract class TicTacToe implements GameMode {
  List<List<TicTacToeFieldValues>> _playField;
  TicTacToeFieldValues currentTurn;
  TicTacToeWinner winner;
  static final log = Logger((TicTacToe).toString());

  TicTacToe({this.currentTurn = TicTacToeFieldValues.o})
      : _playField =
            List.generate(3, (_) => List.filled(3, TicTacToeFieldValues.empty)),
        winner = TicTacToeWinner.ongoing;

  @override
  void init() {
    log.info('Reset TicTacToe play field.');
    _playField =
        List.generate(3, (_) => List.filled(3, TicTacToeFieldValues.empty));
    currentTurn = TicTacToeFieldValues.o;
    winner = TicTacToeWinner.ongoing;
  }

  @override
  Future<void> move(int row, int col);

  makeMove(int row, int col) {
    if (_playField[row][col] == TicTacToeFieldValues.empty) {
      log.info('Making move for Player ${currentTurn.name}');

      _playField[row][col] = currentTurn;
      checkWinner(row, col);
      _switchTurn();
    }
  }

  void checkWinner(int row, int col) {
    TicTacToeFieldValues currentSymbol = _playField[row][col];
    bool won = false;
    bool isBoardFull = true;

    // Check row
    if (_playField[row][0] == currentSymbol &&
        _playField[row][1] == currentSymbol &&
        _playField[row][2] == currentSymbol) {
      won = true;
    }

    // Check column
    if (_playField[0][col] == currentSymbol &&
        _playField[1][col] == currentSymbol &&
        _playField[2][col] == currentSymbol) {
      won = true;
    }

    // Check diagonal (top-left to bottom-right)
    if (_playField[0][0] == currentSymbol &&
        _playField[1][1] == currentSymbol &&
        _playField[2][2] == currentSymbol) {
      won = true;
    }

    // Check diagonal (top-right to bottom-left)
    if (_playField[0][2] == currentSymbol &&
        _playField[1][1] == currentSymbol &&
        _playField[2][0] == currentSymbol) {
      won = true;
    }

    // check for tie
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_playField[i][j] == TicTacToeFieldValues.empty) {
          isBoardFull = false;
          break;
        }
      }
      if (!isBoardFull) {
        break;
      }
    }

    if (won) {
      winner = currentSymbol == TicTacToeFieldValues.x
          ? TicTacToeWinner.x
          : TicTacToeWinner.o;
    } else if (isBoardFull) {
      winner = TicTacToeWinner.draw;
    } else {
      winner = TicTacToeWinner.ongoing;
    }
  }

  void _switchTurn() {
    currentTurn = currentTurn == TicTacToeFieldValues.o
        ? TicTacToeFieldValues.x
        : TicTacToeFieldValues.o;
  }

  List<List<TicTacToeFieldValues>> get playField => _playField;
}

enum TicTacToeFieldValues { x, o, empty}

enum TicTacToeWinner { x, o, draw, ongoing }
