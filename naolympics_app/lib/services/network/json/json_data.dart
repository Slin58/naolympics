import "dart:convert";

import "package:naolympics_app/services/network/json/data_types.dart";
import "package:naolympics_app/services/network/json/json_objects/connection_establishment.dart";
import "package:naolympics_app/services/network/json/json_objects/game_end_data.dart";
import "package:naolympics_app/services/network/json/json_objects/navigation_data.dart";
import "package:naolympics_app/services/network/json/json_objects/tictactoe_data.dart";

abstract class JsonData {
  DataType dataType;

  JsonData(this.dataType);

  Map<String, dynamic> toJson();

  static JsonData fromJsonString(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    DataType? type = DataType.fromString(map["dataType"]);
    if (type != null) {
      switch (type) {
        case DataType.connectionEstablishment:
          return ConnectionEstablishment.fromJson(map);
        case DataType.navigation:
          return NavigationData.fromJson(map);
        case DataType.ticTacToe:
          return TicTacToeData.fromJson(map);
        case DataType.gameEndData:
          return GameEndData.fromJson(map);
        default:
          throw UnimplementedError("Unknown DataType '$type");
      }
    } else {
      throw Error();
    }
  }
}
