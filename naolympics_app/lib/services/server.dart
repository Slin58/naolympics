import 'dart:io';


class Server {

  bool _running;
  Server(this._running);

  void start() async {
    _running = true;

    const port = 7470;
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print('Server listening on port ${server.port}');

    await for (Socket socket in server) {
      if(_running) {
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
    final clientAddress = socket.remoteAddress.address;
    print('New client connected: $clientAddress');
    socket.listen(
          (List<int> data) {
        final message = String.fromCharCodes(data).trim();
        print('Received data: $message');

        // Handle the received data
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('Connection closed by client');
        socket.destroy();
      },
    );
  }

}


Future<void> main() async {
  Server server = Server(true);
  server.start();
}
