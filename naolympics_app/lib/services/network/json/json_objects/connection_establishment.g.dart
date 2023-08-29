// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_establishment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionEstablishment _$ConnectionEstablishmentFromJson(
        Map<String, dynamic> json) =>
    ConnectionEstablishment(
      $enumDecode(_$ConnectionStatusEnumMap, json['connectionStatus']),
    )..dataType = $enumDecode(_$DataTypeEnumMap, json['dataType']);

Map<String, dynamic> _$ConnectionEstablishmentToJson(
        ConnectionEstablishment instance) =>
    <String, dynamic>{
      'dataType': _$DataTypeEnumMap[instance.dataType]!,
      'connectionStatus': _$ConnectionStatusEnumMap[instance.connectionStatus]!,
    };

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.connectionSuccessful: 'connectionSuccessful',
};

const _$DataTypeEnumMap = {
  DataType.connectionEstablishment: 'connectionEstablishment',
  DataType.navigation: 'navigation',
  DataType.ticTacToe: 'ticTacToe',
  DataType.connect4: 'connect4',
};
