import "dart:io";

class Server {
  Server(this._running);

  bool _running;

  Future<void> start() async {
    _running = true;

    const port = 7470;
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);

    await for (Socket socket in server) {
      if (_running) {
        handleClient(socket);
      } else {
        break;
      }
    }
  }

  void stop() {
    _running = false;
  }

  void handleClient(Socket socket) {
    // final clientAddress = socket.remoteAddress.address;
    socket.listen(
      (data) {
        //   final message = String.fromCharCodes(data).trim();

        // Handle the received data
      },
      onDone: () {
        socket.destroy();
      },
    );
  }
}

Future<void> main() async {
  Server(true);
}
