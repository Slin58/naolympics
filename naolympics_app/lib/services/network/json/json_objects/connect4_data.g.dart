// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect4_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Connect4Data _$Connect4DataFromJson(Map<String, dynamic> json) => Connect4Data(
      (json['board'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
    )..dataType = $enumDecode(_$DataTypeEnumMap, json['dataType']);

Map<String, dynamic> _$Connect4DataToJson(Connect4Data instance) =>
    <String, dynamic>{
      'dataType': _$DataTypeEnumMap[instance.dataType]!,
      'board': instance.board,
    };

const _$DataTypeEnumMap = {
  DataType.connectionEstablishment: 'connectionEstablishment',
  DataType.navigation: 'navigation',
  DataType.gameEndData: 'gameEndData',
  DataType.ticTacToe: 'ticTacToe',
  DataType.connect4: 'connect4',
};
