import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:naolympics_app/services/network/json/json_data.dart';

class SocketManager {
  static final log = Logger((SocketManager).toString());
  Socket socket;
  late StreamController<String> streamController;
  late Stream<String> broadcastStream;

  String ip = "";
  int port = 0;

  SocketManager(this.socket, this.ip, this.port) {
    startListening();
  }

  SocketManager.fromExistingSocket(this.socket) {
    startListening();
  }

  void startListening() {
    streamController = StreamController<String>.broadcast();
    broadcastStream = streamController.stream;

    socket.listen((data) {
      String message = String.fromCharCodes(data);
      streamController.add(message);
      log.finest("The following was just received : $message");
    });
  }

  Future<void> write(String object) async {
    log.finest("Now writing to ${socket.remoteAddress.address}");
    socket.write(object);
    await socket.flush();
  }

  Future<void> writeJsonData(JsonData object) async {
   await write(json.encode(object.toJson()));
  }

  Future<void> closeConnection() async {
    await socket.close();
  }
}
