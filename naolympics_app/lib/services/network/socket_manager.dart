
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class SocketManager {
    late Socket socket;
    late StreamController<String> streamController;
    late Stream<String> broadcastStream;

    String ip = "";
    int port = 0;

    SocketManager(Socket socket, this.ip, this.port) {
        this.socket = socket;
        startListening();    }

    SocketManager.fromExistingSocket(Socket socket) {
        this.socket = socket;
        startListening();
    }

    void startListening() {
        this.streamController = StreamController<String>.broadcast();
        this.broadcastStream = streamController.stream;

        socket.listen((data) {
            String message = String.fromCharCodes(data);
            streamController.add(message);
            print("In startListening: The following was just received by SocketManager: $message");
        });
    }

    void write(Object object) {
        socket.write(object);
        socket.flush();
    }


}