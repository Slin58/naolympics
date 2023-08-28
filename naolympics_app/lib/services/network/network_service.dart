import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';



class NetworkService {
  static final log = Logger((NetworkService).toString());
  final Socket _connection;

  NetworkService(this._connection);

  Future<void> sendData(Uint8List data) {
    log.info("Sending data to ${_connection.remoteAddress}.");
    _connection.add(data);
    return _connection.flush();
  }

  Future<Uint8List> receiveData() async {
    final completer = Completer<Uint8List>();

    _connection.listen((List<int> data) {
      final receivedData = Uint8List.fromList(data);
      completer.complete(receivedData);
    }, onDone: () {
      log.info("Received data from ${_connection.remoteAddress}");
    });

    return completer.future;
  }

  Future<void> closeConnection() {
    log.info("Closing connection to ${_connection.remoteAddress}");
    return _connection.close();
  }
}
