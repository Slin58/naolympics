import "dart:async";
import "dart:io";

import "package:logging/logging.dart";
import "package:naolympics_app/services/network/connection_service/connection_service_log_utils.dart";
import "package:naolympics_app/services/network/connection_service/connection_service_network_utils.dart";
import "package:naolympics_app/services/network/connection_service/connections_service_enums.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

class HostConnectionService {
  static Future<SocketManager?> createHost() async {
    hostLog("Now hosting on port $port.");
    final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    SocketManager? connection;

    await for (Socket tempSocket in serverSocket) {
      hostLog("Incoming connection from ${ipString(tempSocket)}");
      try {
        SocketManager socketManager =
            SocketManager.fromExistingSocket(tempSocket);
        SocketManager? client = await _handleIncomingConnection(socketManager);
        if (client != null) {
          hostLog("Exiting connection loop, because of value: $client.");
          connection = socketManager;
          break;
        }
      } on Exception catch (error) {
        hostLog(error.toString(), level: Level.WARNING);
      }
    }
    hostLog("Stopping to listen to incoming connections.");
    await serverSocket.close();
    return connection;
  }

  static Future<SocketManager?> _handleIncomingConnection(
      SocketManager socketManager) async {
    final completer = Completer<SocketManager?>();
    final subscription = socketManager.broadcastStream.listen(
        _onData(socketManager, completer),
        onError: _onError(completer),
        onDone: () => hostLog("finished handling client connection."));

    return completer.future
        .timeout(const Duration(milliseconds: 500))
        .whenComplete(subscription.cancel);
  }

  static void Function(String data) _onData(
      SocketManager socketManager, Completer completer) {
    return (data) async {
      ConnectionStatus status = parseIncomingData(data);

      if (status == ConnectionStatus.connecting) {
        hostLog("Sending success message to ${ipString(socketManager)}");
        await sendConnectionMessage(socketManager, ConnectionStatus.success);
        await Future.delayed(const Duration(milliseconds: 100));
        completer.complete(socketManager);
      }
    };
  }

  static void Function(Object e) _onError(Completer completer) {
    return (e) {
      hostLog("Error: $e", level: Level.SEVERE);
      completer.completeError(e);
    };
  }
}
