import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';

import '../../utils/logger.dart';
import 'network_analyzer.dart';

class ConnectionService {
  static final log = getLogger();
  static const String hostPrefix = "[HOST]:";
  static const String clientPrefix = "[CLIENT]:";

  static const Duration timeoutDuration = Duration(seconds: 5);

  static const int port = 7470;

  static Future<Socket?> connectToHost(final String ip) async {
    try {
      _clientLog("Trying to connect to $ip.");
      Socket connection = await Socket.connect(ip, port);
      var success = await _handleServerConnection(connection);
      _clientLog("Finished method '_handleServerConnection'");

      if (success == ConnectionStatus.connectionSuccessful) {
        return connection;
      } else {
        return null;
      }
    } catch (error) {
      _clientLog(error.toString(), level: Level.error);
      return null;
    }
  }

  static Future<ConnectionStatus> _handleServerConnection(Socket socket) async {
    _clientLog("Sending connection message.");
    socket.write(ConnectionStatus.connecting.toBytes());
    await socket.flush();

    final completer = Completer<ConnectionStatus>();

    _clientLog(
        "Trying to listen to incoming data from ${socket.remoteAddress.address}");
    socket.listen((data) {
      ConnectionStatus? value = ConnectionStatus.bytesToConnectionStatus(data);
      _clientLog("Client received '$data' and parsed it to '$value'");

      if (value == ConnectionStatus.connectionSuccessful) {
        completer.complete(value);
      }
    }, onError: (error) {
      _clientLog("Error while trying to receive success message from server");
      completer.completeError(error);
    }, onDone: () {
      _clientLog("Finished handling connection to server");
    });

    return completer.future.timeout(timeoutDuration);
  }

  static Future<Socket?> createHost() async {
    _hostLog("Now hosting on port $port.");
    final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    Socket? connection;

    await for (Socket socket in serverSocket) {
      _hostLog("Incoming connection from ${socket.remoteAddress.address}");
      try {
        Socket? client = await _handleClientConnections(socket);
        if (client != null) {
          _hostLog("exiting connection loop, because of value: $client");
          connection = socket;
          break;
        }
      } catch (error) {
        _hostLog(error.toString(), level: Level.error);
      }
    }
    _hostLog("Stopping to listen to incoming connections.");
    serverSocket.close();
    return connection;
  }

  static _handleClientConnections(Socket socket) async {
    final completer = Completer<Socket?>();

    socket.listen((data) async {
      ConnectionStatus? value = ConnectionStatus.bytesToConnectionStatus(data);
      _hostLog("Server received '$data' and parsed it to '$value'");
      if (value == ConnectionStatus.connecting) {
        _hostLog("Sending success message to ${socket.remoteAddress.address}");
        socket.write(ConnectionStatus.connectionSuccessful.toBytes());
        await socket.flush();
        completer.complete(socket);
      }
    }, onError: (error) {
      _hostLog('Error: $error', level: Level.error);
      completer.completeError(error);
    }, onDone: () {
      _hostLog("finished handling connection to client");
    });

    return completer.future.timeout(timeoutDuration);
  }

  static Future<List<String>> getDevices() async {
    final String? ip = await _getCurrentIp();
    log.i("Current ip of the system: $ip");
    if (ip == null) {
      return Future(() => List.empty());
    } else {
      final String submask = ip.substring(0, ip.lastIndexOf('.'));
      final List<String> devices = await _discoverDevices(submask, port);
      log.i("Found ip addresses for given port: $devices");

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
        log.i("$prefix $message");
        break;
      case Level.debug:
        log.d("$prefix $message");
        break;
      case Level.error:
        log.e("$prefix $message");
        break;
      case Level.warning:
        log.w("$prefix $message");
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

  static ConnectionStatus? bytesToConnectionStatus(Uint8List bytes) {
    try {
      final intEnumValue = bytes[0];
      return ConnectionStatus.values[intEnumValue];
    } catch (error) {
      return null;
    }
  }
}
