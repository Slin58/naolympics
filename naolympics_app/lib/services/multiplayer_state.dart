import 'network/socket_manager.dart';

class MultiplayerState {
  static SocketManager? connection;
  static List<String> history = [];
  static bool _hosting = false;

  static void setHost(SocketManager connection) {
    MultiplayerState.connection = connection;
    MultiplayerState._hosting = true;
  }

  void addIp(String ip) {
    history.add(ip);
  }

  static void closeConnection() {
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
