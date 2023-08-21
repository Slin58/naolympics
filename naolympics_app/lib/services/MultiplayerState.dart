import 'dart:io';

class MultiplayerState {
  static Socket? connection;
  static List<String> history = [];
  static bool _hosting = false;


  static setHost(Socket connection) {
    MultiplayerState.connection = connection;
    MultiplayerState._hosting = true;
  }

  void addIp(String ip) {
    history.add(ip);
  }

  static bool isHosting() {
    return connection != null && _hosting;
  }

  static bool isClient() {
    return connection != null && !_hosting;
  }
}
