import 'package:json_annotation/json_annotation.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';

import '../../../gamemodes/tictactoe/tictactoe.dart';
import '../data_types.dart';

part 'tictactoe_data.g.dart';

@JsonSerializable()
class TicTacToeData extends JsonData {
  final int row;
  final int column;
  final TicTacToeFieldValues fieldValue;

  TicTacToeData(this.row, this.column, this.fieldValue)
      : super(DataType.ticTacToe);

  factory TicTacToeData.fromJson(Map<String, dynamic> json) =>
      _$TicTacToeDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TicTacToeDataToJson(this);
}
