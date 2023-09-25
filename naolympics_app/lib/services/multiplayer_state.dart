import "package:naolympics_app/services/network/socket_manager.dart";
import "package:naolympics_app/services/routing/client_routing_service.dart";

class MultiplayerState {
  static SocketManager? connection;
  static ClientRoutingService? clientRoutingService;
  static bool _hosting = false;

  static void setHost(SocketManager connection) {
    MultiplayerState.connection = connection;
    MultiplayerState._hosting = true;
  }

  static void closeConnection() {
    connection?.closeConnection();
    connection = null;
  }

  static String? getRemoteAddress() {
    return connection?.socket.remoteAddress.address;
  }

  static bool isHosting() {
    return connection != null && _hosting;
  }

  static bool isClient() {
    return connection != null && !_hosting;
  }
}
