import "dart:io";

import "package:naolympics_app/services/network/socket_manager.dart";
import "package:naolympics_app/services/routing/client_routing_service.dart";

class MultiplayerState {
  static SocketManager? _connection;
  static ClientRoutingService? clientRoutingService;
  static bool _hosting = false;

  static void setHost(SocketManager connection) {
    MultiplayerState._connection = connection;
    MultiplayerState._hosting = true;
  }

  static void setClient(SocketManager connection) {
    MultiplayerState._connection = connection;
    MultiplayerState._hosting = false;
  }

  static void closeConnection() {
    _connection?.closeConnection();
    _connection = null;
    _hosting = false;
  }

  static String? getRemoteAddress() {
    return _connection?.socket.remoteAddress.address;
  }

  static bool hasConnection() {
    return _connection != null;
  }

  static bool isHosting() {
    return _connection != null && _hosting;
  }

  static bool isClient() {
    return _connection != null && !_hosting;
  }

  static SocketManager getConnection() {
    if (_connection == null) {
      throw Exception("Currently not connected");
    } else {
      return _connection!;
    }
  }
}
