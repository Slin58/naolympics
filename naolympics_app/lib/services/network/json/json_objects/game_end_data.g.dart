// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_end_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameEndData _$GameEndDataFromJson(Map<String, dynamic> json) => GameEndData(
      json['reset'] as bool,
      json['goBack'] as bool,
    )..dataType = $enumDecode(_$DataTypeEnumMap, json['dataType']);

Map<String, dynamic> _$GameEndDataToJson(GameEndData instance) =>
    <String, dynamic>{
      'dataType': _$DataTypeEnumMap[instance.dataType]!,
      'reset': instance.reset,
      'goBack': instance.goBack,
    };

const _$DataTypeEnumMap = {
  DataType.connectionEstablishment: 'connectionEstablishment',
  DataType.navigation: 'navigation',
  DataType.gameEndData: 'gameEndData',
  DataType.ticTacToe: 'ticTacToe',
  DataType.connect4: 'connect4',
};
