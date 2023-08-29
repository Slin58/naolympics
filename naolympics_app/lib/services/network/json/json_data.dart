import 'data_types.dart';

abstract class JsonData {
  final DataType dataType;

  JsonData(this.dataType);

  Map<String, dynamic> toJson();
}