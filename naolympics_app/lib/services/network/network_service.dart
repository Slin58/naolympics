import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class NetworkService {
  final Socket _connection;

  NetworkService(this._connection);

  Future<void> sendData(Uint8List data) {
    _connection.add(data);
    return _connection.flush();
  }

  Future<Uint8List> receiveData() async {
    final completer = Completer<Uint8List>();

    _connection.listen((List<int> data) {
      final receivedData = Uint8List.fromList(data);
      completer.complete(receivedData);
    }, onDone: () {
      print("Successful");
    });

    return completer.future;
  }

  Future<void> closeConnection() {
    return _connection.close();
  }
}
