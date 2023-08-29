// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_establishment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionEstablishment _$ConnectionEstablishmentFromJson(
        Map<String, dynamic> json) =>
    ConnectionEstablishment(
      $enumDecode(_$ConnectionStatusEnumMap, json['connectionStatus']),
    );

Map<String, dynamic> _$ConnectionEstablishmentToJson(
        ConnectionEstablishment instance) =>
    <String, dynamic>{
      'connectionStatus': _$ConnectionStatusEnumMap[instance.connectionStatus]!,
    };

const _$ConnectionStatusEnumMap = {
  ConnectionStatus.connecting: 'connecting',
  ConnectionStatus.connectionSuccessful: 'connectionSuccessful',
};
