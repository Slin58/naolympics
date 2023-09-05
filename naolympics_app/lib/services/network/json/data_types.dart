enum DataType {
  connectionEstablishment,
  navigation,
  gameEndData,
  ticTacToe,
  connect4;

  static DataType? fromString(String dataType) {
    return DataType.values
        .where((element) => element.name == dataType)
        .firstOrNull;
  }
}
