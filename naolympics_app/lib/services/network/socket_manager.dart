import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

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
      log.info("The following was just received : $message");
    });
  }

  void write(String object) {
    log.info("Now writing to ${socket.remoteAddress.address}");
    socket.write(object);
    socket.flush();
  }
}
