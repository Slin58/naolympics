import 'dart:io';

import 'package:logging/logging.dart';

import 'network_analyzer.dart';

class ConnectionService {
  static final log = Logger((ConnectionService).toString());
  static const int port = 7470;

  static Future<Socket> connectToHost(final String ip) {
    log.info("Trying to connect to $ip.");
    return Socket.connect(ip, port);
  }

  static Future<ServerSocket> createHost() {
    log.info("Now hosting on port $port.");
    return ServerSocket.bind(InternetAddress.anyIPv4, port);
  }

  static Future<List<String>> getDevices() async {
    final String? ip = await _getCurrentIp();
    log.info("Detected ip of the system: $ip");
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
