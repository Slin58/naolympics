import "package:json_annotation/json_annotation.dart";
import "package:naolympics_app/services/network/connection_service.dart";
import "package:naolympics_app/services/network/json/data_types.dart";
import "package:naolympics_app/services/network/json/json_data.dart";

part "connection_establishment.g.dart";

@JsonSerializable()
class ConnectionEstablishment extends JsonData {
  final ConnectionStatus connectionStatus;

  ConnectionEstablishment(this.connectionStatus)
      : super(DataType.connectionEstablishment);

  factory ConnectionEstablishment.fromJson(Map<String, dynamic> json) =>
      _$ConnectionEstablishmentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ConnectionEstablishmentToJson(this);
}
