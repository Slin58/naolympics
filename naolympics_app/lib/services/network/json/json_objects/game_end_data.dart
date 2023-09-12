import "package:json_annotation/json_annotation.dart";
import "package:naolympics_app/services/network/json/data_types.dart";
import "package:naolympics_app/services/network/json/json_data.dart";

part "game_end_data.g.dart";

@JsonSerializable()
class GameEndData extends JsonData {
  final bool reset;
  final bool goBack;

  GameEndData(this.reset, this.goBack)
      : super(DataType.gameEndData);

  GameEndData.getReset()
      : reset = true,
        goBack = false,
        super(DataType.gameEndData);

  GameEndData.getGoBack()
      : reset = false,
        goBack = true,
        super(DataType.gameEndData);

  factory GameEndData.fromJson(Map<String, dynamic> json) =>
      _$GameEndDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameEndDataToJson(this);
}
