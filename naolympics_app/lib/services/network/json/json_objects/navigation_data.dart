import 'package:json_annotation/json_annotation.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';

import '../data_types.dart';

part 'navigation_data.g.dart';

@JsonSerializable()
class NavigationData extends JsonData {
  final String route;
  final NavigationType navigationType;

  NavigationData(this.route, this.navigationType) : super(DataType.navigation);

  factory NavigationData.fromJson(Map<String, dynamic> json) =>
      _$NavigationDataFromJson(json);

  DataType get data => super.dataType;

  @override
  Map<String, dynamic> toJson() => _$NavigationDataToJson(this);

  @override
  String toString() {
    return """
    NavigationData{
         dataType: ${super.dataType}
         route: $route}'
    }
    """;
  }
}

enum NavigationType { push, pop, dispose, closeConnection }
