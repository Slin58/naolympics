import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';
import 'package:naolympics_app/services/network/json/json_objects/connection_establishment.dart';
import 'package:naolympics_app/services/network/socket_manager.dart';

import 'json/json_data.dart';
import 'network_analyzer.dart';

class ConnectionService {
  static final log = Logger((ConnectionService).toString());
  static const String hostPrefix = "[HOST]:";
  static const String clientPrefix = "[CLIENT]:";

  static const Duration timeoutDuration = Duration(seconds: 5);

  static const int port = 7470;

  static Future<SocketManager?> connectToHost(final String ip) async {
    try {
      _clientLog("Trying to connect to $ip.");
      Socket socket = await Socket.connect(ip, port);
      SocketManager connection = SocketManager(socket, ip, port);

      var success = await _handleServerConnection(connection);

      if (success == ConnectionStatus.connectionSuccessful) {
        return connection;
      } else {
        return null;
      }
    } catch (error) {
      _clientLog(error.toString(), level: Level.SEVERE);
      return null;
    }
  }

  static Future<ConnectionStatus> _handleServerConnection(
      SocketManager socketManager) async {
    _clientLog("Sending connection message.");
    await socketManager
        .writeJsonData(ConnectionEstablishment(ConnectionStatus.connecting));
    final completer = Completer<ConnectionStatus>();

    StreamSubscription<String> subscription =
        socketManager.broadcastStream.listen((data) {
      _clientLog("Listening to incoming data from ${_ipString(socketManager)}");
      final jsonData = JsonData.fromJsonString(data) as ConnectionEstablishment;
      ConnectionStatus? value = jsonData.connectionStatus;
      _clientLog("Received '$data' and parsed it to '$value'",
          level: Level.FINER);
      if (value == ConnectionStatus.connectionSuccessful) {
        completer.complete(value);
      }
    }, onError: (error) {
      _clientLog("Error while trying to receive success message from server");
      log.severe("", error);
      completer.completeError(error);
    }, onDone: () => _clientLog("Finished handling connection to server"));

    return completer.future
        .timeout(timeoutDuration)
        .whenComplete(() => subscription.cancel());
  }

  static Future<SocketManager?> createHost() async {
    _hostLog("Now hosting on port $port.");
    final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    SocketManager? connection;

    await for (Socket tempSocket in serverSocket) {
      _hostLog("Incoming connection from ${_ipString(tempSocket)}");
      try {
        SocketManager socketManager =
            SocketManager.fromExistingSocket(tempSocket);
        SocketManager? client = await _handleClientConnections(socketManager);
        if (client != null) {
          _hostLog("exiting connection loop, because of value: $client");
          connection = socketManager;
          break;
        }
      } catch (error) {
        _hostLog(error.toString(), level: Level.WARNING);
      }
    }
    _hostLog("Stopping to listen to incoming connections.");
    serverSocket.close();
    return connection;
  }

  static Future<SocketManager?> _handleClientConnections(
      SocketManager socketManager) async {
    final completer = Completer<SocketManager?>();
    StreamSubscription<String> subscription =
        socketManager.broadcastStream.listen((data) async {
      final jsonData = JsonData.fromJsonString(data) as ConnectionEstablishment;
      ConnectionStatus? value = jsonData.connectionStatus;
      _hostLog("Server received '$data' and parsed it to '$value'",
          level: Level.FINER);

      if (value == ConnectionStatus.connecting) {
        _hostLog(
            "Sending success message to ${_ipString(socketManager.socket)}");
        await socketManager.writeJsonData(
            ConnectionEstablishment(ConnectionStatus.connectionSuccessful));
        completer.complete(socketManager);
        _hostLog("finished handling connection to client");
      }
    }, onError: (error) {
      _hostLog('Error: $error', level: Level.SEVERE);
      completer.completeError(error);
    }, onDone: () => _hostLog("finished handling connection to client"));

    return completer.future
        .timeout(const Duration(milliseconds: 500))
        .whenComplete(() => subscription.cancel());
  }

  static String _ipString(socket) {
    if (socket is Socket) {
      return socket.remoteAddress.address;
    } else if (socket is SocketManager) {
      return socket.socket.remoteAddress.address;
    } else {
      throw UnimplementedError("Unknown input ${socket.runtimeType}");
    }
  }

  static Future<List<String>> getDevices() async {
    final String? ip = await _getCurrentIp();
    log.info("Current ip of the system: $ip");
    if (ip == null) {
      return Future(() => List.empty());
    } else {
      final String submask = ip.substring(0, ip.lastIndexOf('.'));
      final List<String> devices = await _discoverDevices(submask, port);
      log.info("Found ip addresses for given port: $devices");

      if (devices.contains(ip)) {
        devices.remove(ip);
      }
      return devices;
    }
  }

  static Future<String?> _getCurrentIp() async {
    final wlanInterfaces = await _getWlanInterfaces();
    if (wlanInterfaces.isEmpty) {
      return null;
    } else if (wlanInterfaces.any(_containsHotspot)) {
      return wlanInterfaces
          .firstWhere(_containsHotspot)
          .addresses
          .first
          .address;
    } else {
      return wlanInterfaces.first.addresses.first.address;
    }
  }

  static Future<List<NetworkInterface>> _getWlanInterfaces() async {
    final List<NetworkInterface> interfaces =
        await NetworkInterface.list(type: InternetAddressType.IPv4);

    return Stream<NetworkInterface>.fromIterable(interfaces)
        .where((i) => WlanInterfaceNames.getValues().contains(i.name))
        .toList();
  }

  static bool _containsHotspot(NetworkInterface interface) =>
      WlanInterfaceNames.androidHotspot.name == interface.name;

  static Future<List<String>> _discoverDevices(String subnet, int port) {
    return NetworkAnalyzer.discover2(subnet, port)
        .where((device) => device.exists)
        .map((device) => device.ip)
        .toList();
  }

  static void _clientLog(String message, {Level? level}) {
    _showPrefixLog(clientPrefix, message, level);
  }

  static void _hostLog(String message, {Level? level}) {
    _showPrefixLog(hostPrefix, message, level);
  }

  static void _showPrefixLog(String prefix, String message, Level? level) {
    switch (level) {
      case null:
        log.info("$prefix $message");
        break;
      case Level.SEVERE:
        log.severe("$prefix $message");
        break;
      case Level.WARNING:
        log.warning("$prefix $message");
        break;
      case Level.FINE:
        log.fine("$prefix $message");
        break;
      case Level.FINER:
        log.finer("$prefix $message");
        break;
      default:
        throw UnimplementedError("Log-level $level is not implemented!");
    }
  }
}

enum WlanInterfaceNames {
  windows("WLAN"),
  android1("wlan0"),
  android2("wlan2"),
  androidHotspot("ap_br_wlan2");

  final String name;

  const WlanInterfaceNames(this.name);

  static List<String> getValues() {
    return WlanInterfaceNames.values.map((i) => i.name).toList();
  }
}

enum ConnectionStatus {
  connecting,
  connectionSuccessful;

  Uint8List toBytes() {
    final intEnumValue = index;
    var val = Uint8List.fromList([intEnumValue]);
    return val;
  }

  static ConnectionStatus? bytesToConnectionStatus(String message) {
    //todo: client currently sends "[91, 48, 93]" as msg when connecting. this parses to null. am changing this to work temporarily for test purposes
    try {
      ConnectionStatus connectionStatus =
          ConnectionStatus.values.firstWhere((e) => e.toString() == message);
      return connectionStatus;
    } catch (error) {
      return null;
    }
  }
}
