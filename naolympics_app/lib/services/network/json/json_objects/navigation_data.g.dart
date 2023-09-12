// GENERATED CODE - DO NOT MODIFY BY HAND

part of "navigation_data.dart";

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigationData _$NavigationDataFromJson(Map<String, dynamic> json) =>
    NavigationData(
      json["route"] as String,
      $enumDecode(_$NavigationTypeEnumMap, json["navigationType"]),
    )..dataType = $enumDecode(_$DataTypeEnumMap, json["dataType"]);

Map<String, dynamic> _$NavigationDataToJson(NavigationData instance) =>
    <String, dynamic>{
      "dataType": _$DataTypeEnumMap[instance.dataType]!,
      "route": instance.route,
      "navigationType": _$NavigationTypeEnumMap[instance.navigationType]!,
    };

const _$NavigationTypeEnumMap = {
  NavigationType.push: "push",
  NavigationType.pop: "pop",
  NavigationType.dispose: "dispose",
  NavigationType.closeConnection: "closeConnection",
};

const _$DataTypeEnumMap = {
  DataType.connectionEstablishment: "connectionEstablishment",
  DataType.navigation: "navigation",
  DataType.gameEndData: "gameEndData",
  DataType.ticTacToe: "ticTacToe",
  DataType.connect4: "connect4",
};
