abstract class GameMode {
  void init();

  Future<Enum> move(int row, int col);
}

class MoveData {
  final int row;
  final int column;

  MoveData(this.row, this.column);
}
