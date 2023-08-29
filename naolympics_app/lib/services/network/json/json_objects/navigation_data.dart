import 'package:json_annotation/json_annotation.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';

import '../../connection_service.dart';
import '../data_types.dart';

part 'navigation_data.g.dart';

@JsonSerializable()
class NavigationData extends JsonData {
  final String route;


  NavigationData(this.route) : super(DataType.connectionEstablishment);

  factory NavigationData.fromJson(Map<String, dynamic> json) =>
      _$NavigationDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NavigationDataToJson(this);
}
