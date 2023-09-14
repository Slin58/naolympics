import "package:json_annotation/json_annotation.dart";
import "package:naolympics_app/services/network/json/data_types.dart";
import "package:naolympics_app/services/network/json/json_data.dart";

part "connect4_data.g.dart";

@JsonSerializable()
class Connect4Data extends JsonData {
  final List<List<int>> board;

  Connect4Data(this.board)
      : super(DataType.connect4);

  factory Connect4Data.fromJson(Map<String, dynamic> json) =>
      _$Connect4DataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$Connect4DataToJson(this);
}