import 'connection_types.dart';

abstract class JsonData {
  final ConnectionTypes connectionTypes;

  JsonData(this.connectionTypes);

  Map<String, dynamic> toJson();
}