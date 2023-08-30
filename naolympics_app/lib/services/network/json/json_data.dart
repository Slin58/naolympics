import 'data_types.dart';

abstract class JsonData {
  DataType dataType;

  JsonData(this.dataType);

  Map<String, dynamic> toJson();
}
