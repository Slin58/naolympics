import 'package:json_annotation/json_annotation.dart';
import 'package:naolympics_app/services/network/JSON/json_data.dart';

import '../connection_service.dart';
import 'connection_types.dart';

part 'connection_establishment.g.dart';

@JsonSerializable()
class ConnectionEstablishment extends JsonData {
  final ConnectionStatus connectionStatus;


  ConnectionEstablishment(this.connectionStatus) : super(ConnectionTypes.connectionEstablishment);

  factory ConnectionEstablishment.fromJson(Map<String, dynamic> json) =>
      _$ConnectionEstablishmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectionEstablishmentToJson(this);
}
