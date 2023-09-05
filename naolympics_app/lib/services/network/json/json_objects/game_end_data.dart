import 'package:json_annotation/json_annotation.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';

import '../data_types.dart';

part 'game_end_data.g.dart';

@JsonSerializable()
class GameEndData extends JsonData {
  bool reset;
  bool goBack;

  GameEndData(this.reset, this.goBack)
      : super(DataType.gameEndData);

  factory GameEndData.fromJson(Map<String, dynamic> json) =>
      _$GameEndDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameEndDataToJson(this);
}
