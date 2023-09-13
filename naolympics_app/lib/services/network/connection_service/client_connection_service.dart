import "dart:async";
import "dart:io";

import "package:logging/logging.dart";
import "package:naolympics_app/services/network/connection_service/connection_service_log_utils.dart";
import "package:naolympics_app/services/network/connection_service/connection_service_network_utils.dart";
import "package:naolympics_app/services/network/connection_service/connections_service_enums.dart";
import "package:naolympics_app/services/network/socket_manager.dart";

abstract class ClientConnectionService {
  static Future<SocketManager?> connectToHost(final String ip) async {
    try {
      clientLog("Trying to connect to $ip.");
      // ignore: close_sinks
      Socket socket = await Socket.connect(ip, port);
      SocketManager connection = SocketManager.fromExistingSocket(socket);
      final success = await _outgoingConnection(connection);

      return success == ConnectionStatus.success ? connection : null;
    } on Exception catch (error) {
      clientLog(error.toString(), level: Level.SEVERE);
      return null;
    }
  }

  static Future<ConnectionStatus> _outgoingConnection(
      SocketManager socketManager) async {
    clientLog("Sending connection message.");
    await sendConnectionMessage(socketManager, ConnectionStatus.connecting);
    final completer = Completer<ConnectionStatus>();

    clientLog("Listening to incoming data from ${ipString(socketManager)}");
    final subscription = socketManager.broadcastStream.listen(
        _onData(completer),
        onError: _onError(completer),
        onDone: () => clientLog("Finished handling connection to server."));

    return completer.future
        .timeout(const Duration(seconds: 5))
        .whenComplete(subscription.cancel);
  }

  static void Function(String data) _onData(Completer completer) {
    return (data) {
      ConnectionStatus status = parseIncomingData(data);
      if (status == ConnectionStatus.success) {
        completer.complete(status);
      }
    };
  }

  static void Function(Object e) _onError(Completer completer) {
    return (e) {
      clientLog("Error while trying to receive success message from server");
      log.severe("", e);
      completer.completeError(e);
    };
  }
}
