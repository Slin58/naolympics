// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tictactoe_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicTacToeData _$TicTacToeDataFromJson(Map<String, dynamic> json) =>
    TicTacToeData(
      json['row'] as int,
      json['column'] as int,
      $enumDecode(_$TicTacToeFieldValuesEnumMap, json['fieldValue']),
    )..dataType = $enumDecode(_$DataTypeEnumMap, json['dataType']);

Map<String, dynamic> _$TicTacToeDataToJson(TicTacToeData instance) =>
    <String, dynamic>{
      'dataType': _$DataTypeEnumMap[instance.dataType]!,
      'row': instance.row,
      'column': instance.column,
      'fieldValue': _$TicTacToeFieldValuesEnumMap[instance.fieldValue]!,
    };

const _$TicTacToeFieldValuesEnumMap = {
  TicTacToeFieldValues.x: 'x',
  TicTacToeFieldValues.o: 'o',
  TicTacToeFieldValues.empty: 'empty',
};

const _$DataTypeEnumMap = {
  DataType.connectionEstablishment: 'connectionEstablishment',
  DataType.navigation: 'navigation',
  DataType.gameEndData: 'gameEndData',
  DataType.ticTacToe: 'ticTacToe',
  DataType.connect4: 'connect4',
};
