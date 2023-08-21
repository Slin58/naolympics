import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';


class NetworkService {
  final log = Logger();
  final Socket _connection;

  NetworkService(this._connection);

  Future<void> sendData(Uint8List data) {
    log.i("Sending data to ${_connection.remoteAddress}.");
    _connection.add(data);
    return _connection.flush();
  }

  Future<Uint8List> receiveData() async {
    final completer = Completer<Uint8List>();

    _connection.listen((List<int> data) {
      final receivedData = Uint8List.fromList(data);
      completer.complete(receivedData);
    }, onDone: () {
      log.i("Received data from ${_connection.remoteAddress}");
    });

    return completer.future;
  }

  Future<void> closeConnection() {
    log.i("Closing connection to ${_connection.remoteAddress}");
    return _connection.close();
  }
}
