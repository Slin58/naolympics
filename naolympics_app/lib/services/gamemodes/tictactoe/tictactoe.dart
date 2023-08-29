import 'package:logging/logging.dart';
import 'package:naolympics_app/services/gamemodes/gamemode.dart';


abstract class TicTacToe implements GameMode {
  List<List<TicTacToeFieldValues>> _playField;
  TicTacToeFieldValues _currentTurn;
  static final log = Logger((TicTacToe).toString());

  TicTacToe()
      : _playField =
            List.generate(3, (_) => List.filled(3, TicTacToeFieldValues.empty)),
        _currentTurn = TicTacToeFieldValues.o;

  @override
  void init() {
    log.info('Reset TicTacToe play field.');
    _playField =
        List.generate(3, (_) => List.filled(3, TicTacToeFieldValues.empty));
    _currentTurn = TicTacToeFieldValues.o;
  }

  @override
  Future<TicTacToeWinner> move(int row, int col);

  TicTacToeWinner makeMove(int row, int col) {
    if (_playField[row][col] == TicTacToeFieldValues.empty) {
      log.info('Making move for Player $_currentTurn');

      _playField[row][col] = _currentTurn;
      TicTacToeWinner winner = _checkWinner(row, col);
      _switchTurn();

      return winner;
    }
    return TicTacToeWinner.ongoing;
  }

  TicTacToeWinner _checkWinner(int row, int col) {
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
      return currentSymbol == TicTacToeFieldValues.x
          ? TicTacToeWinner.x
          : TicTacToeWinner.o;
    } else if (isBoardFull) {
      return TicTacToeWinner.draw;
    } else {
      return TicTacToeWinner.ongoing;
    }
  }

  void _switchTurn() {
    _currentTurn = _currentTurn == TicTacToeFieldValues.o
        ? TicTacToeFieldValues.x
        : TicTacToeFieldValues.o;
  }

  List<List<TicTacToeFieldValues>> get playField => _playField;

  TicTacToeFieldValues get currentTurn => _currentTurn;
}

enum TicTacToeFieldValues { x, o, empty }

enum TicTacToeWinner { x, o, draw, ongoing }
